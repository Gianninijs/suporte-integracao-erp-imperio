-- ==========================================
-- 1. QUANTIDADE DE ERROS DE INTEGRAÇÃO POR LOJA
-- Objetivo: Identificar lojas com maior volume de falhas/pendências
-- ==========================================

SELECT 
  COUNT(status_integracao) AS qtd_status_integracao,
  loja_destino,
  status_integracao
FROM 
  tb_fila_integracoes
WHERE 
  status_integracao <> 'SUCESSO'
GROUP BY 
  2,3
ORDER BY 
    COUNT(status_integracao) DESC;


-- ==========================================
-- 2. GARGALOS NA FILA (> 30 MINUTOS)
-- Objetivo: Priorizar pedidos travados que impactam o faturamento
-- ==========================================

SELECT 
  numero_pedido,
  loja_destino,
  status_integracao,
  codigo_http,
  tentativas,
  ROUND(extract(EPOCH FROM (NOW() - data_criacao))/ 60,0) AS minutos_em_fila,
  mensagem_log_erro
FROM
  tb_fila_integracoes
WHERE 
  status_integracao IN ('ERRO', 'PENDENTE')
AND 
  data_criacao < NOW() - INTERVAL '30 minutes'
ORDER BY 
  minutos_em_fila DESC;


-- ==========================================
-- 3. CAUSA-RAIZ E RECEITA RETIDA (JSONB + CASE WHEN)
-- Objetivo: Agrupar erros técnicos/de negócio e medir impacto financeiro
-- ==========================================

SELECT 
    CASE 
        WHEN mensagem_log_erro LIKE '%ORA-02291%' THEN 'Cadastro de Cliente Ausente no ERP (FK)'
        WHEN mensagem_log_erro LIKE '%Timeout%' THEN 'Instabilidade / Lentidão API Sankhya (504)'
        WHEN mensagem_log_erro LIKE '%Validation Error%' THEN 'Falha de Preenchimento no E-commerce (400)'
        ELSE 'Fila Aguardando Processamento'
    END AS categoria_incidente,
    COUNT(*) AS total_ocorrencias,
    SUM((payload_json->>'valor')::NUMERIC) AS receita_retida_brl,
    status_integracao
FROM 
  tb_fila_integracoes
WHERE 
  status_integracao <> 'SUCESSO'
GROUP BY
  1,4
ORDER BY 
  receita_retida_brl DESC;

-- ==========================================
-- 4. PEDIDOS COM MAIOR QUANTIDADE DE FALHAS
-- Objetivo: Agrupar erros técnicos/de negócio e medir impacto financeiro
-- ==========================================

SELECT 
  numero_pedido,
  loja_destino,
  codigo_http,
  tentativas,
  mensagem_log_erro
FROM 
  tb_fila_integracoes
WHERE 
  tentativas > 3
ORDER BY 
  tentativas DESC;


-- ==========================================
-- 4. SANEAMENTO / REPROCESSAMENTO (SIMULAÇÃO)
-- Objetivo: Ajustar payload inválido antes de reenviar ao ERP
-- ==========================================

-- O pedido 'IMP-9044' tem um erro de validação por CPF ausente
SELECT 
  numero_pedido,
  loja_destino,
  sistema_origem,
  payload_json,
  status_integracao,
  codigo_http,
  mensagem_log_erro
FROM 
  tb_fila_integracoes
where
  numero_pedido = 'IMP-9044'


-- Irei fazer uma correção manual
UPDATE tb_fila_integracoes
SET 
  payload_json = jsonb_set(payload_json, '{cpf}', '"00011122233"', true),
  status_integracao = 'PENDENTE',
  codigo_http = NULL,
  mensagem_log_erro = 'Corrigido CPF ausente no payload; aguardando reenvio ao ERP Sankhya',
  data_ultima_tentativa = NOW()
WHERE numero_pedido = 'IMP-9044';

-- Quantidade de erros de integração por Loja

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

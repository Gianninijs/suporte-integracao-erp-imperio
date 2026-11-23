-- Criação da tabela simulando a fila de integração E-commerce -> ERP Sankhya
CREATE TABLE tb_fila_integracoes (
    id_integracao SERIAL PRIMARY KEY,
    numero_pedido VARCHAR(20) NOT NULL,
    loja_destino VARCHAR(50),
    sistema_origem VARCHAR(30) DEFAULT 'E-commerce',
    sistema_destino VARCHAR(30) DEFAULT 'ERP Sankhya',
    payload_json JSONB,
    status_integracao VARCHAR(20), -- 'SUCESSO', 'ERRO', 'PENDENTE'
    codigo_http INT,
    mensagem_log_erro TEXT,
    tentativas INT DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_ultima_tentativa TIMESTAMP
);

-- Inserção de massa de dados para diagnóstico
INSERT INTO tb_fila_integracoes 
(numero_pedido, loja_destino, payload_json, status_integracao, codigo_http, mensagem_log_erro, tentativas, data_criacao, data_ultima_tentativa)
VALUES
('IMP-9041', 'Loja 01 - Recife Centro', '{"cpf": "12345678900", "sku": "SOFA-3L", "valor": 1899.90}', 'SUCESSO', 200, NULL, 1, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours'),
('IMP-9042', 'Loja 12 - Jaboatão', '{"cpf": "98765432100", "sku": "GEL-400L", "valor": 3290.00}', 'ERRO', 422, 'ORA-02291: integrity constraint (SANKHYA.FK_CODPARC) violated - parent key not found', 3, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '10 minutes'),
('IMP-9043', 'Loja 05 - Caruaru', '{"cpf": "45612378900", "sku": "FOGAO-5B", "valor": 1150.00}', 'ERRO', 504, 'Gateway Timeout: ERP Sankhya API did not respond within 30000ms', 5, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '5 minutes'),
('IMP-9044', 'Loja 18 - João Pessoa', '{"cpf": "", "sku": "TV-55-4K", "valor": 2799.00}', 'ERRO', 400, 'Validation Error: Field [cpf_cnpj] cannot be null or empty in JSON payload', 1, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour'),
('IMP-9045', 'Loja 22 - Maceió', '{"cpf": "32165498700", "sku": "CAMA-BOX", "valor": 1450.00}', 'PENDENTE', NULL, NULL, 0, NOW() - INTERVAL '45 minutes', NULL),
('IMP-9046', 'Loja 01 - Recife Centro', '{"cpf": "78912345600", "sku": "GUARD-6P", "valor": 980.00}', 'ERRO', 422, 'ORA-02291: integrity constraint (SANKHYA.FK_CODPARC) violated - parent key not found', 3, NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '2 minutes');

BANCO DE DADOS SISTEMA BANCÁRIO
-- =============================================
CREATE DATABASE IF NOT EXISTS sistema_bancario;
USE sistema_bancario;

-- =============================================
-- TABELAS PRINCIPAIS
-- =============================================

-- Tabela: AGENCIA
CREATE TABLE AGENCIA (
    id_agencia VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone_principal VARCHAR(20),
    data_abertura DATE,
    status ENUM('ATIVA', 'INATIVA') DEFAULT 'ATIVA',
    INDEX idx_agencia_status (status)
);

-- Tabela: CLIENTE
CREATE TABLE CLIENTE (
    id_cliente VARCHAR(20) PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nome_completo VARCHAR(100) NOT NULL,
    data_nascimento DATE,
    email VARCHAR(100),
    profissao VARCHAR(50),
    data_cadastro DATE DEFAULT (CURRENT_DATE),
    status ENUM('ATIVO', 'INATIVO', 'BLOQUEADO') DEFAULT 'ATIVO',
    INDEX idx_cliente_cpf (cpf),
    INDEX idx_cliente_status (status)
);

-- Tabela: CONTA
CREATE TABLE CONTA (
    numero_conta VARCHAR(20) PRIMARY KEY,
    id_agencia VARCHAR(10) NOT NULL,
    tipo_conta ENUM('CORRENTE', 'POUPANCA', 'INVESTIMENTO', 'SALARIO') DEFAULT 'CORRENTE',
    saldo DECIMAL(15,2) DEFAULT 0.00,
    limite_credito DECIMAL(15,2) DEFAULT 0.00,
    limite_saque_diario DECIMAL(15,2) DEFAULT 1000.00,
    data_abertura DATE DEFAULT (CURRENT_DATE),
    data_encerramento DATE,
    status ENUM('ATIVA', 'BLOQUEADA', 'ENCERRADA') DEFAULT 'ATIVA',
    FOREIGN KEY (id_agencia) REFERENCES AGENCIA(id_agencia),
    INDEX idx_conta_agencia (id_agencia),
    INDEX idx_conta_status (status),
    INDEX idx_conta_tipo (tipo_conta)
);

-- Tabela: FUNCIONARIO
CREATE TABLE FUNCIONARIO (
    id_funcionario VARCHAR(20) PRIMARY KEY,
    id_agencia VARCHAR(10) NOT NULL,
    nome_completo VARCHAR(100) NOT NULL,
    cargo ENUM('GERENTE', 'CAIXA', 'ATENDENTE', 'ANALISTA') DEFAULT 'ATENDENTE',
    salario DECIMAL(10,2),
    data_admissao DATE DEFAULT (CURRENT_DATE),
    data_demissao DATE,
    status ENUM('ATIVO', 'AFASTADO', 'DEMITIDO') DEFAULT 'ATIVO',
    FOREIGN KEY (id_agencia) REFERENCES AGENCIA(id_agencia),
    INDEX idx_funcionario_agencia (id_agencia),
    INDEX idx_funcionario_cargo (cargo)
);

-- Tabela: TRANSACAO
CREATE TABLE TRANSACAO (
    id_transacao VARCHAR(36) PRIMARY KEY,
    numero_conta_origem VARCHAR(20),
    numero_conta_destino VARCHAR(20),
    valor DECIMAL(15,2) NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo ENUM('DEPOSITO', 'SAQUE', 'TRANSFERENCIA', 'PAGAMENTO') NOT NULL,
    descricao VARCHAR(200),
    codigo_autenticacao VARCHAR(50) UNIQUE,
    status ENUM('CONCLUIDA', 'PENDENTE', 'CANCELADA') DEFAULT 'CONCLUIDA',
    FOREIGN KEY (numero_conta_origem) REFERENCES CONTA(numero_conta),
    FOREIGN KEY (numero_conta_destino) REFERENCES CONTA(numero_conta),
    INDEX idx_transacao_origem (numero_conta_origem),
    INDEX idx_transacao_destino (numero_conta_destino),
    INDEX idx_transacao_data (data_hora),
    INDEX idx_transacao_tipo (tipo),
    CHECK (valor > 0)
);

-- =============================================
-- TABELAS DE RELACIONAMENTO
-- =============================================

-- Tabela: CLIENTE_CONTA
CREATE TABLE CLIENTE_CONTA (
    id_cliente VARCHAR(20) NOT NULL,
    numero_conta VARCHAR(20) NOT NULL,
    data_associacao DATE DEFAULT (CURRENT_DATE),
    tipo_relacionamento ENUM('TITULAR', 'COTITULAR', 'PROCURADOR') DEFAULT 'TITULAR',
    tipo_titularidade ENUM('INDIVIDUAL', 'CONJUNTA', 'SOLIDARIA') DEFAULT 'INDIVIDUAL',
    assinatura_obrigatoria BOOLEAN DEFAULT FALSE,
    limite_operacao DECIMAL(15,2),
    PRIMARY KEY (id_cliente, numero_conta),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (numero_conta) REFERENCES CONTA(numero_conta) ON DELETE CASCADE,
    INDEX idx_cliente_conta_cliente (id_cliente),
    INDEX idx_cliente_conta_conta (numero_conta)
);

-- =============================================
-- TABELAS AUXILIARES (Correções 1FN)
-- =============================================

-- Tabela: ENDERECO_CLIENTE
CREATE TABLE ENDERECO_CLIENTE (
    id_endereco VARCHAR(36) PRIMARY KEY,
    id_cliente VARCHAR(20) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    tipo ENUM('RESIDENCIAL', 'COMERCIAL', 'COBRANCA') DEFAULT 'RESIDENCIAL',
    endereco_principal BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE CASCADE,
    INDEX idx_end_cliente (id_cliente),
    INDEX idx_end_principal (endereco_principal)
);

-- Tabela: TELEFONE_CLIENTE
CREATE TABLE TELEFONE_CLIENTE (
    id_telefone VARCHAR(36) PRIMARY KEY,
    id_cliente VARCHAR(20) NOT NULL,
    numero_telefone VARCHAR(20) NOT NULL,
    tipo ENUM('CELULAR', 'RESIDENCIAL', 'COMERCIAL') DEFAULT 'CELULAR',
    operadora VARCHAR(20),
    telefone_principal BOOLEAN DEFAULT TRUE,
    whatsapp BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE CASCADE,
    INDEX idx_tel_cliente (id_cliente),
    INDEX idx_tel_principal (telefone_principal)
);

-- Tabela: ENDERECO_AGENCIA
CREATE TABLE ENDERECO_AGENCIA (
    id_endereco VARCHAR(36) PRIMARY KEY,
    id_agencia VARCHAR(10) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    ponto_referencia VARCHAR(100),
    FOREIGN KEY (id_agencia) REFERENCES AGENCIA(id_agencia) ON DELETE CASCADE,
    INDEX idx_end_agencia (id_agencia)
);

-- Tabela: TELEFONE_AGENCIA
CREATE TABLE TELEFONE_AGENCIA (
    id_telefone VARCHAR(36) PRIMARY KEY,
    id_agencia VARCHAR(10) NOT NULL,
    numero_telefone VARCHAR(20) NOT NULL,
    ramal VARCHAR(10),
    departamento ENUM('ATENDIMENTO', 'GERENCIA', 'OPERACOES') DEFAULT 'ATENDIMENTO',
    telefone_principal BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_agencia) REFERENCES AGENCIA(id_agencia) ON DELETE CASCADE,
    INDEX idx_tel_agencia (id_agencia)
);

-- Tabela: ENDERECO_FUNCIONARIO
CREATE TABLE ENDERECO_FUNCIONARIO (
    id_endereco VARCHAR(36) PRIMARY KEY,
    id_funcionario VARCHAR(20) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    tipo ENUM('RESIDENCIAL', 'COMERCIAL') DEFAULT 'RESIDENCIAL',
    FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario) ON DELETE CASCADE,
    INDEX idx_end_funcionario (id_funcionario)
);

-- =============================================
-- TABELAS DE SEGURANÇA E AUDITORIA
-- =============================================

-- Tabela: USUARIO_SISTEMA
CREATE TABLE USUARIO_SISTEMA (
    id_usuario VARCHAR(36) PRIMARY KEY,
    id_funcionario VARCHAR(20) UNIQUE NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil ENUM('ADMIN', 'GERENTE', 'OPERADOR', 'CONSULTA') DEFAULT 'OPERADOR',
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_expiracao_senha DATE,
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario),
    INDEX idx_usuario_login (login),
    INDEX idx_usuario_ativo (ativo)
);

-- Tabela: LOG_ACESSO
CREATE TABLE LOG_ACESSO (
    id_log VARCHAR(36) PRIMARY KEY,
    id_usuario VARCHAR(36) NOT NULL,
    data_hora_login DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_hora_logout DATETIME,
    ip_address VARCHAR(45),
    dispositivo VARCHAR(100),
    status_sessao ENUM('ATIVA', 'FINALIZADA', 'EXPIRADA') DEFAULT 'ATIVA',
    FOREIGN KEY (id_usuario) REFERENCES USUARIO_SISTEMA(id_usuario),
    INDEX idx_log_usuario (id_usuario),
    INDEX idx_log_data (data_hora_login)
);

-- Tabela: AUDITORIA_TRANSACAO
CREATE TABLE AUDITORIA_TRANSACAO (
    id_auditoria VARCHAR(36) PRIMARY KEY,
    id_transacao VARCHAR(36) NOT NULL,
    id_usuario VARCHAR(36) NOT NULL,
    data_hora_auditoria DATETIME DEFAULT CURRENT_TIMESTAMP,
    acao ENUM('CRIACAO', 'ALTERACAO', 'CANCELAMENTO') NOT NULL,
    dados_anteriores JSON,
    dados_novos JSON,
    motivo VARCHAR(200),
    FOREIGN KEY (id_transacao) REFERENCES TRANSACAO(id_transacao),
    FOREIGN KEY (id_usuario) REFERENCES USUARIO_SISTEMA(id_usuario),
    INDEX idx_auditoria_transacao (id_transacao),
    INDEX idx_auditoria_usuario (id_usuario),
    INDEX idx_auditoria_data (data_hora_auditoria)
);

-- =============================================
-- TRIGGERS PARA AUDITORIA
-- =============================================

-- Trigger para auditoria de transações
DELIMITER //
CREATE TRIGGER after_transacao_insert
    AFTER INSERT ON TRANSACAO
    FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_TRANSACAO (
        id_auditoria, id_transacao, id_usuario, acao, dados_novos, motivo
    ) VALUES (
        UUID(), NEW.id_transacao, 'SISTEMA', 'CRIACAO',
        JSON_OBJECT(
            'numero_conta_origem', NEW.numero_conta_origem,
            'numero_conta_destino', NEW.numero_conta_destino,
            'valor', NEW.valor,
            'tipo', NEW.tipo,
            'descricao', NEW.descricao
        ),
        'Transação criada automaticamente'
    );
END//
DELIMITER ;

-- =============================================
-- STORED PROCEDURES
-- =============================================

-- Procedure para criar nova conta
DELIMITER //
CREATE PROCEDURE CriarNovaConta(
    IN p_numero_conta VARCHAR(20),
    IN p_id_agencia VARCHAR(10),
    IN p_tipo_conta ENUM('CORRENTE', 'POUPANCA', 'INVESTIMENTO', 'SALARIO'),
    IN p_id_cliente VARCHAR(20),
    IN p_tipo_titularidade ENUM('INDIVIDUAL', 'CONJUNTA', 'SOLIDARIA')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Inserir conta
    INSERT INTO CONTA (numero_conta, id_agencia, tipo_conta)
    VALUES (p_numero_conta, p_id_agencia, p_tipo_conta);
    
    -- Associar cliente à conta
    INSERT INTO CLIENTE_CONTA (id_cliente, numero_conta, tipo_titularidade)
    VALUES (p_id_cliente, p_numero_conta, p_tipo_titularidade);
    
    COMMIT;
END//
DELIMITER ;

-- Procedure para realizar transação
DELIMITER //
CREATE PROCEDURE RealizarTransacao(
    IN p_id_transacao VARCHAR(36),
    IN p_numero_conta_origem VARCHAR(20),
    IN p_numero_conta_destino VARCHAR(20),
    IN p_valor DECIMAL(15,2),
    IN p_tipo ENUM('DEPOSITO', 'SAQUE', 'TRANSFERENCIA', 'PAGAMENTO'),
    IN p_descricao VARCHAR(200)
)
BEGIN
    DECLARE v_saldo_origem DECIMAL(15,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Verificar saldo para saques e transferências
    IF p_tipo IN ('SAQUE', 'TRANSFERENCIA') THEN
        SELECT saldo INTO v_saldo_origem 
        FROM CONTA 
        WHERE numero_conta = p_numero_conta_origem
        FOR UPDATE;
        
        IF v_saldo_origem < p_valor THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
        END IF;
        
        -- Debitar conta origem
        UPDATE CONTA 
        SET saldo = saldo - p_valor 
        WHERE numero_conta = p_numero_conta_origem;
    END IF;
    
    -- Creditar conta destino para depósitos e transferências
    IF p_tipo IN ('DEPOSITO', 'TRANSFERENCIA') THEN
        UPDATE CONTA 
        SET saldo = saldo + p_valor 
        WHERE numero_conta = p_numero_conta_destino;
    END IF;
    
    -- Registrar transação
    INSERT INTO TRANSACAO (
        id_transacao, numero_conta_origem, numero_conta_destino, 
        valor, tipo, descricao, codigo_autenticacao
    ) VALUES (
        p_id_transacao, p_numero_conta_origem, p_numero_conta_destino,
        p_valor, p_tipo, p_descricao, UUID()
    );
    
    COMMIT;
END//
DELIMITER ;

-- =============================================
-- INSERÇÃO DE DADOS EXEMPLO
-- =============================================

-- Inserir agências
INSERT INTO AGENCIA (id_agencia, nome, telefone_principal, data_abertura) VALUES
('001', 'Agência Centro', '(11) 3333-0001', '2020-01-15'),
('002', 'Agência Zona Sul', '(11) 3333-0002', '2020-03-20');

-- Inserir clientes
INSERT INTO CLIENTE (id_cliente, cpf, nome_completo, data_nascimento, email, profissao) VALUES
('CLI001', '123.456.789-00', 'João Silva Santos', '1985-05-15', 'joao.silva@email.com', 'Engenheiro'),
('CLI002', '987.654.321-00', 'Maria Oliveira Souza', '1990-08-22', 'maria.oliveira@email.com', 'Advogada'),
('CLI003', '111.222.333-44', 'Carlos Pereira Lima', '1978-12-10', 'carlos.pereira@email.com', 'Médico');

-- Inserir funcionários
INSERT INTO FUNCIONARIO (id_funcionario, id_agencia, nome_completo, cargo, salario) VALUES
('FUNC001', '001', 'Ana Costa Rodrigues', 'GERENTE', 8500.00),
('FUNC002', '001', 'Pedro Almeida Santos', 'CAIXA', 3200.00),
('FUNC003', '002', 'Juliana Martins Lima', 'GERENTE', 8200.00);

-- Inserir contas usando a stored procedure
CALL CriarNovaConta('12345-1', '001', 'CORRENTE', 'CLI001', 'INDIVIDUAL');
CALL CriarNovaConta('23456-2', '001', 'POUPANCA', 'CLI002', 'INDIVIDUAL');
CALL CriarNovaConta('34567-3', '002', 'CORRENTE', 'CLI003', 'INDIVIDUAL');

-- Inserir endereços
INSERT INTO ENDERECO_CLIENTE (id_endereco, id_cliente, cep, logradouro, numero, bairro, cidade, estado) VALUES
(UUID(), 'CLI001', '01234-567', 'Rua das Flores', '123', 'Centro', 'São Paulo', 'SP'),
(UUID(), 'CLI002', '04567-890', 'Avenida Paulista', '456', 'Bela Vista', 'São Paulo', 'SP');

-- Inserir telefones
INSERT INTO TELEFONE_CLIENTE (id_telefone, id_cliente, numero_telefone, tipo, telefone_principal, whatsapp) VALUES
(UUID(), 'CLI001', '(11) 99999-1111', 'CELULAR', TRUE, TRUE),
(UUID(), 'CLI002', '(11) 98888-2222', 'CELULAR', TRUE, TRUE);

-- =============================================
-- CONSULTAS ÚTEIS
-- =============================================

-- View: Saldo de contas por cliente
CREATE VIEW VW_SALDO_CLIENTES AS
SELECT 
    c.id_cliente,
    c.nome_completo,
    cc.numero_conta,
    ct.saldo,
    ct.tipo_conta,
    a.nome as agencia
FROM CLIENTE c
JOIN CLIENTE_CONTA cc ON c.id_cliente = cc.id_cliente
JOIN CONTA ct ON cc.numero_conta = ct.numero_conta
JOIN AGENCIA a ON ct.id_agencia = a.id_agencia
WHERE c.status = 'ATIVO' AND ct.status = 'ATIVA';

-- View: Transações recentes
CREATE VIEW VW_TRANSACOES_RECENTES AS
SELECT 
    t.id_transacao,
    t.data_hora,
    t.tipo,
    t.valor,
    co.numero_conta as conta_origem,
    cd.numero_conta as conta_destino,
    t.descricao
FROM TRANSACAO t
LEFT JOIN CONTA co ON t.numero_conta_origem = co.numero_conta
LEFT JOIN CONTA cd ON t.numero_conta_destino = cd.numero_conta
ORDER BY t.data_hora DESC;

-- =============================================
-- MOSTRAR ESTRUTURA CRIADA
-- =============================================

SHOW TABLES;

-- Verificar views criadas
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_SCHEMA = 'sistema_bancario';
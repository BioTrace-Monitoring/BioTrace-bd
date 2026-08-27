CREATE DATABASE bio_trace;
USE bio_trace;

-- EMPRESA
-- Cliente direto da BioTrace: fabricante dos equipamentos hospitalares
CREATE TABLE empresa(
	id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(100) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    celular_comercial CHAR(11) NOT NULL,
    cep CHAR(8) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    bairro VARCHAR(45) NOT NULL,
    numero VARCHAR(10) NOT NULL
);

/*INSERT INTO empresa(razao_social, cnpj, celular_comercial, cep, cidade, logradouro, bairro, numero) VALUES
();*/

-- NIVEL_ACESSO
-- Perfis de usuário dentro da empresa cliente
CREATE TABLE nivel_acesso(
	id_nivel_acesso INT PRIMARY KEY AUTO_INCREMENT,
    nome_nivel_acesso VARCHAR(45) NOT NULL,
    
    CONSTRAINT nivel_acesso_fk_nome CHECK (nome_nivel_acesso IN ('GESTOR', 'COORDENADOR', 'ANALISTA', 'TÉCNICO'))
);

INSERT INTO nivel_acesso(nome_nivel_acesso) VALUES
('GESTOR'),
('COORDENADOR'),
('ANALISTA'),
('TÉCNICO');

-- USUARIO
-- Quem loga na aplicação web para ver o dashboard: sempre vinculado a uma empresa (fabricante) e a um nível de acesso
CREATE TABLE usuario(
	id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome_usuario VARCHAR(45) NOT NULL,
    dt_nasc_usuario DATE NOT NULL,
    celular_usuario CHAR(11) NOT NULL,
    cpf_usuario CHAR(11) UNIQUE NOT NULL,
    email_usuario VARCHAR(100) UNIQUE NOT NULL,
    senha_usuario CHAR(8) NOT NULL,
    fk_empresa INT NOT NULL,
    fk_nivel_acesso INT NOT NULL,
    
    CONSTRAINT usuario_fk_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa),
    CONSTRAINT usuario_fk_nivel_acesso FOREIGN KEY (fk_nivel_acesso) REFERENCES nivel_acesso (id_nivel_acesso)
);
select * from usuario;
drop table empresa, usuario;
-- PERMISSAO / PERMISSOES_COMPARTILHADAS
-- Permissões finas associadas a cada nível de acesso
CREATE TABLE permissao(
	id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    nome_permissao VARCHAR(45) NOT NULL,
    descricao_permissao VARCHAR(100) NOT NULL
);

INSERT INTO permissao(nome_permissao, descricao_permissao) VALUES
('VISUALIZAR_DASHBOARD', 'Ver o painel geral de equipamentos monitorados'),
('CADASTRAR_EQUIPAMENTO', 'Cadastrar novo equipamento monitorado'),
('EDITAR_EQUIPAMENTO', 'Editar dados de um equipamento já cadastrado'),
('CONFIGURAR_PARAMETRO_ALERTA', 'Definir/alterar os limites de atenção e crítico por modelo'),
('CADASTRAR_HOSPITAL', 'Cadastrar/editar hospital onde equipamentos são instalados'),
('GERENCIAR_USUARIOS', 'Cadastrar, editar ou desativar usuários da própria empresa'),
('EDITAR_DADOS_EMPRESA', 'Editar dados cadastrais da empresa');

CREATE TABLE permissoes_compartilhadas(
	id_permissoes_compartilhadas INT PRIMARY KEY AUTO_INCREMENT,
    fk_nivel_acesso INT NOT NULL,
    fk_permissao INT NOT NULL,
    
    CONSTRAINT permissoes_fk_nivel_acesso FOREIGN KEY (fk_nivel_acesso) REFERENCES nivel_acesso (id_nivel_acesso),
    CONSTRAINT permissoes_fk_permissao FOREIGN KEY (fk_permissao) REFERENCES permissao (id_permissao)
);

INSERT INTO permissoes_compartilhadas(fk_nivel_acesso, fk_permissao) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(3, 1),
(4, 1),
(4, 2),
(4, 3),
(4, 4),
(4, 5),
(4, 6),
(4, 7);

-- HOSPITAL
-- Local de instalação do equipamento. Não é cliente da BioTrace e não tem usuário/login no sistema
CREATE TABLE hospital(
    id_hospital INT PRIMARY KEY AUTO_INCREMENT,
    nome_hospital VARCHAR(100) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    cep CHAR(8) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    bairro VARCHAR(45) NOT NULL,
    numero VARCHAR(10) NOT NULL
);

-- MODELO_EQUIPAMENTO
-- Agrupa equipamentos do mesmo modelo por fabricante — base para identificar padrões e para configurar os parâmetros de
-- alerta em escala (uma vez por modelo, não por equipamento)
CREATE TABLE modelo_equipamento(
    id_modelo_equipamento INT PRIMARY KEY AUTO_INCREMENT,
    nome_modelo VARCHAR(60) NOT NULL,
    fk_empresa INT NOT NULL,
    
    CONSTRAINT modelo_fk_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa)
);

-- EQUIPAMENTO
-- Cadastro do equipamento: nº de série, modelo, hospital onde está instalado no momento, status e última comunicação
CREATE TABLE equipamento(
    id_equipamento INT PRIMARY KEY AUTO_INCREMENT,
    numero_serie VARCHAR(60) NOT NULL UNIQUE,
    fk_modelo_equipamento INT NOT NULL,
    fk_hospital INT,
    dt_instalacao DATE,
    status_atual VARCHAR(45) NOT NULL,
    dt_ultima_comunicacao DATETIME,
    
    CONSTRAINT equipamento_status_atual CHECK (status_atual IN ('NORMAL', 'ATENCAO', 'CRITICO', 'INDISPONIVEL')),
    CONSTRAINT equipamento_fk_modelo FOREIGN KEY (fk_modelo_equipamento) REFERENCES modelo_equipamento (id_modelo_equipamento),
    CONSTRAINT equipamento_fk_hospital FOREIGN KEY (fk_hospital) REFERENCES hospital (id_hospital)
);

-- Limites de CPU/RAM/disco (atenção / crítico) usados pela aplicação para decidir quando um dado lido do bucket vira alerta
CREATE TABLE parametro_alerta(
    id_parametro_alerta INT PRIMARY KEY AUTO_INCREMENT,
    fk_modelo_equipamento INT NOT NULL,
    tipo_metrica VARCHAR(45) NOT NULL,
    limite_atencao DECIMAL(5,2) NOT NULL,
    limite_critico DECIMAL(5,2) NOT NULL,
    
    CONSTRAINT parametro_alerta_tipo_metrica CHECK (tipo_metrica IN ('CPU', 'RAM', 'DISCO')),
    CONSTRAINT parametro_fk_modelo FOREIGN KEY (fk_modelo_equipamento) REFERENCES modelo_equipamento (id_modelo_equipamento),
    CONSTRAINT parametro_unico_por_tipo UNIQUE (fk_modelo_equipamento, tipo_metrica)
);
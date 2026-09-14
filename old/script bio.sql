CREATE DATABASE bio_trace;
USE bio_trace;

-- EMPRESA
-- Cliente direto da BioTrace: fabricante dos equipamentos hospitalares
CREATE TABLE empresa(
	id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(100) NOT NULL,
    cnpj CHAR(14) UNIQUE NOT NULL,
    telefone_comercial CHAR(11) NOT NULL,
    cep CHAR(8) NOT NULL,
    cidade VARCHAR(45) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    bairro VARCHAR(45) NOT NULL,
    numero VARCHAR(10) NOT NULL
);

INSERT INTO empresa(razao_social, cnpj, telefone_comercial, cep, cidade, logradouro, bairro, numero) VALUES
('Homed Equipamentos Médicos Hospitalar Ltda', '15879632587598', '11959875026', '09863956', 'São Paulo', 'Rua Brasil', 'Jardins', '99'),
('Opus Medical Equipamentos Médico-Hospitalares', '29879682582599', '11987526653', '01589632', 'Santo André', 'Av Américo', 'Silvestre', '1985');

-- NIVEL_ACESSO
-- Perfis de usuário dentro da empresa cliente
CREATE TABLE nivel_acesso(
	id_nivel_acesso INT PRIMARY KEY AUTO_INCREMENT,
    nome_nivel_acesso VARCHAR(45) NOT NULL
);

INSERT INTO nivel_acesso(nome_nivel_acesso) VALUES
('GESTOR'),
('COORDENADOR'),
('ANALISTA'),
('TÉCNICO'),
('BIOTRACE');

-- USUARIO
-- Quem loga na aplicação web para ver o dashboard: sempre vinculado a uma empresa (fabricante) e a um nível de acesso
CREATE TABLE usuario(
	id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome_usuario VARCHAR(45) NOT NULL,
    dt_nasc_usuario DATE NOT NULL,
    telefone_usuario CHAR(11) NOT NULL,
    cpf_usuario CHAR(11) UNIQUE NOT NULL,
    email_usuario VARCHAR(100) UNIQUE NOT NULL,
    senha_usuario CHAR(8) NOT NULL,
    fk_empresa INT,
    fk_nivel_acesso INT NOT NULL,
    
    CONSTRAINT usuario_fk_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa),
    CONSTRAINT usuario_fk_nivel_acesso FOREIGN KEY (fk_nivel_acesso) REFERENCES nivel_acesso (id_nivel_acesso)
);

INSERT INTO usuario(nome_usuario, dt_nasc_usuario, telefone_usuario, cpf_usuario, email_usuario, senha_usuario, fk_empresa, fk_nivel_acesso) VALUES
('João Franca', '2007-11-16', '11985632587', '59845632285', 'joao@biotrace.com', '12345678', NULL, 5),
('Samara Lopes', '1999-09-06', '11956632011', '78963256600', 'samara@homed.com', '12345678', 1, 1);

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
('EDITAR_DADOS_EMPRESA', 'Editar dados cadastrais da empresa'),
('CADASTRAR_EMPRESA', 'Cadastrar novas empresas clientes da BioTrace'),
('CADASTRAR_GESTOR_EMPRESA', 'Cadastrar o primeiro gestor de uma empresa cliente'),
('GERENCIAR_EMPRESAS', 'Visualizar e editar empresas clientes da BioTrace');

CREATE TABLE permissoes_compartilhadas(
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
(4, 7),
(5, 8),
(5, 9),
(5, 10);

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
-- Agrupa equipamentos do mesmo modelo por fabricante. base para identificar padrões e para configurar os parâmetros de
-- alerta em escala (uma vez por modelo, não por equipamento)
CREATE TABLE modelo_equipamento(
    id_modelo_equipamento INT PRIMARY KEY AUTO_INCREMENT,
    nome_modelo VARCHAR(60) NOT NULL,
    fk_empresa INT NOT NULL,
    
    CONSTRAINT modelo_fk_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa)
);


-- COMPONENTE
-- centraliza os componentes que vai ser monitorados.
CREATE TABLE componente(
	id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome_componente VARCHAR(45) NOT NULL,
    codigo_componente VARCHAR(45) NOT NULL,
    tipo_medida VARCHAR(45) NOT NULL
);


-- EQUIPAMENTO
-- Cadastro do equipamento: nº de série, modelo, hospital onde está instalado no momento, status e última comunicação
CREATE TABLE equipamento(
    id_equipamento INT PRIMARY KEY AUTO_INCREMENT,
    numero_serie VARCHAR(60) NOT NULL UNIQUE,
    fk_modelo_equipamento INT NOT NULL,
    fk_hospital INT NOT NULL,
    
    CONSTRAINT equipamento_fk_modelo FOREIGN KEY (fk_modelo_equipamento) REFERENCES modelo_equipamento (id_modelo_equipamento),
    CONSTRAINT equipamento_fk_hospital FOREIGN KEY (fk_hospital) REFERENCES hospital (id_hospital)
);

-- Limites de CPU/RAM/disco (atenção / crítico) usados pela aplicação para decidir quando um dado lido do bucket vira alerta
CREATE TABLE parametro_alerta(
    id_parametro_alerta INT PRIMARY KEY AUTO_INCREMENT,
    limite_atencao DECIMAL(5,2) NOT NULL,
    limite_critico DECIMAL(5,2) NOT NULL,
    fk_componente INT NOT NULL,
    fk_equipamento INT NOT NULL,
    
    CONSTRAINT parametro_fk_componente FOREIGN KEY (fk_componente) REFERENCES componente(id_componente),
    CONSTRAINT parametro_fk_equipamento FOREIGN KEY (fk_equipamento) REFERENCES equipamento(id_equipamento)
);



SELECT
-- Dados da empresa que serão exibidos na tabela do painel interno
e.id_empresa,
e.razao_social,
e.cnpj,
e.telefone_comercial,
e.cep,
e.cidade,
e.logradouro,
e.bairro,
e.numero,

-- Verifica se existe um usuário gestor vinculado à empresa
-- Se existir, retorna true; caso contrário, retorna false
CASE
	WHEN
		u.id_usuario IS NOT NULL
	THEN true
	ELSE false
END AS temGestor,

-- Retorna o nome do gestor vinculado à empresa
-- Caso a empresa não tenha gestor, o valor será NULL
u.nome_usuario AS nomeGestor

FROM empresa e

-- LEFT JOIN tambem mostra aquelas empresas que ainda não possuem gestor
-- fk_nivel_acesso = 1 representa o nível de acesso GESTOR
LEFT JOIN usuario u ON u.fk_empresa = e.id_empresa AND u.fk_nivel_acesso = 1
ORDER BY e.id_empresa DESC;
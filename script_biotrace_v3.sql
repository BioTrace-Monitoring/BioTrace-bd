CREATE DATABASE IF NOT EXISTS biotrace;
USE biotrace;

CREATE TABLE permissao (
	codigo_permissao VARCHAR(15) NOT NULL PRIMARY KEY,
    nome_permissao VARCHAR(45) NOT NULL,
    descricao_permissao VARCHAR(100)
);

CREATE TABLE nivel_acesso (
    id_nivel_acesso INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome_nivel_acesso VARCHAR(45) NOT NULL
);

CREATE TABLE permissoes_compartilhadas (
    fk_nivel_acesso INT NOT NULL,
    fk_permissao VARCHAR(15) NOT NULL,
    PRIMARY KEY (fk_nivel_acesso, fk_permissao),
    CONSTRAINT fk_permissoes_nivel FOREIGN KEY (fk_nivel_acesso) REFERENCES nivel_acesso (id_nivel_acesso),
    CONSTRAINT fk_permissoes_permissao FOREIGN KEY (fk_permissao) REFERENCES permissao (codigo_permissao)
);

CREATE TABLE cargo (
	id_cargo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL
);

CREATE TABLE endereco (
    id_endereco INT NOT NULL AUTO_INCREMENT,
    cep CHAR(8),
    cidade VARCHAR(45),
    logradouro VARCHAR(45),
    bairro VARCHAR(45),
    numero VARCHAR(10),
    PRIMARY KEY (id_endereco)
);

CREATE TABLE empresa (
	id_empresa INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    telefone_comercial CHAR(11),
    fk_endereco INT,
    CONSTRAINT fk_empresa_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco)
);

CREATE TABLE usuario (
    id_usuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome_usuario VARCHAR(45) NOT NULL,
    dt_nasc_usuario DATE,
    telefone_usuario CHAR(11),
    cpf_usuario CHAR(11),
    email_usuario VARCHAR(100),
    senha_usuario VARCHAR(255),
    fk_empresa INT,
    fk_nivel_acesso INT,
    fk_cargo INT,
    CONSTRAINT fk_usuario_cargo FOREIGN KEY (fk_cargo) REFERENCES cargo (id_cargo),
    CONSTRAINT fk_usuario_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa),
    CONSTRAINT fk_usuario_nivel_acesso FOREIGN KEY (fk_nivel_acesso) REFERENCES nivel_acesso (id_nivel_acesso)
);

CREATE TABLE hospital (
    id_hospital INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome_hospital VARCHAR(100) NOT NULL,
    cnpj CHAR(14),
    fk_endereco INT,
    CONSTRAINT fk_hospital_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco (id_endereco)
);

CREATE TABLE modelo_equipamento (
    id_modelo_equipamento INT NOT NULL AUTO_INCREMENT,
    nome_modelo VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_modelo_equipamento)
);

CREATE TABLE lote_equipamento (
    id_lote_equipamento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numero_lote VARCHAR(60) NOT NULL,
    fk_empresa INT,
    fk_modelo_equipamento INT,
    CONSTRAINT fk_lote_empresa FOREIGN KEY (fk_empresa) REFERENCES empresa (id_empresa),
    CONSTRAINT fk_lote_modelo FOREIGN KEY (fk_modelo_equipamento) REFERENCES modelo_equipamento (id_modelo_equipamento)
);

CREATE TABLE equipamento (
    id_equipamento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    numero_serie VARCHAR(60) NOT NULL,
    fk_hospital INT,
    fk_lote INT,
    CONSTRAINT fk_equipamento_hospital FOREIGN KEY (fk_hospital) REFERENCES hospital (id_hospital),
    CONSTRAINT fk_equipamento_lote FOREIGN KEY (fk_lote) REFERENCES lote_equipamento (id_lote_equipamento)
);

CREATE TABLE tipo_componente (
    id_tipo_componente INT NOT NULL AUTO_INCREMENT,
    nome_componente VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_tipo_componente)
);

CREATE TABLE componente (
    id_componente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_equipamento INT,
    fk_tipo_componente INT,
    CONSTRAINT fk_componente_equipamento FOREIGN KEY (fk_equipamento) REFERENCES equipamento (id_equipamento),
    CONSTRAINT fk_componente_tipo FOREIGN KEY (fk_tipo_componente) REFERENCES tipo_componente (id_tipo_componente)
);

CREATE TABLE tipo_metrica (
    id_tipo_metrica INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tipo_metrica VARCHAR(45) NOT NULL
);

CREATE TABLE metrica (
    id_metrica INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fk_tipo_metrica INT,
    fk_componente INT,
    CONSTRAINT fk_metrica_tipo FOREIGN KEY (fk_tipo_metrica) REFERENCES tipo_metrica (id_tipo_metrica),
    CONSTRAINT fk_metrica_componente FOREIGN KEY (fk_componente) REFERENCES componente (id_componente)
);

CREATE TABLE parametro_metrica (
    id_parametro_alerta INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    limite_uso DECIMAL(5,2),
    limite_ociosidade DECIMAL(5,2),
    habilitado TINYINT,
    fk_metrica INT,
    CONSTRAINT fk_parametro_metrica FOREIGN KEY (fk_metrica) REFERENCES metrica (id_metrica)
);


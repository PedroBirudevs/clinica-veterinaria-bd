-- =============================================================================
-- V001 - Tabela PESSOA (entidade generalizada)
-- =============================================================================
-- Guarda os atributos comuns a qualquer pessoa fisica do sistema.
-- As especializacoes (cliente, atendente, veterinario) herdam desta tabela
-- atraves de chave primaria que tambem e chave estrangeira.
--
-- Justificativa da modelagem:
-- O enunciado exige que "atendentes tambem podem ser clientes". Se cliente e
-- atendente fossem tabelas independentes, o CPF e o nome seriam duplicados,
-- violando a 2FN e permitindo divergencia de dados. Com a generalizacao, a
-- mesma pessoa aparece uma unica vez em PESSOA e pode ter linhas em quantas
-- especializacoes forem necessarias (especializacao parcial e sobreposta).
-- =============================================================================

CREATE TABLE IF NOT EXISTS pessoa (
    id_pessoa        INTEGER      GENERATED ALWAYS AS IDENTITY,
    cpf              CHAR(11)     NOT NULL,
    nome             VARCHAR(60)  NOT NULL,
    sobrenome        VARCHAR(80)  NOT NULL,
    email            VARCHAR(120) NOT NULL,
    telefone         VARCHAR(15),
    data_nascimento  DATE         NOT NULL,
    criado_em        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_pessoa
        PRIMARY KEY (id_pessoa),

    CONSTRAINT uq_pessoa_cpf
        UNIQUE (cpf),

    CONSTRAINT uq_pessoa_email
        UNIQUE (email),

    -- CPF deve conter exatamente 11 digitos numericos
    CONSTRAINT ck_pessoa_cpf_formato
        CHECK (cpf ~ '^[0-9]{11}$'),

    -- Formato minimo de e-mail valido
    CONSTRAINT ck_pessoa_email_formato
        CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[a-zA-Z]{2,}$'),

    -- Ninguem nasce no futuro e ninguem vive mais de 120 anos
    CONSTRAINT ck_pessoa_data_nascimento
        CHECK (data_nascimento <= CURRENT_DATE
           AND data_nascimento >= CURRENT_DATE - INTERVAL '120 years'),

    CONSTRAINT ck_pessoa_nome_nao_vazio
        CHECK (length(trim(nome)) > 0 AND length(trim(sobrenome)) > 0)
);

COMMENT ON TABLE  pessoa                 IS 'Entidade generalizada: dados comuns de toda pessoa fisica do sistema';
COMMENT ON COLUMN pessoa.cpf             IS 'CPF somente digitos, sem pontuacao';
COMMENT ON COLUMN pessoa.data_nascimento IS 'Usada para calcular idade em relatorios';

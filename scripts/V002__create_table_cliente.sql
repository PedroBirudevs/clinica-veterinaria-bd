-- =============================================================================
-- V002 - Tabela CLIENTE (especializacao de PESSOA)
-- =============================================================================
-- Um cliente e o tutor responsavel pelos animais atendidos na clinica.
-- A PK e tambem FK para pessoa: garante relacionamento 1:1 e dependencia
-- de existencia (nao existe cliente sem a pessoa correspondente).
--
-- ON DELETE CASCADE: se a pessoa for removida do sistema, sua condicao de
-- cliente deixa de existir junto.
-- =============================================================================

CREATE TABLE IF NOT EXISTS cliente (
    id_pessoa     INTEGER      NOT NULL,
    logradouro    VARCHAR(120) NOT NULL,
    numero        VARCHAR(10)  NOT NULL,
    complemento   VARCHAR(60),
    bairro        VARCHAR(60)  NOT NULL,
    cidade        VARCHAR(60)  NOT NULL,
    uf            CHAR(2)      NOT NULL,
    cep           CHAR(8)      NOT NULL,
    banco         VARCHAR(60),
    agencia       VARCHAR(10),
    conta         VARCHAR(20),
    tipo_conta    VARCHAR(10),
    chave_pix     VARCHAR(120),
    cliente_desde DATE         NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT pk_cliente
        PRIMARY KEY (id_pessoa),

    CONSTRAINT fk_cliente_pessoa
        FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT ck_cliente_uf
        CHECK (uf IN ('AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT',
                      'MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO',
                      'RR','SC','SP','SE','TO')),

    CONSTRAINT ck_cliente_cep_formato
        CHECK (cep ~ '^[0-9]{8}$'),

    CONSTRAINT ck_cliente_tipo_conta
        CHECK (tipo_conta IS NULL OR tipo_conta IN ('CORRENTE','POUPANCA')),

    -- Regra de negocio: se informar dados bancarios, informe o conjunto todo
    CONSTRAINT ck_cliente_dados_bancarios_completos
        CHECK (
            (banco IS NULL AND agencia IS NULL AND conta IS NULL AND tipo_conta IS NULL)
            OR
            (banco IS NOT NULL AND agencia IS NOT NULL AND conta IS NOT NULL AND tipo_conta IS NOT NULL)
        )
);

COMMENT ON TABLE  cliente           IS 'Especializacao de pessoa: tutor responsavel por animais';
COMMENT ON COLUMN cliente.id_pessoa IS 'PK e FK simultaneamente - garante 1:1 com pessoa';
COMMENT ON CONSTRAINT ck_cliente_dados_bancarios_completos ON cliente
    IS 'Evita cadastro bancario pela metade, que inviabilizaria reembolso';

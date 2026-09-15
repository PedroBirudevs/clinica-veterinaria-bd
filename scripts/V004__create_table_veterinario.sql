-- =============================================================================
-- V004 - Tabela VETERINARIO (especializacao de PESSOA)
-- =============================================================================
-- Profissional responsavel tecnico pela consulta.
-- O CRMV e o registro no Conselho Regional de Medicina Veterinaria e, por
-- ser unico por profissional, recebe restricao UNIQUE.
-- =============================================================================

CREATE TABLE IF NOT EXISTS veterinario (
    id_pessoa       INTEGER      NOT NULL,
    crmv            VARCHAR(15)  NOT NULL,
    especialidade   VARCHAR(60)  NOT NULL,
    data_formatura  DATE,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_veterinario
        PRIMARY KEY (id_pessoa),

    CONSTRAINT fk_veterinario_pessoa
        FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_veterinario_crmv
        UNIQUE (crmv),

    CONSTRAINT ck_veterinario_especialidade_nao_vazia
        CHECK (length(trim(especialidade)) > 0),

    CONSTRAINT ck_veterinario_formatura_passado
        CHECK (data_formatura IS NULL OR data_formatura <= CURRENT_DATE)
);

COMMENT ON TABLE  veterinario       IS 'Especializacao de pessoa: responsavel tecnico pelas consultas';
COMMENT ON COLUMN veterinario.crmv  IS 'Registro no Conselho Regional de Medicina Veterinaria';
COMMENT ON COLUMN veterinario.ativo IS 'Permite inativar sem apagar o historico de atendimentos';

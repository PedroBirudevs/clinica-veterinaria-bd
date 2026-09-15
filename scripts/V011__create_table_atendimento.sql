-- =============================================================================
-- V011 - Tabela ATENDIMENTO
-- =============================================================================
-- Entidade central do sistema. Atende integralmente o requisito:
-- "registrar a data, o atendente, o cliente (tutor), o animal, o veterinario
-- responsavel, um descritivo da consulta".
--
-- Note que id_cliente aparece aqui mesmo sendo derivavel de animal.id_cliente.
-- Isso e intencional e NAO e redundancia indevida: o tutor pode transferir o
-- animal para outra pessoa no futuro, e o atendimento precisa preservar quem
-- era o responsavel NA DATA do atendimento (dado historico).
-- A coerencia entre os dois no momento do registro e garantida pelo trigger
-- de V021.
--
-- ON DELETE RESTRICT em todas as FKs: atendimento e registro contabil e
-- clinico, nao pode ser perdido por exclusao em cascata.
-- =============================================================================

CREATE TABLE IF NOT EXISTS atendimento (
    id_atendimento  INTEGER      GENERATED ALWAYS AS IDENTITY,
    data_hora       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_atendente    INTEGER      NOT NULL,
    id_cliente      INTEGER      NOT NULL,
    id_animal       INTEGER      NOT NULL,
    id_veterinario  INTEGER,
    descritivo      TEXT         NOT NULL,
    diagnostico     TEXT,
    status          VARCHAR(12)  NOT NULL DEFAULT 'ABERTO',
    desconto        NUMERIC(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT pk_atendimento
        PRIMARY KEY (id_atendimento),

    CONSTRAINT fk_atendimento_atendente
        FOREIGN KEY (id_atendente) REFERENCES atendente (id_pessoa)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_atendimento_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_pessoa)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_atendimento_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- Veterinario opcional: banho e tosa nao exigem responsavel tecnico
    CONSTRAINT fk_atendimento_veterinario
        FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_pessoa)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_atendimento_status
        CHECK (status IN ('ABERTO','CONCLUIDO','CANCELADO')),

    CONSTRAINT ck_atendimento_descritivo_nao_vazio
        CHECK (length(trim(descritivo)) > 0),

    CONSTRAINT ck_atendimento_desconto
        CHECK (desconto >= 0),

    -- Nao se registra atendimento com data futura
    CONSTRAINT ck_atendimento_data_nao_futura
        CHECK (data_hora <= CURRENT_TIMESTAMP + INTERVAL '1 day')
);

COMMENT ON TABLE  atendimento                IS 'Entidade central: consulta realizada na clinica';
COMMENT ON COLUMN atendimento.id_cliente     IS 'Tutor na data do atendimento - preservado para historico';
COMMENT ON COLUMN atendimento.id_veterinario IS 'NULL quando o servico nao exige responsavel tecnico';

-- =============================================================================
-- V013 - Tabela ATENDIMENTO_SERVICO (associativa N:N)
-- =============================================================================
-- Mesma logica de V012, aplicada aos servicos.
-- Guarda tambem qual veterinario executou cada procedimento, que pode ser
-- diferente do responsavel geral pelo atendimento (ex: consulta com um
-- clinico e exame de imagem com outro profissional).
-- =============================================================================

CREATE TABLE IF NOT EXISTS atendimento_servico (
    id_atendimento  INTEGER       NOT NULL,
    id_servico      INTEGER       NOT NULL,
    quantidade      INTEGER       NOT NULL DEFAULT 1,
    valor_unitario  NUMERIC(10,2) NOT NULL,
    id_executante   INTEGER,
    observacao      TEXT,

    CONSTRAINT pk_atendimento_servico
        PRIMARY KEY (id_atendimento, id_servico),

    CONSTRAINT fk_atend_servico_atendimento
        FOREIGN KEY (id_atendimento) REFERENCES atendimento (id_atendimento)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_atend_servico_servico
        FOREIGN KEY (id_servico) REFERENCES servico (id_servico)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_atend_servico_executante
        FOREIGN KEY (id_executante) REFERENCES veterinario (id_pessoa)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_atend_servico_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_atend_servico_valor
        CHECK (valor_unitario >= 0)
);

COMMENT ON COLUMN atendimento_servico.id_executante
    IS 'Veterinario que executou este procedimento especifico';

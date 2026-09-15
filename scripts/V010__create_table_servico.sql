-- =============================================================================
-- V010 - Tabela SERVICO
-- =============================================================================
-- Procedimento realizado no atendimento (consulta, banho, cirurgia, exame).
-- Diferente de produto: nao tem estoque nem valor de compra, apenas um valor
-- de tabela que pode ser ajustado caso a caso no atendimento.
-- =============================================================================

CREATE TABLE IF NOT EXISTS servico (
    id_servico          INTEGER       GENERATED ALWAYS AS IDENTITY,
    nome                VARCHAR(80)   NOT NULL,
    descricao           TEXT,
    valor_padrao        NUMERIC(10,2) NOT NULL,
    duracao_minutos     INTEGER,
    exige_veterinario   BOOLEAN       NOT NULL DEFAULT TRUE,
    ativo               BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_servico
        PRIMARY KEY (id_servico),

    CONSTRAINT uq_servico_nome
        UNIQUE (nome),

    CONSTRAINT ck_servico_valor_padrao
        CHECK (valor_padrao >= 0),

    CONSTRAINT ck_servico_duracao
        CHECK (duracao_minutos IS NULL OR (duracao_minutos > 0 AND duracao_minutos <= 600))
);

COMMENT ON COLUMN servico.exige_veterinario
    IS 'FALSE para banho e tosa, que podem ser feitos sem responsavel tecnico';

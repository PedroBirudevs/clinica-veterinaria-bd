-- =============================================================================
-- V007 - Tabela TIPO_PRODUTO
-- =============================================================================
-- Normaliza o campo "tipo" exigido no enunciado do produto.
-- =============================================================================

CREATE TABLE IF NOT EXISTS tipo_produto (
    id_tipo_produto     INTEGER     GENERATED ALWAYS AS IDENTITY,
    nome                VARCHAR(40) NOT NULL,
    exige_receita       BOOLEAN     NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_tipo_produto
        PRIMARY KEY (id_tipo_produto),

    CONSTRAINT uq_tipo_produto_nome
        UNIQUE (nome)
);

COMMENT ON COLUMN tipo_produto.exige_receita
    IS 'Medicamentos controlados exigem receita do veterinario';

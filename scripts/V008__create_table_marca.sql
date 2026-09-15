-- =============================================================================
-- V008 - Tabela MARCA
-- =============================================================================
-- Normaliza o campo "marca" exigido no enunciado do produto.
-- =============================================================================

CREATE TABLE IF NOT EXISTS marca (
    id_marca  INTEGER     GENERATED ALWAYS AS IDENTITY,
    nome      VARCHAR(60) NOT NULL,
    fabricante VARCHAR(80),

    CONSTRAINT pk_marca
        PRIMARY KEY (id_marca),

    CONSTRAINT uq_marca_nome
        UNIQUE (nome)
);

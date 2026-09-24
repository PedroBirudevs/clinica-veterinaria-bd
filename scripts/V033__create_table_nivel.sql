-- =============================================================================
-- V033 - Tabela NIVEL (Inovacao: programa de fidelidade)
-- =============================================================================
-- Faixas do programa de fidelidade. O cliente esta no maior nivel cujo
-- pontos_minimos ele ja alcancou (ex.: Bronze 0, Prata 50, Ouro 150).
-- =============================================================================

CREATE TABLE IF NOT EXISTS nivel (
    id_nivel        INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome            VARCHAR(30)  NOT NULL,
    pontos_minimos  INTEGER      NOT NULL,

    CONSTRAINT pk_nivel
        PRIMARY KEY (id_nivel),

    CONSTRAINT uq_nivel_nome
        UNIQUE (nome),

    CONSTRAINT uq_nivel_pontos_minimos
        UNIQUE (pontos_minimos),

    CONSTRAINT ck_nivel_pontos_minimos
        CHECK (pontos_minimos >= 0)
);

COMMENT ON TABLE nivel IS 'Faixas do programa de fidelidade (Bronze, Prata, Ouro)';

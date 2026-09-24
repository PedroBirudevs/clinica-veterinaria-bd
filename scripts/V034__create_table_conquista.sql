-- =============================================================================
-- V034 - Tabela CONQUISTA (Inovacao: programa de fidelidade)
-- =============================================================================
-- Medalhas que o cliente desbloqueia. Cada conquista rende pontos extras.
-- =============================================================================

CREATE TABLE IF NOT EXISTS conquista (
    id_conquista    INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome            VARCHAR(60)  NOT NULL,
    descricao       TEXT         NOT NULL,
    pontos_bonus    INTEGER      NOT NULL DEFAULT 0,

    CONSTRAINT pk_conquista
        PRIMARY KEY (id_conquista),

    CONSTRAINT uq_conquista_nome
        UNIQUE (nome),

    CONSTRAINT ck_conquista_pontos_bonus
        CHECK (pontos_bonus >= 0)
);

COMMENT ON TABLE conquista IS 'Conquistas (medalhas) do programa de fidelidade';

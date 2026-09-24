-- =============================================================================
-- V036 - Tabela CLIENTE_CONQUISTA (Inovacao: programa de fidelidade)
-- =============================================================================
-- Associativa N:N: quais conquistas cada cliente ja desbloqueou.
-- A PK composta impede ganhar a mesma conquista duas vezes.
-- =============================================================================

CREATE TABLE IF NOT EXISTS cliente_conquista (
    id_cliente      INTEGER      NOT NULL,
    id_conquista    INTEGER      NOT NULL,
    obtida_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_cliente_conquista
        PRIMARY KEY (id_cliente, id_conquista),

    CONSTRAINT fk_cliente_conquista_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_cliente_conquista_conquista
        FOREIGN KEY (id_conquista) REFERENCES conquista (id_conquista)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE cliente_conquista IS 'Conquistas desbloqueadas por cada cliente';

-- =============================================================================
-- V035 - Tabela PONTUACAO (Inovacao: programa de fidelidade)
-- =============================================================================
-- Extrato de pontos do cliente. Cada linha e um credito:
--   - por atendimento (id_atendimento preenchido)
--   - por conquista ou bonus avulso (id_atendimento nulo)
-- O saldo do cliente e a soma dos pontos (ver V037).
-- =============================================================================

CREATE TABLE IF NOT EXISTS pontuacao (
    id_pontuacao    INTEGER      GENERATED ALWAYS AS IDENTITY,
    id_cliente      INTEGER      NOT NULL,
    id_atendimento  INTEGER,
    pontos          INTEGER      NOT NULL,
    motivo          VARCHAR(80)  NOT NULL,
    registrado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_pontuacao
        PRIMARY KEY (id_pontuacao),

    CONSTRAINT fk_pontuacao_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_pontuacao_atendimento
        FOREIGN KEY (id_atendimento) REFERENCES atendimento (id_atendimento)
        ON DELETE SET NULL ON UPDATE CASCADE,

    CONSTRAINT ck_pontuacao_pontos
        CHECK (pontos <> 0)
);

COMMENT ON TABLE  pontuacao                IS 'Extrato de pontos do programa de fidelidade';
COMMENT ON COLUMN pontuacao.id_atendimento IS 'NULL quando o ponto vem de conquista ou bonus';

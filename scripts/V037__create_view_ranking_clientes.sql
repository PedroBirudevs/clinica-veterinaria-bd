-- =============================================================================
-- V037 - VISAO vw_ranking_clientes (Inovacao: programa de fidelidade)
-- =============================================================================
-- Ranking dos clientes por total de pontos, com o nivel atual de cada um.
-- Clientes sem pontos aparecem com 0, no nivel inicial.
-- =============================================================================

CREATE OR REPLACE VIEW vw_ranking_clientes AS
WITH totais AS (
    SELECT
        c.id_pessoa                          AS id_cliente,
        p.nome || ' ' || p.sobrenome         AS cliente,
        COALESCE(SUM(pt.pontos), 0)::INTEGER AS total_pontos
    FROM cliente        c
    JOIN pessoa         p  ON p.id_pessoa   = c.id_pessoa
    LEFT JOIN pontuacao pt ON pt.id_cliente = c.id_pessoa
    GROUP BY c.id_pessoa, p.nome, p.sobrenome
)
SELECT
    RANK() OVER (ORDER BY t.total_pontos DESC) AS posicao,
    t.id_cliente,
    t.cliente,
    t.total_pontos,
    (SELECT n.nome
       FROM nivel n
      WHERE n.pontos_minimos <= t.total_pontos
      ORDER BY n.pontos_minimos DESC
      LIMIT 1)                               AS nivel_atual
FROM totais t
ORDER BY posicao, t.cliente;

COMMENT ON VIEW vw_ranking_clientes
    IS 'Ranking do programa de fidelidade: posicao, pontos e nivel atual';

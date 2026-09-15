-- =============================================================================
-- V023 - VISAO vw_faturamento_por_mes
-- =============================================================================
-- Visao analitica para a gestao: receita mensal separada entre produtos e
-- servicos, com a margem obtida sobre os produtos vendidos.
--
-- Atendimentos CANCELADOS sao excluidos - nao geram receita.
-- =============================================================================

CREATE OR REPLACE VIEW vw_faturamento_por_mes AS
WITH receita_produtos AS (
    SELECT
        date_trunc('month', at.data_hora)::DATE          AS mes,
        ROUND(SUM(ap.quantidade * ap.valor_unitario), 2)  AS total_produtos,
        ROUND(SUM(ap.quantidade * (ap.valor_unitario - p.valor_compra)), 2) AS margem_produtos
    FROM atendimento         at
    JOIN atendimento_produto ap ON ap.id_atendimento = at.id_atendimento
    JOIN produto             p  ON p.id_produto      = ap.id_produto
    WHERE at.status <> 'CANCELADO'
    GROUP BY date_trunc('month', at.data_hora)
),
receita_servicos AS (
    SELECT
        date_trunc('month', at.data_hora)::DATE          AS mes,
        ROUND(SUM(asv.quantidade * asv.valor_unitario), 2) AS total_servicos
    FROM atendimento         at
    JOIN atendimento_servico asv ON asv.id_atendimento = at.id_atendimento
    WHERE at.status <> 'CANCELADO'
    GROUP BY date_trunc('month', at.data_hora)
),
volume AS (
    SELECT
        date_trunc('month', data_hora)::DATE             AS mes,
        COUNT(*)                                         AS qtd_atendimentos,
        COUNT(DISTINCT id_cliente)                       AS clientes_distintos,
        SUM(desconto)                                    AS total_descontos
    FROM atendimento
    WHERE status <> 'CANCELADO'
    GROUP BY date_trunc('month', data_hora)
)
SELECT
    v.mes,
    v.qtd_atendimentos,
    v.clientes_distintos,
    COALESCE(rp.total_produtos, 0)                       AS receita_produtos,
    COALESCE(rs.total_servicos, 0)                       AS receita_servicos,
    v.total_descontos,
    COALESCE(rp.total_produtos, 0)
        + COALESCE(rs.total_servicos, 0)
        - v.total_descontos                              AS receita_liquida,
    COALESCE(rp.margem_produtos, 0)                      AS margem_produtos,
    ROUND(
        (COALESCE(rp.total_produtos, 0) + COALESCE(rs.total_servicos, 0)
         - v.total_descontos) / NULLIF(v.qtd_atendimentos, 0)
    , 2)                                                 AS ticket_medio
FROM volume v
LEFT JOIN receita_produtos rp ON rp.mes = v.mes
LEFT JOIN receita_servicos rs ON rs.mes = v.mes
ORDER BY v.mes DESC;

COMMENT ON VIEW vw_faturamento_por_mes
    IS 'Visao gerencial: receita, margem e ticket medio por mes';

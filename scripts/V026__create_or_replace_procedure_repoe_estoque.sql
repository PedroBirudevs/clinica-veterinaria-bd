-- =============================================================================
-- V026 - PROCEDIMENTO repoe_estoque
-- =============================================================================
-- Entrada de mercadoria. Alem de somar ao estoque, atualiza o valor de compra
-- pela media ponderada - assim o calculo de margem em V023 continua honesto
-- quando o fornecedor reajusta o preco.
-- =============================================================================

CREATE OR REPLACE PROCEDURE repoe_estoque(
    p_id_produto        INTEGER,
    p_quantidade        INTEGER,
    p_valor_compra_novo NUMERIC DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estoque_atual INTEGER;
    v_valor_atual   NUMERIC(10,2);
    v_valor_medio   NUMERIC(10,2);
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'A quantidade reposta deve ser positiva (recebido: %)', p_quantidade;
    END IF;

    SELECT estoque_atual, valor_compra
      INTO v_estoque_atual, v_valor_atual
      FROM produto
     WHERE id_produto = p_id_produto
       FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto % nao encontrado', p_id_produto;
    END IF;

    IF p_valor_compra_novo IS NULL THEN
        UPDATE produto
           SET estoque_atual = estoque_atual + p_quantidade
         WHERE id_produto = p_id_produto;
    ELSE
        -- Media ponderada entre o saldo antigo e a entrada nova
        v_valor_medio := (
            (v_estoque_atual * v_valor_atual) + (p_quantidade * p_valor_compra_novo)
        ) / NULLIF(v_estoque_atual + p_quantidade, 0);

        UPDATE produto
           SET estoque_atual = estoque_atual + p_quantidade,
               valor_compra  = ROUND(v_valor_medio, 2),
               -- Mantem a restricao de margem nao negativa (V009) coerente
               valor_venda   = GREATEST(valor_venda, ROUND(v_valor_medio, 2))
         WHERE id_produto = p_id_produto;
    END IF;

    RAISE NOTICE 'Estoque do produto % reposto: % -> %',
        p_id_produto, v_estoque_atual, v_estoque_atual + p_quantidade;
END;
$$;

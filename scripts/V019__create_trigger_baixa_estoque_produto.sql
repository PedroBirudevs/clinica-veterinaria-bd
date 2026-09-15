-- =============================================================================
-- V019 - TRIGGER de baixa automatica de estoque
-- =============================================================================
-- Sempre que um produto e lancado num atendimento, o estoque cai.
-- Se o item for removido ou o atendimento cancelado, o estoque volta.
--
-- Trata os tres eventos (INSERT, UPDATE, DELETE) porque o usuario pode
-- corrigir a quantidade depois de lancada - nesse caso ajusta apenas a
-- diferenca, nao o valor cheio.
--
-- A restricao ck_produto_estoque_nao_negativo (V009) atua como segunda linha
-- de defesa: mesmo que a logica aqui falhe, o banco recusa estoque negativo.
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_baixa_estoque_produto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_delta          NUMERIC(8,3);
    v_estoque_atual  INTEGER;
    v_descricao      VARCHAR(120);
BEGIN
    -- Determina quanto sai (positivo) ou volta (negativo) do estoque
    IF TG_OP = 'INSERT' THEN
        v_delta := NEW.quantidade;
    ELSIF TG_OP = 'UPDATE' THEN
        v_delta := NEW.quantidade - OLD.quantidade;
    ELSE  -- DELETE
        v_delta := -OLD.quantidade;
    END IF;

    -- Conferencia de disponibilidade apenas quando ha saida
    IF v_delta > 0 THEN
        SELECT estoque_atual, descricao
          INTO v_estoque_atual, v_descricao
          FROM produto
         WHERE id_produto = COALESCE(NEW.id_produto, OLD.id_produto)
           FOR UPDATE;   -- bloqueia a linha e evita condicao de corrida

        IF v_estoque_atual < v_delta THEN
            RAISE EXCEPTION
                'Estoque insuficiente para "%": disponivel %, solicitado %',
                v_descricao, v_estoque_atual, v_delta
                USING HINT = 'Reponha o estoque antes de lancar este item';
        END IF;
    END IF;

    UPDATE produto
       SET estoque_atual = estoque_atual - v_delta
     WHERE id_produto = COALESCE(NEW.id_produto, OLD.id_produto);

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_baixa_estoque_produto ON atendimento_produto;

CREATE TRIGGER tg_baixa_estoque_produto
    AFTER INSERT OR UPDATE OF quantidade OR DELETE ON atendimento_produto
    FOR EACH ROW
    EXECUTE FUNCTION fn_baixa_estoque_produto();

COMMENT ON FUNCTION fn_baixa_estoque_produto()
    IS 'Mantem produto.estoque_atual sincronizado com os itens lancados nos atendimentos';

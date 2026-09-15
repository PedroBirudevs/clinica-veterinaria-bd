-- =============================================================================
-- V016 - FUNCAO calcula_total_atendimento
-- =============================================================================
-- Centraliza a regra de calculo do valor total de um atendimento:
--     soma dos produtos + soma dos servicos - desconto
--
-- Por que funcao e nao calculo na aplicacao: a regra fica junto do dado.
-- Qualquer sistema que acesse o banco (relatorio, app, BI) obtem o mesmo
-- resultado, sem risco de duas implementacoes divergirem.
--
-- COALESCE trata o caso de atendimento sem itens, em que SUM() retorna NULL.
--
-- A funcao e declarada STRICT (RETURNS NULL ON NULL INPUT) porque as visoes
-- que usam LEFT JOIN podem passar NULL quando o animal ainda nao tem nenhum
-- atendimento. Sem STRICT, a funcao entraria no corpo, nao encontraria o
-- registro e lancaria excecao, derrubando a consulta inteira. Com STRICT, o
-- PostgreSQL devolve NULL sem executar o corpo, e o SUM() da visao ignora.
-- =============================================================================

CREATE OR REPLACE FUNCTION calcula_total_atendimento(p_id_atendimento INTEGER)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
STABLE
STRICT              -- retorna NULL se o parametro for NULL, sem executar o corpo
AS $$
DECLARE
    v_total_produtos NUMERIC(10,2);
    v_total_servicos NUMERIC(10,2);
    v_desconto       NUMERIC(10,2);
    v_total          NUMERIC(10,2);
BEGIN
    -- Valida a existencia do atendimento antes de calcular
    SELECT desconto INTO v_desconto
      FROM atendimento
     WHERE id_atendimento = p_id_atendimento;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Atendimento % nao encontrado', p_id_atendimento
            USING ERRCODE = 'no_data_found';
    END IF;

    SELECT COALESCE(SUM(quantidade * valor_unitario), 0)
      INTO v_total_produtos
      FROM atendimento_produto
     WHERE id_atendimento = p_id_atendimento;

    SELECT COALESCE(SUM(quantidade * valor_unitario), 0)
      INTO v_total_servicos
      FROM atendimento_servico
     WHERE id_atendimento = p_id_atendimento;

    v_total := v_total_produtos + v_total_servicos - v_desconto;

    -- O desconto nunca pode tornar a conta negativa
    IF v_total < 0 THEN
        v_total := 0;
    END IF;

    RETURN v_total;
END;
$$;

COMMENT ON FUNCTION calcula_total_atendimento(INTEGER)
    IS 'Retorna o valor final do atendimento: produtos + servicos - desconto';

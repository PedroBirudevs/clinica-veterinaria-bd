-- =============================================================================
-- V025 - PROCEDIMENTO registra_atendimento_completo
-- =============================================================================
-- Encapsula numa unica transacao o registro de um atendimento com seus itens.
--
-- Por que procedure e nao varios INSERTs soltos: atomicidade. Se o estoque de
-- um dos produtos for insuficiente, a excecao do trigger desfaz TUDO - nao
-- fica atendimento pela metade no banco. E a propriedade A do ACID em uso.
--
-- Os arrays permitem lancar varios produtos e servicos de uma vez.
--
-- ATENCAO AO CHAMAR: o PostgreSQL NAO aceita subconsulta como argumento de
-- CALL. Isto falha:
--     CALL registra_atendimento_completo((SELECT id_pessoa FROM ...), ...);
--     ERROR: cannot use subquery in CALL argument
-- Resolva os valores em variaveis antes, dentro de um bloco DO ou na
-- aplicacao. Ha um exemplo completo em testes/teste_procedures.sql.
-- =============================================================================

CREATE OR REPLACE PROCEDURE registra_atendimento_completo(
    p_id_atendente     INTEGER,
    p_id_cliente       INTEGER,
    p_id_animal        INTEGER,
    p_id_veterinario   INTEGER,
    p_descritivo       TEXT,
    p_produtos         INTEGER[] DEFAULT NULL,  -- ids dos produtos
    p_qtd_produtos     NUMERIC[] DEFAULT NULL,  -- quantidades correspondentes
    p_servicos         INTEGER[] DEFAULT NULL,  -- ids dos servicos
    p_desconto         NUMERIC   DEFAULT 0,
    INOUT p_id_gerado  INTEGER   DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    i               INTEGER;
    v_valor_venda   NUMERIC(10,2);
    v_valor_servico NUMERIC(10,2);
BEGIN
    -- Coerencia entre os dois arrays de produto
    IF p_produtos IS NOT NULL THEN
        IF p_qtd_produtos IS NULL
           OR array_length(p_produtos, 1) <> array_length(p_qtd_produtos, 1) THEN
            RAISE EXCEPTION
                'A lista de produtos e a de quantidades devem ter o mesmo tamanho';
        END IF;
    END IF;

    -- 1. Cabecalho do atendimento
    --    O trigger de V018 valida aqui se o animal pertence ao cliente
    INSERT INTO atendimento (
        id_atendente, id_cliente, id_animal, id_veterinario, descritivo, desconto
    )
    VALUES (
        p_id_atendente, p_id_cliente, p_id_animal, p_id_veterinario,
        p_descritivo, COALESCE(p_desconto, 0)
    )
    RETURNING id_atendimento INTO p_id_gerado;

    -- 2. Produtos: o valor vem da tabela no momento do lancamento
    IF p_produtos IS NOT NULL THEN
        FOR i IN 1 .. array_length(p_produtos, 1) LOOP
            SELECT valor_venda INTO v_valor_venda
              FROM produto
             WHERE id_produto = p_produtos[i] AND ativo = TRUE;

            IF NOT FOUND THEN
                RAISE EXCEPTION 'Produto % nao existe ou esta inativo', p_produtos[i];
            END IF;

            -- O trigger de V019 faz a baixa de estoque e barra falta de saldo
            INSERT INTO atendimento_produto (
                id_atendimento, id_produto, quantidade, valor_unitario
            )
            VALUES (p_id_gerado, p_produtos[i], p_qtd_produtos[i], v_valor_venda);
        END LOOP;
    END IF;

    -- 3. Servicos
    IF p_servicos IS NOT NULL THEN
        FOR i IN 1 .. array_length(p_servicos, 1) LOOP
            SELECT valor_padrao INTO v_valor_servico
              FROM servico
             WHERE id_servico = p_servicos[i] AND ativo = TRUE;

            IF NOT FOUND THEN
                RAISE EXCEPTION 'Servico % nao existe ou esta inativo', p_servicos[i];
            END IF;

            INSERT INTO atendimento_servico (
                id_atendimento, id_servico, quantidade, valor_unitario, id_executante
            )
            VALUES (p_id_gerado, p_servicos[i], 1, v_valor_servico, p_id_veterinario);
        END LOOP;
    END IF;

    RAISE NOTICE 'Atendimento % registrado. Valor total: R$ %',
        p_id_gerado, calcula_total_atendimento(p_id_gerado);
END;
$$;

COMMENT ON PROCEDURE registra_atendimento_completo
    IS 'Registra atendimento e itens em transacao unica - tudo entra ou nada entra';

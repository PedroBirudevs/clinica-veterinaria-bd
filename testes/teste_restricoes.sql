-- =============================================================================
-- TESTE DE RESTRICOES DE INTEGRIDADE
-- =============================================================================
-- Cada bloco tenta gravar um dado INVALIDO de proposito. O resultado esperado
-- e que TODOS falhem: e assim que se comprova que as restricoes funcionam.
--
-- Executar com:  psql -d clinica_vet -f testes/teste_restricoes.sql
--
-- Cada teste fica dentro de um bloco que captura a excecao e imprime o
-- resultado, para que um teste que falhe nao interrompa os seguintes.
-- =============================================================================

\pset border 2
\echo '======================================================================'
\echo ' BATERIA DE TESTES - cada linha deve mostrar BLOQUEADO'
\echo '======================================================================'

DO $$
DECLARE
    v_msg TEXT;
BEGIN
    ------------------------------------------------------------------ TESTE 1
    BEGIN
        INSERT INTO pessoa (cpf, nome, sobrenome, email, data_nascimento)
        VALUES ('123', 'CPF', 'Invalido', 'cpf@teste.com', '1990-01-01');
        RAISE WARNING 'FALHOU  | 1. CPF com 3 digitos foi aceito';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 1. CPF fora do formato de 11 digitos';
    END;

    ------------------------------------------------------------------ TESTE 2
    BEGIN
        INSERT INTO pessoa (cpf, nome, sobrenome, email, data_nascimento)
        VALUES ('11122233344', 'CPF', 'Duplicado', 'outro@teste.com', '1990-01-01');
        RAISE WARNING 'FALHOU  | 2. CPF duplicado foi aceito';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'BLOQUEADO | 2. CPF duplicado (UNIQUE)';
    END;

    ------------------------------------------------------------------ TESTE 3
    BEGIN
        INSERT INTO pessoa (cpf, nome, sobrenome, email, data_nascimento)
        VALUES ('99988877766', 'Nascido', 'NoFuturo', 'futuro@teste.com',
                CURRENT_DATE + 1);
        RAISE WARNING 'FALHOU  | 3. Data de nascimento futura foi aceita';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 3. Data de nascimento no futuro';
    END;

    ------------------------------------------------------------------ TESTE 4
    BEGIN
        INSERT INTO cliente (id_pessoa, logradouro, numero, bairro, cidade, uf, cep, banco)
        SELECT id_pessoa, 'Rua X', '1', 'Centro', 'Porto Velho', 'RO', '76800000', 'Itau'
          FROM pessoa WHERE cpf = '66677788899';
        RAISE WARNING 'FALHOU  | 4. Dados bancarios incompletos foram aceitos';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 4. Banco informado sem agencia/conta';
    END;

    ------------------------------------------------------------------ TESTE 5
    BEGIN
        INSERT INTO animal (nome, id_especie, id_cliente, sexo)
        VALUES ('Orfao', 1, 99999, 'M');
        RAISE WARNING 'FALHOU  | 5. Animal com tutor inexistente foi aceito';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'BLOQUEADO | 5. FK: animal apontando para cliente inexistente';
    END;

    ------------------------------------------------------------------ TESTE 6
    BEGIN
        INSERT INTO animal (nome, id_especie, id_cliente, sexo)
        SELECT 'SexoErrado', 1, id_pessoa, 'X' FROM pessoa WHERE cpf = '11122233344';
        RAISE WARNING 'FALHOU  | 6. Sexo invalido foi aceito';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 6. Sexo fora do dominio (M/F/I)';
    END;

    ------------------------------------------------------------------ TESTE 7
    -- Regra que so um GATILHO consegue validar: o animal pertence a outro tutor
    BEGIN
        INSERT INTO atendimento (id_atendente, id_cliente, id_animal, descritivo)
        SELECT (SELECT id_pessoa FROM pessoa WHERE cpf = '33344455566'),
               (SELECT id_pessoa FROM pessoa WHERE cpf = '22233344455'), -- Joao
               (SELECT a.id_animal FROM animal a
                  JOIN pessoa p ON p.id_pessoa = a.id_cliente
                 WHERE p.cpf = '11122233344' AND a.nome = 'Thor'),       -- cao da Mariana
               'Tutor trocado de proposito';
        RAISE WARNING 'FALHOU  | 7. Atendimento com tutor trocado foi aceito';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
        RAISE NOTICE 'BLOQUEADO | 7. Gatilho: %', left(v_msg, 60);
    END;

    ------------------------------------------------------------------ TESTE 8
    -- Animal inativo (obito) nao pode receber atendimento
    BEGIN
        INSERT INTO atendimento (id_atendente, id_cliente, id_animal, descritivo)
        SELECT (SELECT id_pessoa FROM pessoa WHERE cpf = '33344455566'),
               (SELECT id_pessoa FROM pessoa WHERE cpf = '10011122233'),
               (SELECT a.id_animal FROM animal a
                  JOIN pessoa p ON p.id_pessoa = a.id_cliente
                 WHERE p.cpf = '10011122233' AND a.nome = 'Bolinha'),
               'Atendimento para animal inativo';
        RAISE WARNING 'FALHOU  | 8. Atendimento para animal inativo foi aceito';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
        RAISE NOTICE 'BLOQUEADO | 8. Gatilho: %', left(v_msg, 60);
    END;

    ------------------------------------------------------------------ TESTE 9
    BEGIN
        INSERT INTO produto (id_tipo_produto, id_marca, descricao,
                             valor_compra, valor_venda)
        VALUES (1, 1, 'Produto com prejuizo', 100.00, 50.00);
        RAISE WARNING 'FALHOU  | 9. Produto com venda abaixo do custo foi aceito';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 9. Valor de venda menor que o de compra';
    END;

    ------------------------------------------------------------------ TESTE 10
    -- Gatilho de estoque: o colar elizabetano tem apenas 3 unidades
    BEGIN
        INSERT INTO atendimento_produto (id_atendimento, id_produto, quantidade, valor_unitario)
        SELECT (SELECT MIN(id_atendimento) FROM atendimento),
               id_produto, 999, valor_venda
          FROM produto WHERE descricao = 'Colar elizabetano tamanho M';
        RAISE WARNING 'FALHOU  | 10. Venda acima do estoque foi aceita';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_msg = MESSAGE_TEXT;
        RAISE NOTICE 'BLOQUEADO | 10. Gatilho: %', left(v_msg, 60);
    END;

    ------------------------------------------------------------------ TESTE 11
    BEGIN
        DELETE FROM cliente
         WHERE id_pessoa = (SELECT id_pessoa FROM pessoa WHERE cpf = '11122233344');
        RAISE WARNING 'FALHOU  | 11. Cliente com animais foi apagado';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'BLOQUEADO | 11. RESTRICT: cliente com animal vinculado';
    END;

    ------------------------------------------------------------------ TESTE 12
    BEGIN
        UPDATE produto SET estoque_atual = -5
         WHERE descricao = 'Vacina V10 canina';
        RAISE WARNING 'FALHOU  | 12. Estoque negativo foi aceito';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 12. Estoque negativo';
    END;

    ------------------------------------------------------------------ TESTE 13
    BEGIN
        INSERT INTO atendente (id_pessoa, matricula, data_admissao, data_demissao)
        SELECT id_pessoa, 'ATD999', '2024-01-01', '2023-01-01'
          FROM pessoa WHERE cpf = '44455566677';
        RAISE WARNING 'FALHOU  | 13. Demissao anterior a admissao foi aceita';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'BLOQUEADO | 13. Data de demissao anterior a admissao';
    END;

    RAISE NOTICE '--------------------------------------------------------';
    RAISE NOTICE 'Fim da bateria. Nenhuma linha "FALHOU" deve ter aparecido.';
END $$;

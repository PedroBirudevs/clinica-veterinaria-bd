\pset border 2
\echo '=== TESTE DA PROCEDURE registra_atendimento_completo ==='
\echo '--- Estoque ANTES ---'
SELECT descricao, estoque_atual FROM produto
 WHERE descricao IN ('Vacina antirrabica','Vermifugo comprimido 600mg');

DO $$
DECLARE
    v_id INTEGER;
    v_atd INTEGER; v_cli INTEGER; v_ani INTEGER; v_vet INTEGER;
    v_p1 INTEGER; v_p2 INTEGER; v_s1 INTEGER;
BEGIN
    -- PostgreSQL nao aceita subconsulta como argumento de CALL:
    -- os valores precisam ser resolvidos antes, em variaveis.
    SELECT id_pessoa INTO v_atd FROM pessoa WHERE cpf='33344455566';
    SELECT id_pessoa INTO v_cli FROM pessoa WHERE cpf='88899900011';
    SELECT a.id_animal INTO v_ani FROM animal a JOIN pessoa p ON p.id_pessoa=a.id_cliente
      WHERE p.cpf='88899900011' AND a.nome='Kiara';
    SELECT id_pessoa INTO v_vet FROM pessoa WHERE cpf='55566677788';
    SELECT id_produto INTO v_p1 FROM produto WHERE descricao='Vacina antirrabica';
    SELECT id_produto INTO v_p2 FROM produto WHERE descricao='Vermifugo comprimido 600mg';
    SELECT id_servico INTO v_s1 FROM servico WHERE nome='Aplicacao de vacina';

    CALL registra_atendimento_completo(
        v_atd, v_cli, v_ani, v_vet,
        'Vacinacao anual e vermifugacao de rotina.',
        ARRAY[v_p1, v_p2], ARRAY[1, 2]::NUMERIC[], ARRAY[v_s1],
        10.00, v_id
    );
END $$;

\echo '--- Estoque DEPOIS (baixa automatica pelo trigger) ---'
SELECT descricao, estoque_atual FROM produto
 WHERE descricao IN ('Vacina antirrabica','Vermifugo comprimido 600mg');

\echo '--- Atendimento gerado ---'
SELECT id_atendimento, animal, tutor, valor_total
  FROM vw_atendimentos_detalhados WHERE descritivo LIKE 'Vacinacao anual%';

\echo ''
\echo '=== ATOMICIDADE: estoque insuficiente deve desfazer TUDO ==='
SELECT COUNT(*) AS antes FROM atendimento;
DO $$
DECLARE v_id INTEGER; v_atd INTEGER; v_cli INTEGER; v_ani INTEGER; v_p INTEGER;
BEGIN
    SELECT id_pessoa INTO v_atd FROM pessoa WHERE cpf='33344455566';
    SELECT id_pessoa INTO v_cli FROM pessoa WHERE cpf='88899900011';
    SELECT a.id_animal INTO v_ani FROM animal a JOIN pessoa p ON p.id_pessoa=a.id_cliente
      WHERE p.cpf='88899900011' AND a.nome='Kiara';
    SELECT id_produto INTO v_p FROM produto WHERE descricao='Colar elizabetano tamanho M';

    CALL registra_atendimento_completo(
        v_atd, v_cli, v_ani, NULL,
        'Este atendimento NAO deve existir no final.',
        ARRAY[v_p], ARRAY[500]::NUMERIC[], NULL, 0, v_id);
    RAISE WARNING 'PROBLEMA: deveria ter falhado';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'OK - excecao capturada, transacao desfeita';
END $$;
SELECT COUNT(*) AS depois FROM atendimento;
SELECT COUNT(*) AS registro_fantasma FROM atendimento WHERE descritivo LIKE 'Este atendimento NAO%';

\echo ''
\echo '=== PROCEDURE repoe_estoque (media ponderada) ==='
SELECT descricao, estoque_atual, valor_compra FROM produto WHERE descricao='Colar elizabetano tamanho M';
DO $$
DECLARE v_p INTEGER;
BEGIN
    SELECT id_produto INTO v_p FROM produto WHERE descricao='Colar elizabetano tamanho M';
    CALL repoe_estoque(v_p, 20, 18.00);
END $$;
SELECT descricao, estoque_atual, valor_compra FROM produto WHERE descricao='Colar elizabetano tamanho M';

-- =============================================================================
-- V031 - Carga de ATENDIMENTO e seus itens
-- =============================================================================
-- Cenarios cobertos de proposito:
--   - atendimento com produtos E servicos
--   - atendimento so com servico, sem veterinario (banho e tosa)
--   - atendimento com desconto aplicado
--   - atendimento CANCELADO (nao deve entrar no faturamento de V023)
--   - atendimento onde o tutor e a propria atendente (Beatriz)
--   - datas em meses diferentes, para a visao de faturamento mensal fazer sentido
--
-- Cada INSERT em atendimento_produto dispara o trigger de baixa de estoque.
-- =============================================================================

-- --- Atendimento 1: consulta completa com vacina --------------------------
WITH novo AS (
    INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                             id_veterinario, descritivo, diagnostico, status)
    SELECT
        CURRENT_DATE - INTERVAL '75 days' + TIME '09:30',
        (SELECT id_pessoa FROM pessoa WHERE cpf = '33344455566'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '11122233344'),
        (SELECT a.id_animal FROM animal a
           JOIN pessoa p ON p.id_pessoa = a.id_cliente
          WHERE p.cpf = '11122233344' AND a.nome = 'Thor'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '55566677788'),
        'Tutor relata coceira intensa e vermelhidao nas orelhas ha uma semana.',
        'Otite externa bilateral. Vacinacao anual em dia a partir de hoje.',
        'CONCLUIDO'
    WHERE NOT EXISTS (
        SELECT 1 FROM atendimento
         WHERE descritivo LIKE 'Tutor relata coceira intensa%'
    )
    RETURNING id_atendimento
)
INSERT INTO atendimento_servico (id_atendimento, id_servico, quantidade, valor_unitario, id_executante)
SELECT n.id_atendimento, s.id_servico, 1, s.valor_padrao,
       (SELECT id_pessoa FROM pessoa WHERE cpf = '55566677788')
FROM novo n
CROSS JOIN servico s
WHERE s.nome IN ('Consulta clinica geral', 'Aplicacao de vacina');

INSERT INTO atendimento_produto (id_atendimento, id_produto, quantidade, valor_unitario)
SELECT at.id_atendimento, p.id_produto, d.qtd::NUMERIC, p.valor_venda
FROM atendimento at
CROSS JOIN (VALUES ('Vacina V10 canina', 1), ('Pomada otologica', 1)) AS d(descricao, qtd)
JOIN produto p ON p.descricao = d.descricao
WHERE at.descritivo LIKE 'Tutor relata coceira intensa%'
  AND NOT EXISTS (
      SELECT 1 FROM atendimento_produto ap
       WHERE ap.id_atendimento = at.id_atendimento AND ap.id_produto = p.id_produto
  );

-- --- Atendimento 2: castracao com desconto --------------------------------
WITH novo AS (
    INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                             id_veterinario, descritivo, diagnostico, status, desconto)
    SELECT
        CURRENT_DATE - INTERVAL '48 days' + TIME '14:00',
        (SELECT id_pessoa FROM pessoa WHERE cpf = '10011122233'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '22233344455'),
        (SELECT a.id_animal FROM animal a
           JOIN pessoa p ON p.id_pessoa = a.id_cliente
          WHERE p.cpf = '22233344455' AND a.nome = 'Nina'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '66677788899'),
        'Castracao eletiva agendada. Jejum de 12h confirmado pelo tutor.',
        'Procedimento sem intercorrencias. Retorno em 10 dias para retirar pontos.',
        'CONCLUIDO',
        50.00
    WHERE NOT EXISTS (
        SELECT 1 FROM atendimento WHERE descritivo LIKE 'Castracao eletiva agendada%'
    )
    RETURNING id_atendimento
)
INSERT INTO atendimento_servico (id_atendimento, id_servico, quantidade, valor_unitario, id_executante)
SELECT n.id_atendimento, s.id_servico, 1, s.valor_padrao,
       (SELECT id_pessoa FROM pessoa WHERE cpf = '66677788899')
FROM novo n
CROSS JOIN servico s
WHERE s.nome IN ('Castracao femea', 'Exame de sangue completo');

INSERT INTO atendimento_produto (id_atendimento, id_produto, quantidade, valor_unitario)
SELECT at.id_atendimento, p.id_produto, d.qtd::NUMERIC, p.valor_venda
FROM atendimento at
CROSS JOIN (VALUES ('Kit sutura absorvivel', 1),
                   ('Anti-inflamatorio injetavel', 1),
                   ('Colar elizabetano tamanho M', 1)) AS d(descricao, qtd)
JOIN produto p ON p.descricao = d.descricao
WHERE at.descritivo LIKE 'Castracao eletiva agendada%'
  AND NOT EXISTS (
      SELECT 1 FROM atendimento_produto ap
       WHERE ap.id_atendimento = at.id_atendimento AND ap.id_produto = p.id_produto
  );

-- --- Atendimento 3: banho e tosa, SEM veterinario -------------------------
WITH novo AS (
    INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                             id_veterinario, descritivo, status)
    SELECT
        CURRENT_DATE - INTERVAL '20 days' + TIME '10:15',
        (SELECT id_pessoa FROM pessoa WHERE cpf = '77788899900'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '11122233344'),
        (SELECT a.id_animal FROM animal a
           JOIN pessoa p ON p.id_pessoa = a.id_cliente
          WHERE p.cpf = '11122233344' AND a.nome = 'Mel'),
        NULL,                                   -- servico sem responsavel tecnico
        'Banho e tosa higienica de rotina.',
        'CONCLUIDO'
    WHERE NOT EXISTS (
        SELECT 1 FROM atendimento WHERE descritivo = 'Banho e tosa higienica de rotina.'
    )
    RETURNING id_atendimento
)
INSERT INTO atendimento_servico (id_atendimento, id_servico, quantidade, valor_unitario)
SELECT n.id_atendimento, s.id_servico, 1, s.valor_padrao
FROM novo n
CROSS JOIN servico s
WHERE s.nome IN ('Banho e tosa', 'Corte de unhas');

-- --- Atendimento 4: a atendente Beatriz como TUTORA -----------------------
-- Comprova na pratica a especializacao sobreposta: Beatriz e atendente
-- (matricula ATD001) e aqui aparece como cliente com seu cao Bidu.
WITH novo AS (
    INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                             id_veterinario, descritivo, diagnostico, status)
    SELECT
        CURRENT_DATE - INTERVAL '12 days' + TIME '16:40',
        (SELECT id_pessoa FROM pessoa WHERE cpf = '10011122233'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '33344455566'),  -- Beatriz cliente
        (SELECT a.id_animal FROM animal a
           JOIN pessoa p ON p.id_pessoa = a.id_cliente
          WHERE p.cpf = '33344455566' AND a.nome = 'Bidu'),
        (SELECT id_pessoa FROM pessoa WHERE cpf = '99900011122'),
        'Retorno de otite. Tutora e funcionaria da clinica.',
        'Quadro resolvido. Manter limpeza semanal.',
        'CONCLUIDO'
    WHERE NOT EXISTS (
        SELECT 1 FROM atendimento WHERE descritivo LIKE 'Retorno de otite%'
    )
    RETURNING id_atendimento
)
INSERT INTO atendimento_servico (id_atendimento, id_servico, quantidade, valor_unitario, id_executante)
SELECT n.id_atendimento, s.id_servico, 1, s.valor_padrao,
       (SELECT id_pessoa FROM pessoa WHERE cpf = '99900011122')
FROM novo n
CROSS JOIN servico s
WHERE s.nome = 'Consulta de retorno';

-- --- Atendimento 5: em aberto (agendado hoje) -----------------------------
INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                         id_veterinario, descritivo, status)
SELECT
    CURRENT_TIMESTAMP - INTERVAL '2 hours',
    (SELECT id_pessoa FROM pessoa WHERE cpf = '33344455566'),
    (SELECT id_pessoa FROM pessoa WHERE cpf = '88899900011'),
    (SELECT a.id_animal FROM animal a
       JOIN pessoa p ON p.id_pessoa = a.id_cliente
      WHERE p.cpf = '88899900011' AND a.nome = 'Tobias'),
    (SELECT id_pessoa FROM pessoa WHERE cpf = '55566677788'),
    'Dificuldade de locomocao nas patas traseiras. Avaliacao ortopedica.',
    'ABERTO'
WHERE NOT EXISTS (
    SELECT 1 FROM atendimento WHERE descritivo LIKE 'Dificuldade de locomocao%'
);

-- --- Atendimento 6: CANCELADO (nao entra no faturamento) ------------------
INSERT INTO atendimento (data_hora, id_atendente, id_cliente, id_animal,
                         id_veterinario, descritivo, status)
SELECT
    CURRENT_DATE - INTERVAL '5 days' + TIME '11:00',
    (SELECT id_pessoa FROM pessoa WHERE cpf = '77788899900'),
    (SELECT id_pessoa FROM pessoa WHERE cpf = '44455566677'),
    (SELECT a.id_animal FROM animal a
       JOIN pessoa p ON p.id_pessoa = a.id_cliente
      WHERE p.cpf = '44455566677' AND a.nome = 'Pipoca'),
    (SELECT id_pessoa FROM pessoa WHERE cpf = '66677788899'),
    'Consulta agendada. Tutor nao compareceu.',
    'CANCELADO'
WHERE NOT EXISTS (
    SELECT 1 FROM atendimento WHERE descritivo LIKE 'Consulta agendada. Tutor nao%'
);

-- =============================================================================
-- V030 - Carga de PRODUTO e SERVICO
-- =============================================================================
-- Estoques iniciais dimensionados para permitir os lancamentos do V031 e ainda
-- deixar saldo, exceto o item "Colar elizabetano", proposital com estoque baixo
-- para demonstrar o bloqueio do trigger de estoque (V019) nos testes.
-- =============================================================================

INSERT INTO produto (id_tipo_produto, id_marca, descricao, unidade_medida,
                     valor_compra, valor_venda, estoque_atual, estoque_minimo)
SELECT tp.id_tipo_produto, m.id_marca, d.descricao, d.unidade,
       d.compra::NUMERIC, d.venda::NUMERIC, d.estoque, d.minimo
FROM (VALUES
    ('Vacina',            'Zoetis',      'Vacina V10 canina',              'FR',  38.00,  85.00, 40,  10),
    ('Vacina',            'MSD',         'Vacina antirrabica',             'FR',  22.00,  60.00, 55,  15),
    ('Vacina',            'Ceva',        'Vacina quadrupla felina',        'FR',  45.00,  95.00, 25,   8),
    ('Antiparasitario',   'Virbac',      'Antipulgas topico 10-20kg',      'UN',  32.00,  72.00, 60,  20),
    ('Antiparasitario',   'Ceva',        'Vermifugo comprimido 600mg',     'CP',   6.50,  18.00, 120, 30),
    ('Medicamento',       'Generico',    'Anti-inflamatorio injetavel',    'FR',  28.00,  65.00, 30,  10),
    ('Medicamento',       'Generico',    'Antibiotico amoxicilina 500mg',  'CP',   2.80,   9.50, 200, 50),
    ('Medicamento',       'Virbac',      'Pomada otologica',               'UN',  24.00,  55.00, 35,  10),
    ('Racao',             'Royal Canin', 'Racao renal caes 2kg',           'KG',  78.00, 142.00, 18,   5),
    ('Racao',             'Premier Pet', 'Racao filhotes gatos 1kg',       'KG',  41.00,  79.00, 24,   6),
    ('Higiene',           'Premier Pet', 'Shampoo antisseptico 500ml',     'ML',  19.00,  44.00, 40,  10),
    ('Acessorio',         'Generico',    'Colar elizabetano tamanho M',    'UN',  12.00,  35.00,  3,   5),
    ('Material cirurgico','Generico',    'Kit sutura absorvivel',          'UN',  15.00,  38.00, 50,  15)
) AS d(tipo, marca, descricao, unidade, compra, venda, estoque, minimo)
JOIN tipo_produto tp ON tp.nome = d.tipo
JOIN marca        m  ON m.nome  = d.marca
ON CONFLICT (descricao, id_marca) DO NOTHING;

INSERT INTO servico (nome, descricao, valor_padrao, duracao_minutos, exige_veterinario) VALUES
    ('Consulta clinica geral',   'Avaliacao clinica completa com anamnese',        120.00,  30, TRUE),
    ('Consulta de retorno',      'Reavaliacao ate 15 dias apos a consulta',         60.00,  20, TRUE),
    ('Aplicacao de vacina',      'Aplicacao com registro em carteira',              25.00,  10, TRUE),
    ('Castracao femea',          'Ovariosalpingohisterectomia eletiva',            480.00, 120, TRUE),
    ('Castracao macho',          'Orquiectomia eletiva',                           350.00,  90, TRUE),
    ('Exame de sangue completo', 'Hemograma e bioquimico',                         180.00,  45, TRUE),
    ('Ultrassonografia',         'Exame de imagem abdominal',                      220.00,  40, TRUE),
    ('Limpeza dentaria',         'Profilaxia com sedacao',                         390.00,  60, TRUE),
    ('Banho e tosa',             'Higiene completa, sem responsavel tecnico',       80.00,  60, FALSE),
    ('Corte de unhas',           'Procedimento simples de contencao',               30.00,  15, FALSE)
ON CONFLICT (nome) DO NOTHING;

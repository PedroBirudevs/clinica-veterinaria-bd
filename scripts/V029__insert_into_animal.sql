-- =============================================================================
-- V029 - Carga de ANIMAL
-- =============================================================================
-- Inclui de proposito:
--   - tutores com mais de um animal (testa a cardinalidade 1:N)
--   - animal sem data de nascimento (resgatado, idade desconhecida)
--   - animal inativo (obito), para testar o bloqueio do trigger V018
--   - especies diferentes de cao e gato, exercitando a tabela ESPECIE
-- =============================================================================

INSERT INTO animal (nome, id_especie, id_cliente, sexo, data_nascimento, peso_kg, castrado, observacoes, ativo)
SELECT d.nome, e.id_especie, p.id_pessoa, d.sexo,
       d.nascimento::DATE, d.peso::NUMERIC, d.castrado, d.obs, d.ativo
FROM   (VALUES
    ('Thor',      'Cao',       '11122233344', 'M', '2019-05-10', 28.500, TRUE,  'Labrador. Alergico a sulfa.',            TRUE),
    ('Mel',       'Cao',       '11122233344', 'F', '2021-08-22',  7.200, TRUE,  'Shih-tzu. Temperamento docil.',          TRUE),
    ('Nina',      'Gato',      '22233344455', 'F', '2020-01-15',  4.100, TRUE,  'SRD. Arisca em consulta.',               TRUE),
    ('Simba',     'Gato',      '22233344455', 'M', NULL,          5.300, FALSE, 'Resgatado, idade estimada em 3 anos.',   TRUE),
    ('Bidu',      'Cao',       '33344455566', 'M', '2018-03-30', 15.000, TRUE,  'Vira-lata. Historico de otite.',         TRUE),
    ('Pipoca',    'Coelho',    '44455566677', 'F', '2022-11-02',  1.800, FALSE, 'Coelho anao.',                           TRUE),
    ('Loro',      'Papagaio',  '44455566677', 'M', '2010-06-18',  0.420, FALSE, 'Papagaio verdadeiro. Documentado IBAMA.',TRUE),
    ('Amora',     'Gato',      '55566677788', 'F', '2023-02-14',  3.600, FALSE, 'Filhote da ninhada da clinica.',         TRUE),
    ('Fred',      'Hamster',   '77788899900', 'M', '2024-09-01',  0.130, FALSE, 'Hamster sirio.',                         TRUE),
    ('Tobias',    'Cao',       '88899900011', 'M', '2015-04-12', 32.000, TRUE,  'Pastor alemao idoso. Displasia coxofemoral.', TRUE),
    ('Kiara',     'Cao',       '88899900011', 'F', '2022-07-19', 11.400, TRUE,  'Beagle.',                                TRUE),
    ('Jade',      'Iguana',    '10011122233', 'F', '2021-10-05',  2.300, FALSE, 'Exige ambiente aquecido.',               TRUE),
    ('Bolinha',   'Gato',      '10011122233', 'M', '2012-03-08',  6.800, TRUE,  'Obito em 2026 por insuficiencia renal.', FALSE)
) AS d(nome, especie, cpf_tutor, sexo, nascimento, peso, castrado, obs, ativo)
JOIN especie e ON e.nome = d.especie
JOIN pessoa  p ON p.cpf  = d.cpf_tutor
JOIN cliente c ON c.id_pessoa = p.id_pessoa
ON CONFLICT (id_cliente, nome) DO NOTHING;

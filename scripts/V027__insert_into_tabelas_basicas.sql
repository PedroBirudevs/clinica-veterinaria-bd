-- =============================================================================
-- V027 - Carga das tabelas de dominio (especie, tipo de produto, marca)
-- =============================================================================
-- ON CONFLICT DO NOTHING torna o script reexecutavel: rodar duas vezes nao
-- duplica nem gera erro de chave. As restricoes UNIQUE definidas no DDL sao
-- o que permite essa clausula funcionar.
-- =============================================================================

INSERT INTO especie (nome, classe, porte_padrao) VALUES
    ('Cao',        'MAMIFERO', 'MEDIO'),
    ('Gato',       'MAMIFERO', 'PEQUENO'),
    ('Coelho',     'MAMIFERO', 'PEQUENO'),
    ('Hamster',    'MAMIFERO', 'PEQUENO'),
    ('Calopsita',  'AVE',      'PEQUENO'),
    ('Papagaio',   'AVE',      'PEQUENO'),
    ('Jabuti',     'REPTIL',   'MEDIO'),
    ('Iguana',     'REPTIL',   'MEDIO')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO tipo_produto (nome, exige_receita) VALUES
    ('Medicamento',      TRUE),
    ('Antiparasitario',  FALSE),
    ('Vacina',           TRUE),
    ('Racao',            FALSE),
    ('Higiene',          FALSE),
    ('Acessorio',        FALSE),
    ('Material cirurgico', FALSE)
ON CONFLICT (nome) DO NOTHING;

INSERT INTO marca (nome, fabricante) VALUES
    ('Zoetis',      'Zoetis Industria de Produtos Veterinarios'),
    ('Ceva',        'Ceva Saude Animal'),
    ('MSD',         'MSD Saude Animal'),
    ('Premier Pet', 'Premier Pet Alimentos'),
    ('Royal Canin', 'Royal Canin do Brasil'),
    ('Virbac',      'Virbac do Brasil'),
    ('Generico',    NULL)
ON CONFLICT (nome) DO NOTHING;

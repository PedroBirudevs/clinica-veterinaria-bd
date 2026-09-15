-- =============================================================================
-- V028 - Carga de PESSOA e suas especializacoes
-- =============================================================================
-- Conjunto montado para exercitar todos os casos da modelagem:
--   - pessoas que sao apenas clientes
--   - pessoas que sao apenas funcionarios
--   - UMA PESSOA QUE E ATENDENTE E CLIENTE AO MESMO TEMPO (Beatriz Rocha)
--   - UM VETERINARIO QUE TAMBEM E CLIENTE (Dr. Ricardo Nunes)
-- Os dois ultimos casos comprovam a especializacao sobreposta exigida no
-- enunciado, que seria impossivel sem a generalizacao da V001.
--
-- Os CPFs sao ficticios, gerados apenas para teste.
-- =============================================================================

INSERT INTO pessoa (cpf, nome, sobrenome, email, telefone, data_nascimento) VALUES
    ('11122233344', 'Mariana',  'Alves',    'mariana.alves@email.com',   '69991110001', '1990-03-14'),
    ('22233344455', 'Joao',     'Pereira',  'joao.pereira@email.com',    '69991110002', '1985-07-22'),
    ('33344455566', 'Beatriz',  'Rocha',    'beatriz.rocha@email.com',   '69991110003', '1996-11-05'),
    ('44455566677', 'Carlos',   'Siqueira', 'carlos.siqueira@email.com', '69991110004', '1978-01-30'),
    ('55566677788', 'Ricardo',  'Nunes',    'ricardo.nunes@vet.com',     '69991110005', '1982-05-19'),
    ('66677788899', 'Fernanda', 'Lima',     'fernanda.lima@vet.com',     '69991110006', '1991-09-08'),
    ('77788899900', 'Tiago',    'Moreira',  'tiago.moreira@email.com',   '69991110007', '2000-12-25'),
    ('88899900011', 'Luiza',    'Campos',   'luiza.campos@email.com',    '69991110008', '1994-04-17'),
    ('99900011122', 'Rafael',   'Barbosa',  'rafael.barbosa@vet.com',    '69991110009', '1988-08-03'),
    ('10011122233', 'Patricia', 'Souza',    'patricia.souza@email.com',  '69991110010', '1975-06-11')
ON CONFLICT (cpf) DO NOTHING;

-- --- CLIENTES (tutores) ------------------------------------------------------
-- Beatriz e Ricardo aparecem aqui E nas tabelas de funcionario: e o caso de
-- especializacao sobreposta.
INSERT INTO cliente (
    id_pessoa, logradouro, numero, complemento, bairro, cidade, uf, cep,
    banco, agencia, conta, tipo_conta, chave_pix
)
SELECT p.id_pessoa, d.logradouro, d.numero, d.complemento, d.bairro,
       d.cidade, d.uf, d.cep, d.banco, d.agencia, d.conta, d.tipo_conta, d.pix
FROM pessoa p
JOIN (VALUES
    ('11122233344', 'Rua das Flores',      '120', 'Apto 302', 'Centro',     'Porto Velho',      'RO', '76801000', 'Banco do Brasil', '1234', '11111-1', 'CORRENTE', 'mariana.alves@email.com'),
    ('22233344455', 'Avenida Amazonas',    '45',  NULL,       'Nova Porto', 'Porto Velho',      'RO', '76820100', 'Caixa',           '5678', '22222-2', 'POUPANCA', '22233344455'),
    ('33344455566', 'Rua Jamari',          '780', 'Casa 2',   'Embratel',   'Porto Velho',      'RO', '76820750', NULL,              NULL,   NULL,      NULL,       '69991110003'),
    ('44455566677', 'Rua Getulio Vargas',  '1500',NULL,       'Centro',     'Itapua do Oeste',  'RO', '76861000', 'Itau',            '0912', '33333-3', 'CORRENTE', NULL),
    ('55566677788', 'Rua das Palmeiras',   '33',  NULL,       'Jardim',     'Porto Velho',      'RO', '76803000', NULL,              NULL,   NULL,      NULL,       'ricardo.nunes@vet.com'),
    ('77788899900', 'Travessa Sao Pedro',  '210', 'Fundos',   'Sao Joao',   'Itapua do Oeste',  'RO', '76861000', NULL,              NULL,   NULL,      NULL,       NULL),
    ('88899900011', 'Rua Rio Madeira',     '900', NULL,       'Centro',     'Candeias do Jamari','RO','76860000', 'Nubank',          '0001', '44444-4', 'CORRENTE', '88899900011'),
    ('10011122233', 'Alameda dos Ipes',    '67',  'Bloco B',  'Flodoaldo',  'Porto Velho',      'RO', '76820500', NULL,              NULL,   NULL,      NULL,       NULL)
) AS d(cpf, logradouro, numero, complemento, bairro, cidade, uf, cep,
       banco, agencia, conta, tipo_conta, pix)
  ON d.cpf = p.cpf
ON CONFLICT (id_pessoa) DO NOTHING;

-- --- ATENDENTES --------------------------------------------------------------
INSERT INTO atendente (id_pessoa, matricula, data_admissao, turno)
SELECT p.id_pessoa, d.matricula, d.admissao::DATE, d.turno
FROM pessoa p
JOIN (VALUES
    ('33344455566', 'ATD001', '2022-02-01', 'MANHA'),    -- Beatriz: tambem cliente
    ('77788899900', 'ATD002', '2023-06-15', 'TARDE'),    -- Tiago: tambem cliente
    ('10011122233', 'ATD003', '2021-09-10', 'INTEGRAL')  -- Patricia: tambem cliente
) AS d(cpf, matricula, admissao, turno)
  ON d.cpf = p.cpf
ON CONFLICT (id_pessoa) DO NOTHING;

-- --- VETERINARIOS ------------------------------------------------------------
INSERT INTO veterinario (id_pessoa, crmv, especialidade, data_formatura)
SELECT p.id_pessoa, d.crmv, d.especialidade, d.formatura::DATE
FROM pessoa p
JOIN (VALUES
    ('55566677788', 'CRMV-RO 1234', 'Clinica geral de pequenos animais', '2006-12-15'),
    ('66677788899', 'CRMV-RO 2345', 'Cirurgia e ortopedia',              '2015-07-20'),
    ('99900011122', 'CRMV-RO 3456', 'Dermatologia veterinaria',          '2012-12-10')
) AS d(cpf, crmv, especialidade, formatura)
  ON d.cpf = p.cpf
ON CONFLICT (id_pessoa) DO NOTHING;

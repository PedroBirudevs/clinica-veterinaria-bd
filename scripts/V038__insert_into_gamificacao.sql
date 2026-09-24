-- =============================================================================
-- V038 - Carga do programa de fidelidade (Inovacao)
-- =============================================================================
-- Niveis e conquistas de exemplo. Pontos e conquistas sao gerados a partir
-- dos atendimentos e animais ja cadastrados (INSERT ... SELECT), sem IDs fixos.
-- Regras:
--   - 10 pontos por atendimento nao cancelado
--   - cada conquista desbloqueada rende os pontos_bonus dela
-- Pode ser executado mais de uma vez sem duplicar dados.
-- =============================================================================

-- --- Niveis -----------------------------------------------------------------
INSERT INTO nivel (nome, pontos_minimos) VALUES
    ('Bronze',   0),
    ('Prata',   50),
    ('Ouro',   150)
ON CONFLICT DO NOTHING;

-- --- Conquistas -------------------------------------------------------------
INSERT INTO conquista (nome, descricao, pontos_bonus) VALUES
    ('Primeira consulta', 'Realizou o primeiro atendimento na clinica',  5),
    ('Cliente fiel',      'Realizou 3 ou mais atendimentos',            20),
    ('Familia grande',    'Tem 2 ou mais animais cadastrados',          10)
ON CONFLICT (nome) DO NOTHING;

-- --- Pontos por atendimento -------------------------------------------------
INSERT INTO pontuacao (id_cliente, id_atendimento, pontos, motivo, registrado_em)
SELECT at.id_cliente, at.id_atendimento, 10, 'Atendimento', at.data_hora
FROM atendimento at
WHERE at.status <> 'CANCELADO'
  AND NOT EXISTS (SELECT 1 FROM pontuacao pt
                   WHERE pt.id_atendimento = at.id_atendimento);

-- --- Conquistas desbloqueadas -----------------------------------------------
INSERT INTO cliente_conquista (id_cliente, id_conquista, obtida_em)
SELECT r.id_cliente, c.id_conquista, r.obtida_em
FROM (
    -- Primeira consulta: data do primeiro atendimento
    SELECT id_cliente, 'Primeira consulta' AS conquista, MIN(data_hora) AS obtida_em
      FROM atendimento
     WHERE status <> 'CANCELADO'
     GROUP BY id_cliente
    UNION ALL
    -- Cliente fiel: 3 ou mais atendimentos
    SELECT id_cliente, 'Cliente fiel', MAX(data_hora)
      FROM atendimento
     WHERE status <> 'CANCELADO'
     GROUP BY id_cliente
    HAVING COUNT(*) >= 3
    UNION ALL
    -- Familia grande: 2 ou mais animais
    SELECT id_cliente, 'Familia grande', MAX(criado_em)
      FROM animal
     GROUP BY id_cliente
    HAVING COUNT(*) >= 2
) r
JOIN conquista c ON c.nome = r.conquista
ON CONFLICT (id_cliente, id_conquista) DO NOTHING;

-- --- Pontos bonus das conquistas --------------------------------------------
INSERT INTO pontuacao (id_cliente, id_atendimento, pontos, motivo, registrado_em)
SELECT cc.id_cliente, NULL, c.pontos_bonus, 'Conquista: ' || c.nome, cc.obtida_em
FROM cliente_conquista cc
JOIN conquista c ON c.id_conquista = cc.id_conquista
WHERE c.pontos_bonus > 0
  AND NOT EXISTS (SELECT 1 FROM pontuacao pt
                   WHERE pt.id_cliente = cc.id_cliente
                     AND pt.motivo     = 'Conquista: ' || c.nome);

-- Conferencia:
-- SELECT * FROM vw_ranking_clientes;

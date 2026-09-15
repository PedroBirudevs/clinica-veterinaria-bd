-- =============================================================================
-- V024 - VISAO vw_prontuario_animal
-- =============================================================================
-- Historico clinico consolidado por animal: quantas vezes veio, quando foi a
-- ultima visita e quanto ja gastou. E a tela que o veterinario abre antes de
-- atender.
-- =============================================================================

CREATE OR REPLACE VIEW vw_prontuario_animal AS
SELECT
    an.id_animal,
    an.nome                                   AS animal,
    e.nome                                    AS especie,
    e.classe,
    an.sexo,
    idade_animal(an.data_nascimento)          AS idade,
    an.peso_kg,
    an.castrado,
    an.ativo,
    p.nome || ' ' || p.sobrenome              AS tutor,
    p.telefone                                AS telefone_tutor,
    COUNT(at.id_atendimento)                  AS total_atendimentos,
    MAX(at.data_hora)                         AS ultima_visita,
    COALESCE(SUM(calcula_total_atendimento(at.id_atendimento)), 0) AS total_gasto
FROM animal   an
JOIN especie  e  ON e.id_especie = an.id_especie
JOIN cliente  c  ON c.id_pessoa  = an.id_cliente
JOIN pessoa   p  ON p.id_pessoa  = c.id_pessoa
LEFT JOIN atendimento at
       ON at.id_animal = an.id_animal
      AND at.status <> 'CANCELADO'
GROUP BY an.id_animal, an.nome, e.nome, e.classe, an.sexo,
         an.data_nascimento, an.peso_kg, an.castrado, an.ativo,
         p.nome, p.sobrenome, p.telefone;

COMMENT ON VIEW vw_prontuario_animal
    IS 'Historico clinico e financeiro consolidado por animal';

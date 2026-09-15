-- =============================================================================
-- V022 - VISAO vw_atendimentos_detalhados
-- =============================================================================
-- Consolida em uma linha tudo que a recepcao precisa ver sobre um atendimento,
-- substituindo um JOIN de seis tabelas que seria reescrito a cada consulta.
--
-- Usa LEFT JOIN no veterinario porque ele e opcional (banho e tosa).
-- O valor total vem da funcao de V016, mantendo uma unica fonte da regra.
-- =============================================================================

CREATE OR REPLACE VIEW vw_atendimentos_detalhados AS
SELECT
    at.id_atendimento,
    at.data_hora,
    at.status,

    an.nome                                    AS animal,
    e.nome                                     AS especie,
    idade_animal(an.data_nascimento)           AS idade_animal,

    pc.nome || ' ' || pc.sobrenome             AS tutor,
    pc.telefone                                AS telefone_tutor,

    pa.nome || ' ' || pa.sobrenome             AS atendente,

    pv.nome || ' ' || pv.sobrenome             AS veterinario,
    v.especialidade,

    at.descritivo,
    at.diagnostico,
    at.desconto,
    calcula_total_atendimento(at.id_atendimento) AS valor_total,

    (SELECT COUNT(*) FROM atendimento_produto ap
      WHERE ap.id_atendimento = at.id_atendimento) AS qtd_produtos,
    (SELECT COUNT(*) FROM atendimento_servico asv
      WHERE asv.id_atendimento = at.id_atendimento) AS qtd_servicos

FROM atendimento at
JOIN animal       an ON an.id_animal   = at.id_animal
JOIN especie      e  ON e.id_especie   = an.id_especie
JOIN cliente      c  ON c.id_pessoa    = at.id_cliente
JOIN pessoa       pc ON pc.id_pessoa   = c.id_pessoa
JOIN atendente    a  ON a.id_pessoa    = at.id_atendente
JOIN pessoa       pa ON pa.id_pessoa   = a.id_pessoa
LEFT JOIN veterinario v  ON v.id_pessoa  = at.id_veterinario
LEFT JOIN pessoa      pv ON pv.id_pessoa = v.id_pessoa;

COMMENT ON VIEW vw_atendimentos_detalhados
    IS 'Visao operacional: um atendimento por linha com tutor, animal, equipe e valor';

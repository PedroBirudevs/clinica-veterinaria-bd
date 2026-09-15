-- =============================================================================
-- CONSULTAS DE EXEMPLO
-- =============================================================================
-- Perguntas reais que a clinica faria ao banco, cada uma exercitando um
-- recurso diferente de SQL.
-- =============================================================================

\pset border 2

\echo '=== 1. Quem sao os atendentes que tambem sao clientes? (especializacao) ==='
SELECT nome_completo, matricula, turno, tambem_e_cliente
  FROM vw_pessoas_atendentes
 WHERE tambem_e_cliente = TRUE;

\echo ''
\echo '=== 2. Agenda do dia com valores (JOIN de 6 tabelas via visao) ==='
SELECT id_atendimento, to_char(data_hora,'DD/MM HH24:MI') AS quando,
       animal, tutor, veterinario, status, valor_total
  FROM vw_atendimentos_detalhados
 ORDER BY data_hora DESC
 LIMIT 10;

\echo ''
\echo '=== 3. Ranking de clientes por valor gasto (agregacao + HAVING) ==='
SELECT p.nome || ' ' || p.sobrenome                       AS cliente,
       COUNT(DISTINCT at.id_atendimento)                  AS visitas,
       COUNT(DISTINCT an.id_animal)                       AS animais,
       SUM(calcula_total_atendimento(at.id_atendimento))  AS total_gasto
  FROM atendimento at
  JOIN pessoa p ON p.id_pessoa = at.id_cliente
  JOIN animal an ON an.id_animal = at.id_animal
 WHERE at.status = 'CONCLUIDO'
 GROUP BY p.id_pessoa, p.nome, p.sobrenome
HAVING SUM(calcula_total_atendimento(at.id_atendimento)) > 0
 ORDER BY total_gasto DESC;

\echo ''
\echo '=== 4. Produtos que precisam de reposicao (indice parcial em uso) ==='
SELECT p.descricao, m.nome AS marca, p.estoque_atual, p.estoque_minimo,
       (p.estoque_minimo - p.estoque_atual) AS faltam
  FROM produto p
  JOIN marca m ON m.id_marca = p.id_marca
 WHERE p.ativo = TRUE AND p.estoque_atual <= p.estoque_minimo
 ORDER BY faltam DESC;

\echo ''
\echo '=== 5. Servicos mais executados (agregacao sobre tabela associativa) ==='
SELECT s.nome                                     AS servico,
       SUM(asv.quantidade)                        AS vezes_executado,
       SUM(asv.quantidade * asv.valor_unitario)   AS receita
  FROM atendimento_servico asv
  JOIN servico     s  ON s.id_servico     = asv.id_servico
  JOIN atendimento at ON at.id_atendimento = asv.id_atendimento
 WHERE at.status <> 'CANCELADO'
 GROUP BY s.id_servico, s.nome
 ORDER BY receita DESC;

\echo ''
\echo '=== 6. Faturamento mensal com margem (visao analitica) ==='
SELECT to_char(mes,'MM/YYYY') AS mes, qtd_atendimentos,
       receita_produtos, receita_servicos, total_descontos,
       receita_liquida, ticket_medio
  FROM vw_faturamento_por_mes;

\echo ''
\echo '=== 7. Animais que nunca voltaram (LEFT JOIN + IS NULL) ==='
SELECT an.nome AS animal, e.nome AS especie,
       p.nome || ' ' || p.sobrenome AS tutor,
       idade_animal(an.data_nascimento) AS idade
  FROM animal an
  JOIN especie e ON e.id_especie = an.id_especie
  JOIN pessoa  p ON p.id_pessoa  = an.id_cliente
  LEFT JOIN atendimento at ON at.id_animal = an.id_animal
 WHERE at.id_atendimento IS NULL AND an.ativo = TRUE
 ORDER BY an.nome;

\echo ''
\echo '=== 8. Distribuicao de pacientes por classe (agregacao + percentual) ==='
SELECT e.classe,
       COUNT(*)                                             AS qtd,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)   AS percentual
  FROM animal an
  JOIN especie e ON e.id_especie = an.id_especie
 GROUP BY e.classe
 ORDER BY qtd DESC;

\echo ''
\echo '=== 9. Prontuario de um animal especifico ==='
SELECT animal, especie, idade, peso_kg, tutor,
       total_atendimentos, ultima_visita, total_gasto
  FROM vw_prontuario_animal
 WHERE total_atendimentos > 0
 ORDER BY total_gasto DESC;

\echo ''
\echo '=== 10. Produtividade por veterinario ==='
SELECT p.nome || ' ' || p.sobrenome         AS veterinario,
       v.especialidade,
       COUNT(at.id_atendimento)             AS atendimentos,
       COALESCE(SUM(calcula_total_atendimento(at.id_atendimento)),0) AS receita_gerada
  FROM veterinario v
  JOIN pessoa p ON p.id_pessoa = v.id_pessoa
  LEFT JOIN atendimento at
         ON at.id_veterinario = v.id_pessoa AND at.status = 'CONCLUIDO'
 GROUP BY v.id_pessoa, p.nome, p.sobrenome, v.especialidade
 ORDER BY receita_gerada DESC;

\echo ''
\echo '=== 11. Auditoria: historico de mudanca de status ==='
SELECT l.id_atendimento, COALESCE(l.status_antigo,'(criado)') AS de,
       l.status_novo AS para, to_char(l.registrado_em,'DD/MM HH24:MI') AS quando
  FROM log_atendimento l
 ORDER BY l.id_log DESC LIMIT 10;

\echo ''
\echo '=== 12. Plano de execucao: o indice esta sendo usado? ==='
EXPLAIN (COSTS OFF)
SELECT * FROM atendimento WHERE id_cliente = 1;

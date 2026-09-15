-- =============================================================================
-- V021 - VISAO vw_pessoas_atendentes
-- =============================================================================
-- Junta os dados gerais da pessoa com os dados do vinculo empregaticio,
-- poupando o JOIN em toda consulta de recepcao.
--
-- A coluna "tambem_e_cliente" evidencia a especializacao sobreposta exigida
-- no enunciado: mostra de imediato quais atendentes tambem sao tutores.
-- =============================================================================

CREATE OR REPLACE VIEW vw_pessoas_atendentes AS
SELECT
    p.id_pessoa,
    p.cpf,
    p.nome || ' ' || p.sobrenome                      AS nome_completo,
    p.email,
    p.telefone,
    a.matricula,
    a.turno,
    a.data_admissao,
    a.data_demissao,
    CASE WHEN a.data_demissao IS NULL
         THEN 'ATIVO' ELSE 'DESLIGADO' END            AS situacao,
    EXTRACT(YEAR FROM age(CURRENT_DATE, p.data_nascimento))::INTEGER AS idade,
    EXISTS (SELECT 1 FROM cliente c WHERE c.id_pessoa = p.id_pessoa)  AS tambem_e_cliente
FROM pessoa    p
JOIN atendente a ON a.id_pessoa = p.id_pessoa;

COMMENT ON VIEW vw_pessoas_atendentes
    IS 'Atendentes com dados pessoais consolidados e indicacao de dupla condicao (atendente/cliente)';

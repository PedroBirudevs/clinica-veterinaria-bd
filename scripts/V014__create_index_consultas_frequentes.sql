-- =============================================================================
-- V014 - Indices de apoio as consultas mais frequentes
-- =============================================================================
-- O PostgreSQL ja cria indice automaticamente para PK e UNIQUE, mas NAO para
-- chave estrangeira. Sem estes indices, toda consulta "atendimentos deste
-- cliente" faria varredura sequencial na tabela inteira (Seq Scan).
--
-- Todos usam IF NOT EXISTS para permitir reexecucao do script.
-- =============================================================================

-- Busca de atendimentos por cliente, animal e periodo (relatorios do dia)
CREATE INDEX IF NOT EXISTS idx_atendimento_cliente    ON atendimento (id_cliente);
CREATE INDEX IF NOT EXISTS idx_atendimento_animal     ON atendimento (id_animal);
CREATE INDEX IF NOT EXISTS idx_atendimento_data       ON atendimento (data_hora DESC);
CREATE INDEX IF NOT EXISTS idx_atendimento_veterinario ON atendimento (id_veterinario);

-- Listagem de animais por tutor (tela de prontuario)
CREATE INDEX IF NOT EXISTS idx_animal_cliente ON animal (id_cliente);
CREATE INDEX IF NOT EXISTS idx_animal_especie ON animal (id_especie);

-- Itens de um atendimento
CREATE INDEX IF NOT EXISTS idx_atend_produto_produto ON atendimento_produto (id_produto);
CREATE INDEX IF NOT EXISTS idx_atend_servico_servico ON atendimento_servico (id_servico);

-- Busca de pessoa por nome (indice parcial: so os produtos ativos importam)
CREATE INDEX IF NOT EXISTS idx_pessoa_nome_completo
    ON pessoa (lower(nome), lower(sobrenome));

CREATE INDEX IF NOT EXISTS idx_produto_ativo
    ON produto (id_tipo_produto) WHERE ativo = TRUE;

COMMENT ON INDEX idx_produto_ativo
    IS 'Indice parcial: consultas de catalogo so buscam produtos ativos';

-- =============================================================================
-- V009 - Tabela PRODUTO
-- =============================================================================
-- Item fisico vendido ou consumido no atendimento (medicamento, racao, vacina).
--
-- Atende o requisito "produtos registrados por tipo, marca, descricao e valor
-- de compra". O valor_venda foi acrescentado porque sem ele nao ha como apurar
-- a margem da clinica - o enunciado pede valor de compra, mas o atendimento
-- precisa cobrar algum valor.
-- =============================================================================

CREATE TABLE IF NOT EXISTS produto (
    id_produto      INTEGER       GENERATED ALWAYS AS IDENTITY,
    id_tipo_produto INTEGER       NOT NULL,
    id_marca        INTEGER       NOT NULL,
    descricao       VARCHAR(120)  NOT NULL,
    unidade_medida  VARCHAR(10)   NOT NULL DEFAULT 'UN',
    valor_compra    NUMERIC(10,2) NOT NULL,
    valor_venda     NUMERIC(10,2) NOT NULL,
    estoque_atual   INTEGER       NOT NULL DEFAULT 0,
    estoque_minimo  INTEGER       NOT NULL DEFAULT 0,
    ativo           BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_produto
        PRIMARY KEY (id_produto),

    CONSTRAINT fk_produto_tipo
        FOREIGN KEY (id_tipo_produto) REFERENCES tipo_produto (id_tipo_produto)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_produto_marca
        FOREIGN KEY (id_marca) REFERENCES marca (id_marca)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT uq_produto_descricao_marca
        UNIQUE (descricao, id_marca),

    CONSTRAINT ck_produto_valor_compra
        CHECK (valor_compra >= 0),

    CONSTRAINT ck_produto_valor_venda
        CHECK (valor_venda >= 0),

    -- Regra de negocio: a clinica nao vende abaixo do custo
    CONSTRAINT ck_produto_margem_nao_negativa
        CHECK (valor_venda >= valor_compra),

    CONSTRAINT ck_produto_estoque_nao_negativo
        CHECK (estoque_atual >= 0),

    CONSTRAINT ck_produto_estoque_minimo
        CHECK (estoque_minimo >= 0),

    CONSTRAINT ck_produto_unidade
        CHECK (unidade_medida IN ('UN','KG','G','L','ML','CX','FR','CP'))
);

COMMENT ON TABLE  produto                IS 'Itens fisicos consumidos ou vendidos no atendimento';
COMMENT ON COLUMN produto.estoque_atual  IS 'Atualizado automaticamente pelo trigger de baixa de estoque';
COMMENT ON CONSTRAINT ck_produto_margem_nao_negativa ON produto
    IS 'Impede cadastro com prejuizo por erro de digitacao';

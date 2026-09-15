-- =============================================================================
-- V012 - Tabela ATENDIMENTO_PRODUTO (associativa N:N)
-- =============================================================================
-- Resolve o relacionamento N:N entre atendimento e produto, exigido pelo
-- requisito "os produtos e servicos utilizados com seus respectivos valores".
--
-- O valor_unitario e COPIADO do produto no momento do registro, nao lido por
-- JOIN. Isso e deliberado: se a clinica reajustar a tabela de precos amanha,
-- os atendimentos de ontem devem continuar mostrando o valor cobrado na epoca.
-- E o mesmo principio de uma nota fiscal.
-- =============================================================================

CREATE TABLE IF NOT EXISTS atendimento_produto (
    id_atendimento  INTEGER       NOT NULL,
    id_produto      INTEGER       NOT NULL,
    quantidade      NUMERIC(8,3)  NOT NULL DEFAULT 1,
    valor_unitario  NUMERIC(10,2) NOT NULL,

    -- Chave primaria composta: um produto aparece uma vez por atendimento
    CONSTRAINT pk_atendimento_produto
        PRIMARY KEY (id_atendimento, id_produto),

    CONSTRAINT fk_atend_produto_atendimento
        FOREIGN KEY (id_atendimento) REFERENCES atendimento (id_atendimento)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_atend_produto_produto
        FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_atend_produto_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_atend_produto_valor
        CHECK (valor_unitario >= 0)
);

COMMENT ON TABLE  atendimento_produto                IS 'Associativa N:N - produtos consumidos no atendimento';
COMMENT ON COLUMN atendimento_produto.valor_unitario IS 'Valor congelado no momento do registro, como em nota fiscal';

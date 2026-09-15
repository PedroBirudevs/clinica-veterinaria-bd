-- =============================================================================
-- V003 - Tabela ATENDENTE (especializacao de PESSOA)
-- =============================================================================
-- Funcionario da recepcao que registra os atendimentos.
--
-- Especializacao SOBREPOSTA: a mesma pessoa pode existir em cliente e em
-- atendente ao mesmo tempo - e exatamente o requisito "atendentes tambem
-- podem ser clientes". Nao ha restricao impedindo isso.
--
-- ON DELETE RESTRICT em atendimento (V011) protege o historico: nao se apaga
-- um atendente que ja atendeu alguem. Aqui o CASCADE vem de pessoa.
-- =============================================================================

CREATE TABLE IF NOT EXISTS atendente (
    id_pessoa     INTEGER      NOT NULL,
    matricula     VARCHAR(12)  NOT NULL,
    data_admissao DATE         NOT NULL,
    data_demissao DATE,
    turno         VARCHAR(10)  NOT NULL DEFAULT 'MANHA',

    CONSTRAINT pk_atendente
        PRIMARY KEY (id_pessoa),

    CONSTRAINT fk_atendente_pessoa
        FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT uq_atendente_matricula
        UNIQUE (matricula),

    CONSTRAINT ck_atendente_turno
        CHECK (turno IN ('MANHA','TARDE','NOITE','INTEGRAL')),

    -- Nao se demite alguem antes de admitir
    CONSTRAINT ck_atendente_periodo_vinculo
        CHECK (data_demissao IS NULL OR data_demissao >= data_admissao),

    CONSTRAINT ck_atendente_admissao_passado
        CHECK (data_admissao <= CURRENT_DATE)
);

COMMENT ON TABLE  atendente               IS 'Especializacao de pessoa: funcionario da recepcao';
COMMENT ON COLUMN atendente.data_demissao IS 'NULL indica vinculo ativo';

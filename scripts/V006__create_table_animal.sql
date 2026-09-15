-- =============================================================================
-- V006 - Tabela ANIMAL
-- =============================================================================
-- O paciente da clinica. Depende de um cliente (tutor) - relacionamento 1:N,
-- ja que um tutor pode ter varios animais, mas cada animal tem um tutor
-- responsavel.
--
-- ON DELETE RESTRICT: nao se apaga um tutor que ainda tem animal cadastrado.
-- Isso protege o prontuario do animal de virar registro orfao.
-- =============================================================================

CREATE TABLE IF NOT EXISTS animal (
    id_animal       INTEGER      GENERATED ALWAYS AS IDENTITY,
    nome            VARCHAR(60)  NOT NULL,
    id_especie      INTEGER      NOT NULL,
    id_cliente      INTEGER      NOT NULL,
    sexo            CHAR(1)      NOT NULL,
    data_nascimento DATE,
    peso_kg         NUMERIC(6,3),
    castrado        BOOLEAN      NOT NULL DEFAULT FALSE,
    observacoes     TEXT,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_animal
        PRIMARY KEY (id_animal),

    CONSTRAINT fk_animal_especie
        FOREIGN KEY (id_especie) REFERENCES especie (id_especie)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_animal_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente (id_pessoa)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    -- M = macho, F = femea, I = indefinido (filhotes muito novos)
    CONSTRAINT ck_animal_sexo
        CHECK (sexo IN ('M','F','I')),

    CONSTRAINT ck_animal_peso_positivo
        CHECK (peso_kg IS NULL OR (peso_kg > 0 AND peso_kg <= 1000)),

    CONSTRAINT ck_animal_nascimento_passado
        CHECK (data_nascimento IS NULL OR data_nascimento <= CURRENT_DATE),

    CONSTRAINT ck_animal_nome_nao_vazio
        CHECK (length(trim(nome)) > 0),

    -- O mesmo tutor nao registra dois animais com o mesmo nome
    CONSTRAINT uq_animal_nome_por_tutor
        UNIQUE (id_cliente, nome)
);

COMMENT ON TABLE  animal             IS 'Paciente da clinica, sempre vinculado a um tutor';
COMMENT ON COLUMN animal.ativo       IS 'FALSE em caso de obito ou transferencia - preserva o historico';
COMMENT ON COLUMN animal.data_nascimento IS 'Opcional: animais resgatados costumam ter idade desconhecida';

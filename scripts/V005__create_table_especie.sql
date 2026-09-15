-- =============================================================================
-- V005 - Tabela ESPECIE
-- =============================================================================
-- O enunciado pede "especie/classe" no animal. Guardar isso como texto livre
-- dentro de ANIMAL causaria redundancia e erro de digitacao ("Canino",
-- "canino", "Cachorro"), quebrando qualquer relatorio por especie.
-- Extrair para tabela propria e aplicacao da 3FN: classe depende da especie,
-- nao do animal.
-- =============================================================================

CREATE TABLE IF NOT EXISTS especie (
    id_especie   INTEGER     GENERATED ALWAYS AS IDENTITY,
    nome         VARCHAR(40) NOT NULL,
    classe       VARCHAR(30) NOT NULL,
    porte_padrao VARCHAR(10),

    CONSTRAINT pk_especie
        PRIMARY KEY (id_especie),

    CONSTRAINT uq_especie_nome
        UNIQUE (nome),

    CONSTRAINT ck_especie_classe
        CHECK (classe IN ('MAMIFERO','AVE','REPTIL','ANFIBIO','PEIXE')),

    CONSTRAINT ck_especie_porte
        CHECK (porte_padrao IS NULL OR porte_padrao IN ('PEQUENO','MEDIO','GRANDE'))
);

COMMENT ON TABLE especie IS 'Catalogo de especies atendidas - normaliza o campo especie/classe do animal';

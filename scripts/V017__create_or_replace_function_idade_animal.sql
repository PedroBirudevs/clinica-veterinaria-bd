-- =============================================================================
-- V017 - FUNCAO idade_animal
-- =============================================================================
-- Converte data de nascimento em idade legivel ("3 anos e 2 meses").
-- Usada nas visoes de prontuario.
--
-- IMMUTABLE nao pode ser usado aqui porque a funcao depende de CURRENT_DATE,
-- que muda a cada dia. Por isso e marcada como STABLE.
-- =============================================================================

CREATE OR REPLACE FUNCTION idade_animal(p_data_nascimento DATE)
RETURNS VARCHAR
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_anos  INTEGER;
    v_meses INTEGER;
BEGIN
    IF p_data_nascimento IS NULL THEN
        RETURN 'Idade desconhecida';
    END IF;

    v_anos  := EXTRACT(YEAR  FROM age(CURRENT_DATE, p_data_nascimento));
    v_meses := EXTRACT(MONTH FROM age(CURRENT_DATE, p_data_nascimento));

    IF v_anos = 0 AND v_meses = 0 THEN
        RETURN 'Menos de 1 mes';
    ELSIF v_anos = 0 THEN
        RETURN v_meses || CASE WHEN v_meses = 1 THEN ' mes' ELSE ' meses' END;
    ELSIF v_meses = 0 THEN
        RETURN v_anos || CASE WHEN v_anos = 1 THEN ' ano' ELSE ' anos' END;
    ELSE
        RETURN v_anos  || CASE WHEN v_anos  = 1 THEN ' ano e '  ELSE ' anos e ' END ||
               v_meses || CASE WHEN v_meses = 1 THEN ' mes'     ELSE ' meses'   END;
    END IF;
END;
$$;

COMMENT ON FUNCTION idade_animal(DATE) IS 'Formata a idade do animal em texto legivel';

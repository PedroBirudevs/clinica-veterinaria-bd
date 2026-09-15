-- =============================================================================
-- V018 - TRIGGER de validacao: o cliente do atendimento e o tutor do animal
-- =============================================================================
-- Regra de negocio que NENHUMA restricao declarativa consegue expressar:
-- uma CHECK so enxerga colunas da propria linha, e aqui e preciso consultar
-- outra tabela (animal) para saber quem e o tutor.
--
-- Sem este gatilho, seria possivel registrar a consulta do cachorro da Maria
-- em nome do Joao - erro que so apareceria na hora de cobrar.
--
-- Tambem impede atendimento para animal inativo (obito/transferencia).
-- =============================================================================

CREATE OR REPLACE FUNCTION fn_valida_tutor_do_animal()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_tutor    INTEGER;
    v_ativo       BOOLEAN;
    v_nome_animal VARCHAR(60);
BEGIN
    SELECT id_cliente, ativo, nome
      INTO v_id_tutor, v_ativo, v_nome_animal
      FROM animal
     WHERE id_animal = NEW.id_animal;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Animal % nao existe', NEW.id_animal;
    END IF;

    IF v_id_tutor <> NEW.id_cliente THEN
        RAISE EXCEPTION
            'Inconsistencia: o animal % (id %) pertence ao cliente %, nao ao cliente %',
            v_nome_animal, NEW.id_animal, v_id_tutor, NEW.id_cliente
            USING HINT = 'Verifique o tutor responsavel antes de registrar o atendimento';
    END IF;

    IF NOT v_ativo THEN
        RAISE EXCEPTION 'O animal % (id %) esta inativo e nao pode receber atendimento',
            v_nome_animal, NEW.id_animal;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_valida_tutor_do_animal ON atendimento;

CREATE TRIGGER tg_valida_tutor_do_animal
    BEFORE INSERT OR UPDATE OF id_animal, id_cliente ON atendimento
    FOR EACH ROW
    EXECUTE FUNCTION fn_valida_tutor_do_animal();

COMMENT ON FUNCTION fn_valida_tutor_do_animal()
    IS 'Garante integridade semantica entre atendimento.id_cliente e animal.id_cliente';

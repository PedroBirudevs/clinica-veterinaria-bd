-- =============================================================================
-- V020 - Auditoria de mudanca de status do atendimento
-- =============================================================================
-- Registra quem mudou o status de um atendimento e quando.
-- Em ambiente clinico isso tem peso legal: cancelar um atendimento apos a
-- cobranca precisa deixar rastro.
-- =============================================================================

CREATE TABLE IF NOT EXISTS log_atendimento (
    id_log         INTEGER      GENERATED ALWAYS AS IDENTITY,
    id_atendimento INTEGER      NOT NULL,
    status_antigo  VARCHAR(12),
    status_novo    VARCHAR(12)  NOT NULL,
    usuario_banco  VARCHAR(60)  NOT NULL DEFAULT CURRENT_USER,
    registrado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_log_atendimento PRIMARY KEY (id_log),

    CONSTRAINT fk_log_atendimento
        FOREIGN KEY (id_atendimento) REFERENCES atendimento (id_atendimento)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE OR REPLACE FUNCTION fn_log_status_atendimento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Grava somente quando o status realmente mudou
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_atendimento (id_atendimento, status_antigo, status_novo)
        VALUES (NEW.id_atendimento, NULL, NEW.status);
    ELSIF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO log_atendimento (id_atendimento, status_antigo, status_novo)
        VALUES (NEW.id_atendimento, OLD.status, NEW.status);
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_log_status_atendimento ON atendimento;

CREATE TRIGGER tg_log_status_atendimento
    AFTER INSERT OR UPDATE OF status ON atendimento
    FOR EACH ROW
    EXECUTE FUNCTION fn_log_status_atendimento();

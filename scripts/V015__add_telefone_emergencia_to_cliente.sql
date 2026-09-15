-- =============================================================================
-- V015 - Evolucao de esquema: telefone de emergencia do tutor
-- =============================================================================
-- Demonstra manutencao de esquema em base ja populada (DDL incremental).
--
-- Motivacao real: em caso de intercorrencia cirurgica, a clinica precisa de um
-- contato alternativo. A coluna nasce anulavel justamente porque ja existem
-- registros gravados - adicionar NOT NULL sem DEFAULT em tabela populada
-- quebraria o ALTER.
--
-- ADD COLUMN IF NOT EXISTS garante que o script pode rodar varias vezes.
-- =============================================================================

ALTER TABLE cliente
    ADD COLUMN IF NOT EXISTS telefone_emergencia VARCHAR(15);

ALTER TABLE cliente
    ADD COLUMN IF NOT EXISTS contato_emergencia  VARCHAR(80);

COMMENT ON COLUMN cliente.telefone_emergencia
    IS 'Contato alternativo para intercorrencias durante procedimentos';

-- Bloco condicional: adiciona a restricao apenas se ela ainda nao existir,
-- ja que ALTER TABLE ... ADD CONSTRAINT nao aceita IF NOT EXISTS.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_cliente_contato_emergencia_completo'
    ) THEN
        ALTER TABLE cliente
            ADD CONSTRAINT ck_cliente_contato_emergencia_completo
            CHECK (
                (telefone_emergencia IS NULL AND contato_emergencia IS NULL)
                OR
                (telefone_emergencia IS NOT NULL AND contato_emergencia IS NOT NULL)
            );
    END IF;
END $$;

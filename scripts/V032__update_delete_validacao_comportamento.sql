-- =============================================================================
-- V032 - Comandos UPDATE e DELETE para validar o comportamento do banco
-- =============================================================================
-- Exigencia do enunciado: "Execute comandos UPDATE e DELETE para validar o
-- comportamento do banco de dados."
--
-- Cada bloco abaixo altera dados reais e demonstra um efeito colateral
-- projetado: gatilho disparando, cascata propagando ou restricao protegendo.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. UPDATE simples: correcao de peso apos pesagem na balanca
-- -----------------------------------------------------------------------------
UPDATE animal
   SET peso_kg = 29.100
 WHERE nome = 'Thor'
   AND id_cliente = (SELECT id_pessoa FROM pessoa WHERE cpf = '11122233344');

-- -----------------------------------------------------------------------------
-- 2. UPDATE que dispara o gatilho de auditoria (V020)
--    Fecha o atendimento que estava ABERTO. Uma linha nova aparece
--    automaticamente em log_atendimento, sem nenhum INSERT explicito.
-- -----------------------------------------------------------------------------
UPDATE atendimento
   SET status      = 'CONCLUIDO',
       diagnostico = 'Displasia coxofemoral confirmada por radiografia. '
                     || 'Iniciado condroprotetor.'
 WHERE descritivo LIKE 'Dificuldade de locomocao%'
   AND status = 'ABERTO';

-- -----------------------------------------------------------------------------
-- 3. UPDATE que dispara o gatilho de estoque (V019)
--    Ao corrigir a quantidade de 1 para 2, o gatilho retira do estoque
--    apenas a DIFERENCA (1 unidade), nao as 2 unidades cheias.
-- -----------------------------------------------------------------------------
UPDATE atendimento_produto
   SET quantidade = 2
 WHERE id_produto = (SELECT id_produto FROM produto
                      WHERE descricao = 'Antibiotico amoxicilina 500mg')
   AND id_atendimento IN (SELECT id_atendimento FROM atendimento
                           WHERE descritivo LIKE 'Tutor relata coceira%');

-- -----------------------------------------------------------------------------
-- 4. UPDATE em massa: reajuste de 8% na tabela de servicos
--    Demonstra alteracao de varias linhas por um unico comando.
--    Os atendimentos JA REGISTRADOS nao mudam de valor, porque
--    atendimento_servico guardou o valor da epoca (ver comentario em V013).
-- -----------------------------------------------------------------------------
UPDATE servico
   SET valor_padrao = ROUND(valor_padrao * 1.08, 2)
 WHERE ativo = TRUE;

-- -----------------------------------------------------------------------------
-- 5. UPDATE logico em vez de DELETE fisico (soft delete)
--    Um veterinario que se desligou nao pode ser apagado: seus atendimentos
--    passados fazem parte do prontuario. Inativa-se o registro.
-- -----------------------------------------------------------------------------
UPDATE veterinario
   SET ativo = FALSE
 WHERE crmv = 'CRMV-RO 3456';

-- -----------------------------------------------------------------------------
-- 6. DELETE com CASCADE: remover item devolve o estoque
--    O gatilho V019 trata o evento DELETE somando a quantidade de volta.
-- -----------------------------------------------------------------------------
DELETE FROM atendimento_produto
 WHERE id_produto = (SELECT id_produto FROM produto
                      WHERE descricao = 'Colar elizabetano tamanho M')
   AND id_atendimento IN (SELECT id_atendimento FROM atendimento
                           WHERE descritivo LIKE 'Castracao eletiva%');

-- -----------------------------------------------------------------------------
-- 7. DELETE de atendimento cancelado
--    A FK de atendimento_produto e atendimento_servico usa ON DELETE CASCADE:
--    os itens somem junto, sem necessidade de apaga-los antes.
--    O registro em log_atendimento tambem e removido em cascata.
-- -----------------------------------------------------------------------------
DELETE FROM atendimento
 WHERE status = 'CANCELADO'
   AND data_hora < CURRENT_DATE - INTERVAL '3 days';

-- -----------------------------------------------------------------------------
-- 8. DELETE de pessoa: cascata percorre as especializacoes
--    Inserimos uma pessoa descartavel so para observar o efeito.
-- -----------------------------------------------------------------------------
INSERT INTO pessoa (cpf, nome, sobrenome, email, telefone, data_nascimento)
VALUES ('12312312312', 'Teste', 'Descarte', 'teste.descarte@email.com',
        '69999999999', '1999-01-01')
ON CONFLICT (cpf) DO NOTHING;

INSERT INTO cliente (id_pessoa, logradouro, numero, bairro, cidade, uf, cep)
SELECT id_pessoa, 'Rua Temporaria', '1', 'Centro', 'Porto Velho', 'RO', '76800000'
  FROM pessoa WHERE cpf = '12312312312'
ON CONFLICT (id_pessoa) DO NOTHING;

-- Apagar a pessoa remove tambem a linha em cliente (ON DELETE CASCADE da V002)
DELETE FROM pessoa WHERE cpf = '12312312312';

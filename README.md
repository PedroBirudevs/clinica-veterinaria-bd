# Sistema de Gestão de Clínica Veterinária

## Sobre o projeto

Tema: Clínica veterinária

Objetivo: Sistema de banco de dados para uma clínica veterinária, cobrindo o atendimento clínico dos animais e a venda de produtos e serviços. Controla estoque, guarda o histórico de preço cobrado em cada atendimento e não deixa cadastrar dado inconsistente.

Público-alvo: Atendentes (cadastro de tutor e animal, agenda), veterinários (prontuário e diagnóstico) e a gestão da clínica (faturamento, estoque).

Observação: o mesmo atendente também pode ser cliente da clínica (levar o próprio animal pra atender), por isso pessoa não é uma tabela só de cliente — ela pode virar cliente, atendente e/ou veterinário através de tabelas ligadas por id_pessoa.

## Modelo de dados

```mermaid
erDiagram
    PESSOA ||--o| CLIENTE : "pode ser"
    PESSOA ||--o| ATENDENTE : "pode ser"
    PESSOA ||--o| VETERINARIO : "pode ser"

    CLIENTE ||--o{ ANIMAL : "é tutor de"
    ESPECIE ||--o{ ANIMAL : classifica

    CLIENTE ||--o{ ATENDIMENTO : "solicita"
    ATENDENTE ||--o{ ATENDIMENTO : registra
    VETERINARIO |o--o{ ATENDIMENTO : "responde por"
    ANIMAL ||--o{ ATENDIMENTO : recebe

    ATENDIMENTO ||--o{ ATENDIMENTO_PRODUTO : consome
    PRODUTO ||--o{ ATENDIMENTO_PRODUTO : "é consumido em"
    ATENDIMENTO ||--o{ ATENDIMENTO_SERVICO : inclui
    SERVICO ||--o{ ATENDIMENTO_SERVICO : "é prestado em"
    VETERINARIO |o--o{ ATENDIMENTO_SERVICO : executa

    TIPO_PRODUTO ||--o{ PRODUTO : classifica
    MARCA ||--o{ PRODUTO : fabrica

    ATENDIMENTO ||--o{ LOG_ATENDIMENTO : audita

    CLIENTE ||--o{ PONTUACAO : acumula
    ATENDIMENTO |o--o{ PONTUACAO : gera
    CLIENTE ||--o{ CLIENTE_CONQUISTA : desbloqueia
    CONQUISTA ||--o{ CLIENTE_CONQUISTA : "é obtida em"

    PESSOA {
        int id_pessoa PK
        char cpf UK "11 dígitos"
        varchar nome
        varchar sobrenome
        varchar email UK
        varchar telefone
        date data_nascimento
    }

    CLIENTE {
        int id_pessoa PK,FK
        varchar logradouro
        varchar numero
        varchar bairro
        varchar cidade
        char uf
        char cep
        varchar banco "nulo"
        varchar agencia "nulo"
        varchar conta "nulo"
        varchar chave_pix "nulo"
    }

    ATENDENTE {
        int id_pessoa PK,FK
        varchar matricula UK
        date data_admissao
        date data_demissao "nulo = ativo"
        varchar turno
    }

    VETERINARIO {
        int id_pessoa PK,FK
        varchar crmv UK
        varchar especialidade
        date data_formatura
        bool ativo
    }

    ESPECIE {
        int id_especie PK
        varchar nome UK
        varchar classe
        varchar porte_padrao
    }

    ANIMAL {
        int id_animal PK
        varchar nome
        int id_especie FK
        int id_cliente FK
        char sexo "M/F/I"
        date data_nascimento "nulo"
        numeric peso_kg
        bool castrado
        bool ativo
    }

    ATENDIMENTO {
        int id_atendimento PK
        timestamp data_hora
        int id_atendente FK
        int id_cliente FK
        int id_animal FK
        int id_veterinario FK "nulo"
        text descritivo
        text diagnostico
        varchar status
        numeric desconto
    }

    PRODUTO {
        int id_produto PK
        int id_tipo_produto FK
        int id_marca FK
        varchar descricao
        numeric valor_compra
        numeric valor_venda
        int estoque_atual
        int estoque_minimo
        bool ativo
    }

    SERVICO {
        int id_servico PK
        varchar nome UK
        numeric valor_padrao
        int duracao_minutos
        bool exige_veterinario
        bool ativo
    }

    ATENDIMENTO_PRODUTO {
        int id_atendimento PK,FK
        int id_produto PK,FK
        numeric quantidade
        numeric valor_unitario "congelado"
    }

    ATENDIMENTO_SERVICO {
        int id_atendimento PK,FK
        int id_servico PK,FK
        int quantidade
        numeric valor_unitario "congelado"
        int id_executante FK
    }

    TIPO_PRODUTO {
        int id_tipo_produto PK
        varchar nome UK
        bool exige_receita
    }

    MARCA {
        int id_marca PK
        varchar nome UK
        varchar fabricante
    }

    LOG_ATENDIMENTO {
        int id_log PK
        int id_atendimento FK
        varchar status_antigo
        varchar status_novo
        varchar usuario_banco
        timestamp registrado_em
    }

    NIVEL {
        int id_nivel PK
        varchar nome UK
        int pontos_minimos UK
    }

    CONQUISTA {
        int id_conquista PK
        varchar nome UK
        text descricao
        int pontos_bonus
    }

    PONTUACAO {
        int id_pontuacao PK
        int id_cliente FK
        int id_atendimento FK "nulo"
        int pontos
        varchar motivo
        timestamp registrado_em
    }

    CLIENTE_CONQUISTA {
        int id_cliente PK,FK
        int id_conquista PK,FK
        timestamp obtida_em
    }
```

## Inovação: programa de fidelidade

Gamificação para o tutor (cliente): a cada atendimento ele ganha 10 pontos, desbloqueia conquistas (Primeira consulta, Cliente fiel, Família grande) que dão pontos extras e sobe de nível (Bronze 0, Prata 50, Ouro 150). A visão `vw_ranking_clientes` mostra o ranking com posição, pontos e nível atual.

A tabela `nivel` fica fora dos relacionamentos de propósito: o nível é calculado comparando o total de pontos com `pontos_minimos`.

## Scripts

Os scripts estão na pasta scripts/, na ordem que devem ser executados:

1. create_table_pessoa.sql
2. create_table_cliente.sql
3. create_table_atendente.sql
4. create_table_veterinario.sql
5. create_table_especie.sql
6. create_table_animal.sql
7. create_table_tipo_produto.sql
8. create_table_marca.sql
9. create_table_produto.sql
10. create_table_servico.sql
11. create_table_atendimento.sql
12. create_table_atendimento_produto.sql
13. create_table_atendimento_servico.sql
14. create_index_consultas_frequentes.sql
15. add_telefone_emergencia_to_cliente.sql
16. create_or_replace_function_calcula_total_atendimento.sql
17. create_or_replace_function_idade_animal.sql
18. create_trigger_valida_tutor_do_animal.sql
19. create_trigger_baixa_estoque_produto.sql
20. create_trigger_log_auditoria_atendimento.sql
21. create_view_pessoas_atendentes.sql
22. create_view_atendimentos_detalhados.sql
23. create_view_faturamento_por_mes.sql
24. create_view_prontuario_animal.sql
25. create_or_replace_procedure_registra_atendimento.sql
26. create_or_replace_procedure_repoe_estoque.sql
27. insert_into_tabelas_basicas.sql
28. insert_into_pessoa.sql
29. insert_into_animal.sql
30. insert_into_produto_e_servico.sql
31. insert_into_atendimento.sql
32. update_delete_validacao_comportamento.sql
33. create_table_nivel.sql
34. create_table_conquista.sql
35. create_table_pontuacao.sql
36. create_table_cliente_conquista.sql
37. create_view_ranking_clientes.sql
38. insert_into_gamificacao.sql

## Protótipo

Protótipo visual do sistema em `prototipo/index.html` (HTML, CSS e JavaScript puro, com dados fictícios). Não precisa instalar nada nem conectar ao banco: basta abrir o arquivo com dois cliques ou arrastar para o navegador. Qualquer usuário e senha entram. Funciona também no celular.

Telas: início, pessoas, atendimentos e produtos, fidelidade (pontos, nível, conquistas e ranking). O que for cadastrado fica só na memória e some ao recarregar a página.

Autor Pedro Henrique Silva - [@PedroBirudevs] -- LINK DO REPOSITORIO --
[https://github.com/PedroBirudevs/clinica-veterinaria-bd](https://github.com/PedroBirudevs/clinica-veterinaria-bd)

Outros integrantes do Grupo: João Paulo Dias, João Victor, Maykon, Saymon.

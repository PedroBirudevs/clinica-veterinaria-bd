# Passo a passo da entrega

## 1. Criar o repositório no GitHub

Acesse github.com, clique em **New repository** e use:

- **Nome:** `clinica-veterinaria-bd`
- **Visibilidade:** Público (para o professor conseguir abrir)
- **Não marque** "Add a README file" — o README já está pronto aqui

## 2. Subir os arquivos

### Opção A — pelo navegador (mais simples)

1. No repositório recém-criado, clique em **uploading an existing file**
2. Arraste a pasta inteira `clinica-veterinaria-bd`
3. Na caixa de commit, escreva:
   ```
   Projeto de banco de dados: sistema de clinica veterinaria em PostgreSQL
   ```
4. Clique em **Commit changes**

### Opção B — pelo terminal

```bash
cd clinica-veterinaria-bd
git init
git add .
git commit -m "Projeto de banco de dados: sistema de clinica veterinaria em PostgreSQL"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/clinica-veterinaria-bd.git
git push -u origin main
```

## 3. Conferir antes de entregar

Abra o repositório no navegador e verifique:

- [ ] O README aparece formatado na página inicial
- [ ] O **diagrama Mermaid aparece desenhado**, não como bloco de código
      (o GitHub renderiza Mermaid sozinho; se aparecer texto, revise se a
      cerca do bloco está escrita como ```mermaid)
- [ ] A pasta `scripts/` mostra os 32 arquivos em ordem
- [ ] As pastas `testes/` e `consultas/` estão lá

## 4. Entregar

Copie o link do repositório (ex.: `https://github.com/SEU_USUARIO/clinica-veterinaria-bd`)
e poste no ambiente da disciplina.

---

## Se o professor pedir para rodar na hora

```bash
createdb clinica_vet

for f in scripts/V*.sql; do
  psql -d clinica_vet -v ON_ERROR_STOP=1 -f "$f" || break
done

psql -d clinica_vet -f testes/teste_restricoes.sql
psql -d clinica_vet -f consultas/consultas_exemplo.sql
```

## Pontos para destacar na apresentação

1. **A generalização de PESSOA** — é a decisão que resolve o requisito
   "atendentes também podem ser clientes" sem duplicar dado nenhum.
   Mostre a consulta 1 do arquivo de consultas.

2. **O gatilho de validação do tutor** — explique por que uma restrição
   `CHECK` não daria conta: ela só enxerga a própria linha, e a regra
   precisa consultar outra tabela.

3. **O teste de atomicidade** — rode `teste_procedures.sql` e mostre que,
   quando o estoque acaba no meio da operação, o atendimento inteiro é
   desfeito. É a letra A do ACID acontecendo na tela.

4. **Valores congelados** — o reajuste de 8% em `V032` não altera os
   atendimentos já registrados. Mesma lógica de uma nota fiscal.

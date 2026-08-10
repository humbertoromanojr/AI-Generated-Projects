# Sistema de Finanças Pessoais

## Objetivo

Desenvolver um sistema web para gerenciamento de finanças pessoais utilizando apenas HTML, CSS e JavaScript.

O sistema deverá permitir cadastrar, visualizar, editar e excluir lançamentos financeiros.

---

# Estrutura do Sistema

O sistema será composto por três páginas.

## Página Inicial

Arquivo:

index.html

Responsável por:

- Dashboard financeiro
- Resumo de receitas
- Resumo de despesas
- Saldo atual
- Lista dos lançamentos
- Botão Novo Lançamento

Cada lançamento deverá possuir:

- Editar
- Excluir (ícone de lixeira)

---

## Página Cadastro

Arquivo:

cadastro.html

Campos obrigatórios:

- Tipo (Receita ou Despesa)
- Descrição
- Categoria
- Valor
- Data

Botões:

- Salvar
- Cancelar

Após salvar retornar para a página inicial.

---

## Página Alteração

Arquivo:

editar.html

Ao abrir deverá carregar automaticamente os dados do lançamento.

Campos:

- Tipo
- Descrição
- Categoria
- Valor
- Data

Botões:

- Salvar Alterações
- Cancelar
- Excluir

O botão Excluir deverá possuir:

- Ícone de lixeira
- Cor vermelha
- Confirmação antes da exclusão

Mensagem:

"Tem certeza que deseja excluir este lançamento?"

Após excluir retornar para a página inicial.

---

# Dashboard

Exibir:

- Total de Receitas
- Total de Despesas
- Saldo Atual

---

# Lista de Lançamentos

Cada registro deverá apresentar:

- Categoria
- Descrição
- Valor
- Tipo
- Data
- Botão Editar
- Botão Excluir

---

# Armazenamento

Persistir os dados utilizando LocalStorage.

Cada lançamento deverá possuir um ID único.

---

# Requisitos

O sistema deverá permitir:

- Criar lançamento
- Editar lançamento
- Excluir lançamento
- Visualizar lançamentos
- Atualizar automaticamente os totais financeiros

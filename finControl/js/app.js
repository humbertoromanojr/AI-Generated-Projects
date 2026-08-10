import { listar, excluir } from "./storage.js";

const MENSAGENS = {
  salvo: "Lançamento salvo com sucesso!",
  editado: "Alterações salvas com sucesso!",
  excluido: "Lançamento excluído com sucesso!",
  "nao-encontrado": "Lançamento não encontrado.",
};

const formatadorMoeda = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
});

const listaEl = document.getElementById("lista-lancamentos");
const listaVaziaEl = document.getElementById("lista-vazia");
const totalReceitasEl = document.getElementById("total-receitas");
const totalDespesasEl = document.getElementById("total-despesas");
const saldoAtualEl = document.getElementById("saldo-atual");
const toastEl = document.getElementById("toast");

let timerToast = null;

function formatarMoeda(valor) {
  return formatadorMoeda.format(valor);
}

function formatarData(dataISO) {
  if (!dataISO) return "—";
  const [ano, mes, dia] = dataISO.split("-");
  return `${dia}/${mes}/${ano}`;
}

function escaparHTML(texto) {
  return String(texto).replace(/[&<>"']/g, (caractere) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  })[caractere]);
}

function rotuloTipo(tipo) {
  return tipo === "receita" ? "Receita" : "Despesa";
}

function criarLinha(lancamento) {
  const descricao = escaparHTML(lancamento.descricao);
  const linha = document.createElement("article");
  linha.className = "lancamento";
  linha.setAttribute("role", "listitem");

  linha.innerHTML = `
    <div class="lancamento-info">
      <p class="lancamento-descricao" title="${descricao}">${descricao}</p>
      <p class="lancamento-categoria">${escaparHTML(lancamento.categoria)}</p>
    </div>
    <p class="lancamento-valor valor-${lancamento.tipo}">${formatarMoeda(Number(lancamento.valor))}</p>
    <span class="badge badge-${lancamento.tipo}">${rotuloTipo(lancamento.tipo)}</span>
    <time class="lancamento-data" datetime="${escaparHTML(lancamento.data)}">${formatarData(lancamento.data)}</time>
    <div class="lancamento-acoes">
      <a class="botao-icone botao-icone-editar" href="editar.html?id=${encodeURIComponent(lancamento.id)}" aria-label="Editar lançamento ${descricao}">
        <img src="assets/icons/edit.svg" alt="">
      </a>
      <button class="botao-icone botao-icone-excluir" type="button" data-acao="excluir" data-id="${encodeURIComponent(lancamento.id)}" aria-label="Excluir lançamento ${descricao}">
        <img src="assets/icons/trash.svg" alt="">
      </button>
    </div>
  `;

  return linha;
}

function renderizar() {
  const lancamentos = listar();

  const totalReceitas = lancamentos
    .filter((lancamento) => lancamento.tipo === "receita")
    .reduce((soma, lancamento) => soma + Number(lancamento.valor), 0);

  const totalDespesas = lancamentos
    .filter((lancamento) => lancamento.tipo === "despesa")
    .reduce((soma, lancamento) => soma + Number(lancamento.valor), 0);

  const saldo = totalReceitas - totalDespesas;

  const linhas = [...lancamentos]
    .sort((a, b) => b.data.localeCompare(a.data))
    .map(criarLinha);

  listaEl.replaceChildren(...linhas);
  listaVaziaEl.hidden = linhas.length > 0;

  totalReceitasEl.textContent = formatarMoeda(totalReceitas);
  totalDespesasEl.textContent = formatarMoeda(totalDespesas);
  saldoAtualEl.textContent = formatarMoeda(saldo);
  saldoAtualEl.classList.toggle("positivo", saldo >= 0);
  saldoAtualEl.classList.toggle("negativo", saldo < 0);
}

function mostrarToast(mensagem) {
  toastEl.textContent = mensagem;
  toastEl.hidden = false;
  requestAnimationFrame(() => toastEl.classList.add("visivel"));

  window.clearTimeout(timerToast);
  timerToast = window.setTimeout(() => {
    toastEl.classList.remove("visivel");
    window.setTimeout(() => {
      toastEl.hidden = true;
    }, 300);
  }, 3000);
}

listaEl.addEventListener("click", (evento) => {
  const botao = evento.target.closest("[data-acao]");
  if (!botao) return;

  const id = decodeURIComponent(botao.dataset.id);
  const confirmou = window.confirm("Tem certeza que deseja excluir este lançamento?");
  if (!confirmou) return;

  excluir(id);
  renderizar();
  mostrarToast("Lançamento excluído com sucesso!");
});

const parametros = new URLSearchParams(window.location.search);
const mensagem = MENSAGENS[parametros.get("msg")];
if (mensagem) mostrarToast(mensagem);

renderizar();

import { buscar, editar, excluir, CATEGORIAS } from "./storage.js";

const form = document.getElementById("form-lancamento");
const tipoEl = document.getElementById("tipo");
const categoriaEl = document.getElementById("categoria");
const descricaoEl = document.getElementById("descricao");
const valorEl = document.getElementById("valor");
const dataEl = document.getElementById("data");
const botaoExcluir = document.getElementById("botao-excluir");

const id = new URLSearchParams(window.location.search).get("id");
const lancamento = buscar(id);

if (!lancamento) {
  window.location.replace("index.html?msg=nao-encontrado");
}

function preencherCategorias() {
  categoriaEl.innerHTML = CATEGORIAS[tipoEl.value]
    .map((categoria) => `<option value="${categoria}">${categoria}</option>`)
    .join("");

  categoriaEl.value = lancamento.categoria;
  if (!categoriaEl.value) {
    const opcao = document.createElement("option");
    opcao.value = lancamento.categoria;
    opcao.textContent = lancamento.categoria;
    categoriaEl.appendChild(opcao);
    categoriaEl.value = lancamento.categoria;
  }
}

tipoEl.value = lancamento.tipo;
descricaoEl.value = lancamento.descricao;
valorEl.value = lancamento.valor;
dataEl.value = lancamento.data;

tipoEl.addEventListener("change", preencherCategorias);
preencherCategorias();

form.addEventListener("submit", (evento) => {
  evento.preventDefault();

  if (!form.checkValidity()) {
    form.reportValidity();
    return;
  }

  editar(id, {
    tipo: tipoEl.value,
    descricao: descricaoEl.value.trim(),
    categoria: categoriaEl.value,
    valor: Number(valorEl.value),
    data: dataEl.value,
  });

  window.location.href = "index.html?msg=editado";
});

botaoExcluir.addEventListener("click", () => {
  const confirmou = window.confirm("Tem certeza que deseja excluir este lançamento?");
  if (!confirmou) return;

  excluir(id);
  window.location.href = "index.html?msg=excluido";
});

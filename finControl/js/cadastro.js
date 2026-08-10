import { salvar, CATEGORIAS } from "./storage.js";

const form = document.getElementById("form-lancamento");
const tipoEl = document.getElementById("tipo");
const categoriaEl = document.getElementById("categoria");
const descricaoEl = document.getElementById("descricao");
const valorEl = document.getElementById("valor");
const dataEl = document.getElementById("data");

function preencherCategorias() {
  categoriaEl.innerHTML = CATEGORIAS[tipoEl.value]
    .map((categoria) => `<option value="${categoria}">${categoria}</option>`)
    .join("");
}

tipoEl.addEventListener("change", preencherCategorias);

dataEl.value = new Date().toISOString().slice(0, 10);
preencherCategorias();

form.addEventListener("submit", (evento) => {
  evento.preventDefault();

  if (!form.checkValidity()) {
    form.reportValidity();
    return;
  }

  salvar({
    tipo: tipoEl.value,
    descricao: descricaoEl.value.trim(),
    categoria: categoriaEl.value,
    valor: Number(valorEl.value),
    data: dataEl.value,
  });

  window.location.href = "index.html?msg=salvo";
});

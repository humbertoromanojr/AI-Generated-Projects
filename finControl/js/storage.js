const CHAVE_LOCAL = "finControl_lancamentos";

export const CATEGORIAS = {
  receita: ["Salário", "Freelance", "Investimentos", "Presente", "Outros"],
  despesa: ["Moradia", "Alimentação", "Transporte", "Saúde", "Lazer", "Educação", "Outros"],
};

function persistir(registros) {
  localStorage.setItem(CHAVE_LOCAL, JSON.stringify(registros));
}

export function listar() {
  try {
    const dados = localStorage.getItem(CHAVE_LOCAL);
    return dados ? JSON.parse(dados) : [];
  } catch {
    return [];
  }
}

function gerarId() {
  if (window.crypto && typeof window.crypto.randomUUID === "function") {
    return window.crypto.randomUUID();
  }
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

export function salvar(lancamento) {
  const registros = listar();
  const novo = { ...lancamento, id: gerarId() };
  registros.push(novo);
  persistir(registros);
  return novo;
}

export function buscar(id) {
  return listar().find((registro) => registro.id === id) || null;
}

export function editar(id, dados) {
  const registros = listar();
  const indice = registros.findIndex((registro) => registro.id === id);
  if (indice === -1) return null;

  registros[indice] = { ...registros[indice], ...dados, id };
  persistir(registros);
  return registros[indice];
}

export function excluir(id) {
  persistir(listar().filter((registro) => registro.id !== id));
}

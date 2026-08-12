# FLUTTMOV - Aplicativo de Descoberta de Filmes

## 📱 Visão Geral da index.md

O **FLUTTMOV** é um aplicativo mobile elegante e intuitivo para descoberta de filmes, projetado com uma interface minimalista em dark mode. O app oferece uma experiência imersiva de navegação por catálogos temáticos, detalhes completos de filmes e recomendações personalizadas, tudo envolto em uma identidade visual sofisticada e moderna, sempre ter o mínimo de páginas e código sempre limpo e menor possível.

## 🎯 Funcionalidades Principais

### Sistema de Descoberta Visual

- **Carrossel Dinâmico**: Destaques de filmes em carrossel horizontal automático com transições suaves
- **Grid de Recomendações**: Seção "Em Alta" com cards em grid de 2 colunas para navegação rápida
- **Indicadores Visuais**: Bolinhas de página e degradês sutis para hierarquia de informação

### Catálogo por Categorias

- **Navegação Temática**: Lista de filmes organizada por gênero ou categoria
- **Cards Informativos**: Imagem, título, sinopse resumida, nota e ano para decisão ágil
- **Efeito Parallax**: Imagem de destaque da categoria com movimento suave ao scroll
- **Scroll Infinito**: Carregamento contínuo de itens sem interrupção na navegação

### Imersão nos Detalhes

- **Pôster Expandido**: Imagem principal em alta definição com sobreposição de informações essenciais
- **Ficha Técnica Completa**: Sinopse extensa, elenco com fotos circulares, diretor e avaliações
- **Ações Rápidas**: Botão "Assistir Agora" em destaque, compartilhar e favoritar com um toque

## 🔧 Especificações Técnicas

### Design System

- **Paleta Dark Mode**: Fundo preto profundo (#0D0D0D), superfícies cinza escuro (#1A1A1A), textos brancos (#FFFFFF)
- **Cor de Destaque**: Dourado queimado (#E5B143) para calls-to-action e elementos interativos
- **Detalhes Secundários**: Cinza médio (#A0A0A0) para textos auxiliares e ícones inativos

### Tipografia e Ícones

- **Família Tipográfica**: Sans-serif moderna (Inter / SF Pro Display)
- **Hierarquia**: Títulos grandes e bold, corpo de texto regular com excelente legibilidade
- **Iconografia**: Feather Icons em linha fina, discretos e elegantes

### Arquitetura Visual

- **Grid System**: Margens de 20px e gutters consistentes em todas as telas
- **Bordas**: Arredondamento de 8px para cards, 16px para imagens principais
- **Sombras**: Glow suave apenas em destaques e botões, sem exageros
- **Barra de Navegação**: Bottom navigation fixa com ícones Home, Search e Profile

## 📋 Casos de Uso

### 🎬 Caso Principal: Descoberta Noturna de Filmes

**Cenário**: Usuário quer encontrar um filme para assistir à noite, com ambiente de baixa luminosidade

- **Ação**: Abre o FLUTTMOV e navega pelo carrossel de destaques e categorias
- **Funcionamento**: Interface escura reduz fadiga visual, tipografia de alto contraste garante legibilidade
- **Resultado**: Encontra um filme rapidamente, acessa detalhes e toma a decisão de assistir
- **Benefício**: Experiência confortável e imersiva sem agredir os olhos em ambientes escuros

### 🍿 Outros Casos de Uso

1. **Navegação por Gênero**: Explorar filmes de ação, drama ou comédia com imagens temáticas
2. **Consulta de Elenco**: Ver atores e diretores antes de decidir o que assistir
3. **Curadoria Visual**: Descobrir filmes em alta apenas pela qualidade dos pôsteres e notas

### 🎨 Funcionamento da Experiência Visual

- **Transições Fluidas**: Fade + slide entre telas para navegação orgânica
- **Microinterações**: Efeito de escala em botões ao toque, scroll suave com easing
- **Shimmer Loading**: Esqueleto animado durante carregamento de imagens
- **Responsividade**: Layout mobile-first otimizado para 375px de largura base

## 🚀 Fluxo de Funcionamento

1. **Abertura**: Usuário inicia o app e vê o carrossel de destaques em movimento automático
2. **Exploração**: Navega pelo grid "Em Alta" ou acessa categorias pela barra inferior
3. **Categoria**: Ao entrar em um gênero, vê a imagem de destaque com parallax e a lista de filmes
4. **Detalhes**: Toca em um filme e visualiza pôster expandido, sinopse, elenco e avaliações
5. **Decisão**: Usa o botão "Assistir Agora", favorita ou compartilha o filme com amigos

## 🎨 Interface do Usuário

### Tela Home

- Header com nome do app à esquerda e ícone de perfil à direita
- Carrossel horizontal automático ocupando 60% da tela com indicadores de página
- Grid de 2 colunas "Em Alta" com mini cards (pôster + título + nota)
- Degradê inferior nos pôsteres do carrossel para destacar informações sobrepostas

### Tela Movie (Catálogo)

- Imagem de destaque do gênero (200px) com parallax e gradiente escuro sobreposto
- Título da categoria centralizado na parte inferior da imagem
- Lista vertical com cards horizontais (imagem à esquerda, informações à direita)
- Borda sutil e highlight ao toque em cada card

### Tela MovieDetail

- Pôster expandido (320px) com botão voltar translúcido no topo
- Gradiente escuro sobreposto com título, ano, gênero e duração
- Seção completa com sinopse, elenco (fotos circulares), diretor e avaliações com estrelas
- Botão fixo "▶ Assistir Agora" em dourado no rodapé
- Ícones de compartilhar e favoritar próximos ao título

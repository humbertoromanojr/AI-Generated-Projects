# 🔧 Recursos e Funcionalidades - FLUTTMOV features.md

## 🎯 Funcionalidades Principais

### 🎬 Sistema de Descoberta Visual de Filmes

#### Carrossel de Destaques (Filmes em Cartaz)

- **Carrossel Automático**: Slider horizontal com filmes populares em transição suave (ease-in-out)
- **Poster em Destaque**: Imagens de alta qualidade ocupando 60% da altura da tela
- **Indicadores de Página**: Bolinhas de navegação abaixo do carrossel mostrando posição atual
- **Informações Sobrepostas**: Título do filme e nota (rating) com degradê inferior para legibilidade
- **Atualização Dinâmica**: Dados consumidos diretamente da API TMDB (endpoint `/movie/now_playing`)

#### Grid de Recomendações (Em Alta)

- **Grid de 2 Colunas**: Cards compactos com pôster, título e nota do filme
- **Dados da API TMDB**: Endpoint `/movie/popular` ou `/trending/movie/week` para listar os mais populares
- **Scroll Vertical Suave**: Experiência de navegação contínua e responsiva
- **Touch Highlight**: Feedback visual sutil ao tocar em qualquer card

### 📂 Catálogo por Categorias

#### Navegação Temática por Gênero

- **Imagem de Destaque por Categoria**: Banner superior (200px) com parallax suave ao scroll
- **Gradiente de Sobreposição**: Fundo escuro sobre a imagem para destacar o título da categoria
- **Filtro por Gênero**: Uso do endpoint `/discover/movie?with_genres={id}` para listar filmes por gênero
- **Cards Horizontais**: Layout com imagem à esquerda e informações à direita (título, sinopse resumida em 2 linhas, nota, ano)

#### Scroll Infinito

- **Paginação Contínua**: Carregamento incremental usando `page` param da API TMDB
- **Shimmer Loading**: Esqueleto animado enquanto novos cards são carregados
- **Transparência no Carregamento**: Indicador sutil de que mais itens estão sendo buscados

### 🎥 Imersão nos Detalhes do Filme

#### Pôster Expandido

- **Imagem em Alta Definição**: Banner de 320px de altura com endpoint `/movie/{id}/images`
- **Informações Sobrepostas**: Título, ano, gêneros e duração sobre gradiente escuro (de baixo para cima)
- **Botão Voltar**: Ícone circular translúcido no canto superior esquerdo

#### Ficha Técnica Completa

- **Sinopse Completa**: Obtida via `/movie/{id}` (campo `overview`)
- **Elenco Principal**: Fotos circulares com nomes dos atores via `/movie/{id}/credits`
- **Diretor e Equipe**: Destaque para diretor extraído dos créditos (department: "Directing")
- **Avaliações**: Nota média (`vote_average`) com ícones de estrela, contagem de votos e popularidade

#### Ações Rápidas

- **▶ Assistir Agora**: Botão fixo no rodapé em douado queimado (#E5B143) com largura máxima e cantos arredondados
- **🔗 Compartilhar**: Botão nativo de compartilhamento do SO enviando link do filme e convite para baixar o app
- **❤️ Favoritar**: Ícone de coração próximo ao título para salvar localmente (armazenamento offline)

## 🔗 Integração com Redes Sociais

### Compartilhamento Nativo

- **Compartilhar Filme**: Usa a API nativa de compartilhamento do sistema operacional
- **Mensagem Padrão**: _"Olha esse filme que encontrei no FLUTTMOV: [título] - [link do TMDB]"_
- **Convite para o App**: Inclui link de download do app junto com o link do filme
- **Plataformas Suportadas**: WhatsApp, Instagram, Twitter/X, Telegram, SMS e outras disponíveis no dispositivo

### Link do Filme

- **URL Oficial do TMDB**: `https://www.themoviedb.org/movie/{id}`
- **Deep Link do App**: Se o destinatário tiver o FLUTTMOV instalado, abre direto na tela de detalhes

## 🔧 Especificações Técnicas

### Integração com API TMDB

- **Base URL**: `https://api.themoviedb.org/3`
- **Chave de API**: Autenticação via `api_key` nos parâmetros da requisição
- **Idioma**: Parâmetro `language=pt-BR` para conteúdo em português
- **Imagens**: Base URL `https://image.tmdb.org/t/p/` com tamanhos `w500`, `w780`, `w1280` conforme necessidade
- **Endpoints Utilizados**:
  - `/movie/now_playing` → Carrossel de destaques (em cartaz)
  - `/movie/popular` → Grid "Em Alta"
  - `/discover/movie?with_genres={id}` → Filmes por gênero
  - `/genre/movie/list` → Lista de gêneros disponíveis
  - `/movie/{id}` → Detalhes completos do filme
  - `/movie/{id}/credits` → Elenco e equipe
  - `/movie/{id}/images` → Pôsteres e backdrops
  - `/trending/movie/week` → Tendências da semana

### Design System (Dark Mode)

- **Paleta de Cores**:
  - Fundo: Preto profundo (#0D0D0D)
  - Superfícies: Cinza escuro (#1A1A1A)
  - Textos: Branco puro (#FFFFFF)
  - Destaque/Dourado: (#E5B143)
  - Textos secundários: Cinza médio (#A0A0A0)
- **Tipografia**: Sans-serif moderna (Inter / SF Pro Display)
- **Ícones**: Feather Icons (linha fina, discretos e elegantes)
- **Bordas**: 8px para cards, 16px para imagens principais
- **Sombras**: Glow suave apenas em destaques e botões
- **Grid System**: Margens de 20px e gutters consistentes

### Arquitetura Visual das Telas

#### Tela Home

- Header com nome do app e ícone de perfil
- Carrossel automático horizontal (60% da tela)
- Grid "Em Alta" com 2 colunas
- Bottom Navigation fixa com ícones Home, Search, Profile

#### Tela Movie (Catálogo)

- Banner de gênero com efeito parallax
- Lista vertical com cards horizontais
- Scroll infinito com shimmer loading

#### Tela MovieDetail

- Pôster expandido com botão voltar
- Gradiente com informações sobrepostas
- Sinopse, elenco, diretor e avaliações
- Botão "Assistir Agora" fixo no rodapé
- Ícones de compartilhar e favoritar

### Armazenamento Local

- **Favoritos**: Salvos offline em armazenamento local (AsyncStorage ou similar)
- **Cache de Imagens**: Armazenamento temporário de pôsteres para carregamento rápido
- **Última Navegação**: Histórico de filmes visualizados recentemente

## 🚀 Fluxo de Funcionamento

1. **Abertura do App**: Requisição à API TMDB → `/movie/now_playing` popula o carrossel e `/movie/popular` o grid
2. **Navegação por Gênero**: Requisição a `/genre/movie/list` → usuário seleciona gênero → `/discover/movie?with_genres={id}`
3. **Scroll Infinito**: Incremento do parâmetro `page` → novos cards anexados à lista
4. **Toque no Filme**: Requisição a `/movie/{id}` + `/movie/{id}/credits` → transição fade+slide para tela de detalhes
5. **Compartilhar**: Aciona Share API nativa com texto: _"Olha esse filme que encontrei no FLUTTMOV: [título] - [link]"_ e link do app

## 🎨 Experiência do Usuário (UI/UX Moderno)

### Microinterações

- **Transições entre Telas**: Fade + slide horizontal (navegação tipo stack)
- **Efeito de Toque em Botões**: Escala de 0.95 com spring animado
- **Scroll Suave**: Easing padronizado em todas as listas
- **Shimmer Loading**: Placeholder animado durante carregamento de imagens e dados

### Acessibilidade e Performance

- **Contraste Otimizado**: Textos brancos sobre fundo escuro atendendo WCAG AA
- **Touch Targets**: Área mínima de toque de 44px para ícones e botões
- **Lazy Loading de Imagens**: Carregamento sob demanda com baixa resolução inicial
- **Tratamento de Erros**: Estados de "Sem conexão", "Filme não encontrado" e "Erro ao carregar" com mensagens amigáveis e opção de retry

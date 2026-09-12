# RetroRecomp Hub 🎮✨

<p align="center">
  <a href="https://github.com/guuhferiani/RetroRecomp-Hub/actions/workflows/android.yml">
    <img src="https://github.com/guuhferiani/RetroRecomp-Hub/actions/workflows/android.yml/badge.svg" alt="Build Status" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Android-0078D6?style=for-the-badge&logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/LÖVE2D-11.5-E64980?style=for-the-badge&logo=lua&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-Lua%20100%25-2C2D72?style=for-the-badge&logo=lua&logoColor=white" />
  <img src="https://img.shields.io/badge/Consoles-GB%20%7C%20GBC%20%7C%20GBA%20%7C%20SNES%20%7C%20PS1-7B2CBF?style=for-the-badge" />
</p>

Central unificada de alto desempenho para execução, gerenciamento de saves, suporte a mods e visualização procedural de projetos recompilados e jogos clássicos retrô.

---

## 🌟 Funcionalidades Principais

- 🕹️ **Frontend Unificado Multiconsole:** Navegação rápida por abas (`TODOS`, `GB/GBC`, `GBA`, `SNES`, `PS1`).
- 📼 **Renderizadores Procedurais de Mídias Clássicas (Efeito Parallax 3D):**
  - **Game Boy / GBC:** Formato vertical clássico, chanfro superior, concavidade Nintendo e adesivo holográfico.
  - **Game Boy Advance:** Design horizontal widescreen com pegada texturizada e relevo metálico.
  - **Super Nintendo (SNES):** Cartucho cinza em dois tons, chanfro inferior e relevo de ventilação.
  - **PlayStation 1 (PS1):** Estojo de acrílico *Jewel Case* com o lendário **Black Disc de CD-ROM** e reflexos prismáticos.
- ⚡ **Seletor de Shaders e Filtros em Tempo Real (`ShaderManager.lua`):**
  - Simulações autênticas: *CRT Trinitron Scanlines*, *LCD Grid Portátil*, *Scale4x / xBRZ HD*, *GBA Color Boost* e *Retro Vignette*.
  - Alternância imediata via tecla `F` ou botão dedicado de Shaders.
- 🚀 **Roteador Inteligente de Execução (`Router.lua`):**
  - Disparo assíncrono em segundo plano com overlay de carregamento integrado.
  - Suporte ao motor integrado **mGBA** e preparação para núcleos de SNES e PS1.
- 🧩 **Gerenciador de Mods por Jogo (`ModManager.lua`):**
  - Modal interativo com switches on/off em tempo real (`M`).
- 📱 **Suporte Nativo a Mobile & Controles Touch (`TouchOverlay.lua`):**
  - D-Pad, botões A/B, L/R de ombro, Start e Select com multi-touch.
- 💾 **Gerenciador de Save Slots (`SaveManager.lua`):**
  - Até 4 slots independentes por jogo (`S1` a `S4`) com troca rápida via teclado (`1-4`) ou clique.

---

## 🎮 Plataformas & Jogos Suportados

| Console | Título | Motor / Execução | Recursos em Destaque |
| :--- | :--- | :--- | :--- |
| **GBC** | Pokémon Crystal Version | mGBA / Gen1Recomp | Tradução PT-BR v1.3.0, Kanto Full 251, 60 FPS |
| **GBC** | Pokémon Yellow Version | mGBA / Gen1Recomp | Pikachu Follower, Fast Text, Corrida Automática |
| **GBA** | Pokémon FireRed Version | mGBA (32-bit) | Shaders LCD/CRT, Exp Share moderno, TMs infinitos |
| **SNES** | Super Mario World | snes9x | Mode 7, 96 Saídas Secretas, Filtros Analógicos |
| **PS1** | Castlevania: Symphony of the Night | duckstation | Áudio Redbook CD, Castelo Invertido 200.6%, Dublagem PT-BR |

---

## ⌨️ Controles & Atalhos

| Tecla / Toque | Função |
| :--- | :--- |
| `Tab` / `SELECT` | Alternar entre filtros de plataformas (`TODOS` ➜ `GBC` ➜ `GBA` ➜ `SNES` ➜ `PS1`) |
| `Enter` / `Espaço` / Botão `A` | Iniciar o jogo selecionado no motor correspondente |
| `F` / Botão `⚡ SHADERS` | Abrir / Fechar Seletor de Shaders e Filtros Analógicos |
| `M` / Botão `MODS` | Abrir / Fechar gaveta de Gerenciamento de Mods |
| `S` / Botão `SAVES` | Abrir / Fechar gaveta de Gerenciamento de Saves |
| `1`, `2`, `3`, `4` | Selecionar Slot de Gravação ativo diretamente |
| `T` / Botão `📱 TOUCH` | Ativar / Desativar controles virtuais na tela |
| `Esc` / Botão `B` | Fechar modal aberto ou voltar |
| `Esc` | Fechar modal aberto ou sair do Hub |

---

## 🚀 Como Executar

### Pré-requisitos
- [LÖVE 11.5+](https://love2d.org/) instalado no sistema.

### Inicialização Rápida
- Dê um **duplo clique no arquivo `Play-Hub.bat`**, ou
- Pelo terminal:
  ```bash
  love "RetroRecomp Hub"
  ```

### Verificação Automatizada
Para rodar os testes unitários e de resolução de caminhos:
```bash
love "RetroRecomp Hub" --verify
love "RetroRecomp Hub" --test
```

---

## 📁 Estrutura do Projeto

```text
RetroRecomp Hub/
├── Play-Hub.bat              # Inicializador rápido para Windows
├── conf.lua                  # Configurações de janela (1120x700, MSAA 4x, HighDPI)
├── main.lua                  # Loop principal de eventos do LÖVE2D
├── emulator/                 # Motor mGBA integrado, shaders e configurações
├── roms/
│   ├── gbc/                  # ROMs de Game Boy / Game Boy Color
│   └── gba/                  # ROMs de Game Boy Advance
├── src/
│   ├── core/                 # Theme, Router, PlatformManager, ModManager, SaveManager
│   └── ui/                   # CartridgeRenderer, GameSelector, GameDetailsView, Modals
└── mods/                     # Pacotes e manifestos de modificações
```

---

## 📜 Licença & Conformidade
Este projeto é uma ferramenta de interface e launcher de código aberto. Arquivos de ROMs proprietárias não são incluídos no repositório.

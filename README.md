# RetroRecomp Hub 🎮✨

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" />
  <img src="https://img.shields.io/badge/LÖVE2D-11.5-E64980?style=for-the-badge&logo=lua&logoColor=white" />
  <img src="https://img.shields.io/badge/Consoles-GB%20%7C%20GBC%20%7C%20GBA-7B2CBF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Recomp-Native%20Port-10B981?style=for-the-badge" />
</p>

Central unificada de alto desempenho para execução, gerenciamento de saves, suporte a mods e visualização procedural de projetos recompilados e jogos clássicos retrô.

---

## 🌟 Funcionalidades Principais

- 🕹️ **Frontend Unificado Multiconsole:** Navegação intuitiva com abas por plataforma (`TODOS`, `GB / GBC`, `GBA`).
- 📼 **Renderizador Procedural de Cartuchos (Efeito Parallax 3D):**
  - **Game Boy / GBC:** Formato vertical clássico, chanfro superior, concavidade Nintendo, adesivo e reflexo holográfico animado.
  - **Game Boy Advance:** Design horizontal widescreen com textura lateral de pegada e relevo metálico.
  - **Parallax:** Os cartuchos se inclinam e reagem dinamicamente ao movimento do mouse.
- 🚀 **Roteador Inteligente de Execução (`Router.lua`):**
  - Disparo assíncrono em segundo plano com overlay de carregamento integrado.
  - Motor integrado **mGBA** com suporte a filtros e shaders modernos (LCD, CRT, Scale4x).
- 🧩 **Gerenciador de Mods por Jogo (`ModManager.lua`):**
  - Modal interativo com toggles em tempo real (`M`).
  - Suporte a traduções PT-BR, Exp Share moderno, texto instantâneo, sapatos de corrida em interiores, etc.
- 💾 **Gerenciador de Save Slots (`SaveManager.lua`):**
  - Até 4 slots independentes por jogo (`S1` a `S4`) com troca rápida via teclado (`1-4`) ou clique.

---

## 🎮 Plataformas & Jogos Suportados

| Console | Título | Motor / Execução | Recursos em Destaque |
| :--- | :--- | :--- | :--- |
| **GBC** | Pokémon Crystal Version | mGBA / Gen1Recomp | Tradução PT-BR v1.3.0, Kanto Full 251, 60 FPS |
| **GBC** | Pokémon Yellow Version | mGBA / Gen1Recomp | Pikachu Follower, Fast Text, Corrida Automática |
| **GBA** | Pokémon FireRed Version | mGBA (32-bit) | Shaders LCD/CRT, Exp Share moderno, TMs infinitos |

---

## ⌨️ Controles & Atalhos

| Tecla / Ação | Função |
| :--- | :--- |
| `Tab` | Alternar entre filtros de plataformas (`TODOS` ➜ `GBC` ➜ `GBA`) |
| `Enter` / `Espaço` | Iniciar o jogo selecionado no motor correspondente |
| `M` | Abrir / Fechar gaveta de Gerenciamento de Mods |
| `S` | Abrir / Fechar gaveta de Gerenciamento de Saves |
| `1`, `2`, `3`, `4` | Selecionar Slot de Gravação ativo diretamente |
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

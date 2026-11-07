# Desfiladeiro Rice

Customização para Fedora KDE Plasma 6 com Wayland. O visual combina uma paleta azul-petróleo, um dock flutuante, três painéis compactos no topo, um terminal translúcido e um espectro de áudio no desktop.

## Instalação

Na sessão do KDE, instale as dependências e rode o instalador na pasta do repositório.

```bash
sudo dnf install cava fastfetch konsole papirus-icon-theme-dark curl
bash instalar.sh
```

O script instala o esquema de cores, o perfil do Konsole e os widgets **Desfiladeiro · Reprodução** e **Desfiladeiro · Espectro** no seu usuário. Ele aplica o esquema de cores e inicia o serviço de áudio. A montagem dos painéis é feita pelo modo de edição do Plasma, assim você pode adaptar a posição dos widgets ao seu monitor.

O wallpaper e os sprites são opcionais. Baixe os arquivos nos links abaixo e passe os caminhos nesta ordem. Instale o pacote `ImageMagick` se for usar um sprite. Passe `""` na posição de um arquivo que quiser pular.

```bash
bash instalar.sh ~/Downloads/70.jpg ~/Downloads/ralsei.gif ~/Downloads/link.png
```

- [Wallpaper do desfiladeiro](https://raw.githubusercontent.com/DPhngNam/dotfiles/main/wallpapers/70.jpg)
- [GIF transparente do Ralsei, adaptação de ClearlyHatin a partir da animação de ThatBratCohen](https://www.reddit.com/r/ralsei/comments/ptfs2j/idle_ralsei_now_transparent/)
- [Sprite do Link, de A Link to the Past](https://en.wikibooks.org/wiki/File:ALttP_Link_sprite.png)

## Painéis e terminal

1. No modo de edição do Plasma, crie três painéis vazios no topo. Configure cada um com **30 px**, modo flutuante, opacidade translúcida e largura ajustada ao conteúdo. Alinhe o relógio à esquerda, o widget **Desfiladeiro · Reprodução** ao centro e a bandeja do sistema à direita.
2. Configure o painel de baixo com **42 px**, centralizado, flutuante, translúcido e ajustado ao conteúdo. Adicione o Lançador de Aplicativos e o Gerenciador de Tarefas Somente com Ícones. No lançador, selecione o ícone `fedora-logo-icon` para manter o símbolo do Fedora.
3. Coloque **Desfiladeiro · Espectro** no desktop acima do dock. Em uma tela de 1600 × 900, use cerca de 560 px de largura e centralize o widget.
4. Em **Configurações do Sistema → Cores e temas → Ícones**, selecione **Papirus-Dark**. Se quiser pastas verde-azuladas, use a variante `teal` do [papirus-folders](https://github.com/PapirusDevelopmentTeam/papirus-folders) em uma cópia do tema na pasta de ícones do usuário.
5. No Konsole, selecione o perfil **Desfiladeiro**. Para abrir uma janela sem barra de ferramentas, use `konsole --profile Desfiladeiro --hide-toolbars`. O perfil usa Hack 9 pt quando a fonte está disponível.

O player usa os metadados MPRIS enviados pelo aplicativo. A capa aparece quando o aplicativo fornece a imagem. O espectro usa o CAVA para ler a saída de áudio e só reage quando há som.

## Remoção

Remova os widgets pelo modo de edição e volte ao esquema de cores, ao wallpaper e ao perfil de terminal de sua escolha. Desative o serviço com `systemctl --user disable --now desfiladeiro-spectrum.service`. Os widgets também podem ser removidos em **Gerenciar widgets**.

## Créditos

- [Referência visual em r/unixporn](https://www.reddit.com/r/unixporn/comments/1re9r7f/kde_plasma_iike_ricing/)
- [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) e [CAVA](https://github.com/karlstav/cava)
- O esquema `Desfiladeiro.colors` deriva do Breeze Dark do KDE e conserva os créditos e a licença [LGPL-2.0-or-later](LGPL-2.0-or-later.txt).

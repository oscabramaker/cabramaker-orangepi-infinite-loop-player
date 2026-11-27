# Os cabramaker — player em loop

Criador: **Os cabramaker** · Instagram: [@oscabramaker](https://www.instagram.com/oscabramaker/).

Ligue a placa e reproduza vídeos automaticamente, sem desktop e em repetição. Troque vídeos e banner pelo cartão no computador.

## Versões atuais

**Escolha a imagem correspondente à placa. As imagens não são intercambiáveis.**

| Placa | Versão atual | Download e instruções |
| --- | --- | --- |
| Orange Pi One — Allwinner H3 | 1.0-rc1 | [Baixar Orange Pi](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/releases/tag/v1.0-rc1) · [Manual](docs/USO.md) |
| Raspberry Pi 3 Model B / B+ | 1.0.1 | [Baixar Raspberry Pi](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/releases/tag/raspberrypi-v1.0.1) · [Manual](raspberrypi/README.md) |

A versão Raspberry Pi teve inicialização e reprodução confirmadas no **3 B v1.2**; o teste físico no **3 B+** está pendente. A distribuição Orange Pi continua identificada como candidata 1.0-rc1; sua configuração de reprodução foi usada na placa, mas a imagem pública completa ainda requer validação física. Veja os relatórios: [Orange Pi](docs/VALIDACAO.md), [Raspberry Pi](raspberrypi/docs/VALIDACAO.md).

## Como usar

1. Baixe a imagem no release da sua placa. Não grave o código-fonte nem a imagem base limpa de construção.
2. Grave em outro microSD de pelo menos 8 GB. Para Raspberry Pi, extraia o ZIP e selecione o `.img` no Raspberry Pi Imager, sem personalizações.
3. Abra a unidade **MIDIA** no computador, copie MP4/H.264 para `videos` e substitua `splash.png` se desejar.
4. Ejete o cartão, conecte HDMI e ligue a placa. Não é necessário digitar login para reproduzir.

O arquivo de demonstração deve ser apagado se você quiser reproduzir apenas seus vídeos. A proporção é preservada; faixas presentes no arquivo ou no ajuste da TV podem permanecer. SSH é opcional por chave pública, conforme o manual de cada placa.

## Código e construção

- Orange Pi: `src/`, `MIDIA/`, `build-image.sh` e [documentação](docs/CONSTRUIR.md).
- Raspberry Pi: [raspberrypi/](raspberrypi/README.md), com instalador e construtor próprios.

Imagens grandes ficam nos anexos dos releases, fora do histórico Git. Somente demonstração e banner próprios são distribuídos; vídeos comerciais e credenciais particulares não fazem parte do projeto público.

MIT para o código próprio. Armbian, Raspberry Pi OS, Debian, VLC, GStreamer e demais componentes mantêm suas respectivas licenças e autorias.

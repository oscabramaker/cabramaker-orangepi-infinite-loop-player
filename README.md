# Os cabramaker — versão 1.0

Player automático de vídeos para **Orange Pi One (Allwinner H3)**.

Criador: **Os cabramaker** · Instagram: [@oscabramaker](https://www.instagram.com/oscabramaker/)

**Imagem candidata a testes em outro cartão. Ainda não validada fisicamente
como uma instalação completa.** A configuração Cedrus/KMS que orientou este
projeto já reproduziu o vídeo original na placa; o novo pacote e a partição
MIDIA precisam passar pelos testes descritos abaixo antes da release estável.

## Uso em poucas etapas

1. Grave a imagem da release em um microSD de pelo menos 8 GB.
2. Retire e recoloque o cartão no PC e abra a unidade **MIDIA**.
3. Copie seus MP4/H.264 para `videos` e seu banner para `splash.png`.
4. Ejete, coloque na Orange Pi One, conecte HDMI e ligue.

```text
MIDIA/
├── videos/
│   └── 01-demonstracao.mp4
├── splash.png
├── LEIA-ME.txt
└── ssh.pub                  # opcional; somente chave pública
```

Para trocar o conteúdo, desligue a placa e repita a cópia pelo computador.
Não precisa de SSH para trocar vídeos ou banner. Apague a demonstração para
reproduzir somente seus próprios vídeos.

## Funcionamento

- Início automático, sem desktop, com repetição de um vídeo ou de uma lista.
- MP4/H.264 até 1080p/30 fps; decodificação Cedrus e saída HDMI 720p/60 Hz.
- Áudio quando o arquivo contém uma trilha, pelo dispositivo ALSA padrão.
- Banner lido da pasta em cada inicialização, centralizado sem distorção.
- Textos Linux silenciados no HDMI; U-Boot pode mostrar mensagens iniciais.
- Botão da placa para reinício e botão externo opcional: pino físico 7 → GND.
- SSH opcional por chave pública; não há senha compartilhada na distribuição.
- Área FAT32 reconhecida pelo Windows 10 1703+ e Windows 11.
- Aproximadamente 4 GB para mídia; espaço adicional de cartões maiores não é
  expandido automaticamente nesta versão.

A imagem é específica para **Orange Pi One H3**. Não use em One Plus, Zero,
PC ou outros modelos. A proporção é preservada: vídeos/telas de proporções
diferentes podem apresentar faixas. Esta versão não converte vídeos.

## Documentação

- [Gravação, troca de arquivos, botões e SSH](docs/USO.md)
- [Construção e testes da imagem](docs/CONSTRUIR.md)
- [Componentes, licenças e créditos](docs/THIRD_PARTY.md)
- [Estado da validação](docs/VALIDACAO.md)

## Código

`src/player.py` controla GStreamer/Cedrus/KMS, `src/splash.py` exibe o banner,
`src/setup-ssh.sh` habilita acesso opcional, e as unidades systemd organizam a
inicialização. `build-image.sh` monta uma imagem separada a partir da base
Armbian cujo checksum consta na documentação.

Os vídeos, imagens comerciais e credenciais da instalação particular do
criador não são incluídos. A imagem contém apenas uma demonstração própria.

## Downloads

Baixe a imagem e confira os checksums nos [Releases](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/releases).
A versão inicial é **v1.0-rc1**, um pré-lançamento com teste físico pendente.
Grave em outro cartão e siga [as instruções](docs/USO.md).

Licença MIT para o código próprio. Armbian, Debian, kernel, GStreamer e demais
componentes mantêm suas respectivas licenças e autorias.

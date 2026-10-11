# Componentes e créditos

O código próprio deste repositório usa a licença MIT, com autoria
**Os cabramaker (@oscabramaker)**. Isso não altera as licenças dos componentes
incluídos na imagem.

- Base: Armbian 26.8.1 Minimal, Debian 13, Orange Pi One.
- Kernel: Linux 6.18.44-current-sunxi da imagem base.
- Reprodução: GStreamer, plugin V4L2 stateless/Cedrus e KMS.
- Banner: Python e Pillow, framebuffer Linux.
- Sistema, bibliotecas e utilitários: pacotes Debian e Armbian.

As licenças e avisos dos pacotes são preservados no cartão em
`/usr/share/doc/*/copyright`. O manifesto da release lista os pacotes e versões.

Fontes dos projetos e instruções de reconstrução:

- https://github.com/armbian/build
- https://docs.armbian.com/
- https://sources.debian.org/
- https://www.kernel.org/
- https://gstreamer.freedesktop.org/
- https://github.com/python-pillow/Pillow

Commit de construção declarado pela base Armbian: `8b778f3d8`.
O código do player e do banner nesta pasta é próprio do projeto; o funcionamento
foi orientado pela configuração Cedrus/KMS anteriormente validada na placa.

Vídeos, imagens comerciais, chaves privadas e senhas da instalação particular
não fazem parte da distribuição. Quem distribuir conteúdo de mídia deve usar
arquivos que tenha direito de compartilhar.

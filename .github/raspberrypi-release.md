# Raspberry Pi 1.0 — Os cabramaker

Versão para Raspberry Pi 3 Model B e 3 Model B+, assinada por **Os cabramaker / @oscabramaker**.

- Liga e inicia o vídeo automaticamente, sem criar usuário ou digitar login.
- MP4/H.264 em loop, saída HDMI 720p/60 Hz e áudio HDMI.
- Primeira partição FAT32 **MIDIA**, com pasta videos e splash.png acessíveis pelo Windows.
- Splash com suporte a framebuffer RGB565 e 32 bits.
- SSH opcional por chave pública, sem senha compartilhada.
- Relatório STATUS-PI3.txt gerado após o boot, sem parar o player.

**Validado pelo proprietário no Raspberry Pi 3 Model B v1.2.** O teste físico no 3 B+ está pendente. O diagnóstico registrou HDMI 720p, 47,8 °C e ausência de alerta de baixa tensão na amostra. Áudio, botão GPIO e ensaio prolongado não foram certificados. Pequenas faixas existentes no arquivo ou na TV podem permanecer.

## Gravar

1. Baixe **os-cabramaker-raspberrypi3-v1.0.img.zip**.
2. Extraia o ZIP e selecione o `.img` no Raspberry Pi Imager, como imagem personalizada.
3. Grave em um microSD de pelo menos 8 GB e pule as personalizações do Imager.
4. Abra MIDIA, troque o MP4 na pasta videos e o banner splash.png; preserve os demais arquivos de firmware.
5. Ejete, conecte HDMI e ligue. Apague a demonstração para reproduzir somente seus próprios arquivos.

Se MIDIA estiver sem letra no Windows, atribua uma pelo Gerenciamento de Disco. Não formate a partição Linux.

[Manual](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/blob/raspberrypi-v1.0/raspberrypi/README.md) · [Validação](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/blob/raspberrypi-v1.0/raspberrypi/docs/VALIDACAO.md)

Anexos: imagem ZIP, SHA256SUMS.txt, código e packages.tsv. Confira o SHA256 antes de gravar. A imagem pública inclui somente demonstração própria; não contém vídeo comercial nem credenciais particulares.

Código próprio sob MIT. Raspberry Pi OS, Debian, VLC e demais componentes preservam suas licenças. Instagram: [@oscabramaker](https://www.instagram.com/oscabramaker/).

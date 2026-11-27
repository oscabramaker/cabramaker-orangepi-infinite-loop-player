# Construir Raspberry Pi 1.0.1

Use Linux como root, com 25 GB livres, xz-utils, util-linux, e2fsprogs, dosfstools, python3 e zip. Em x86_64, configure emulação binfmt ARM64; também pode construir em Linux ARM64 nativo.

Base oficial: Raspberry Pi OS Lite ARM64 Trixie, 2026-10-06.

Download: https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-10-06/2026-10-06-raspios-trixie-arm64-lite.img.xz

SHA256: `483db18a48da399b5b7022ffae9a07bc6d99daab30e593aedac09b69ff422843`.

```sh
sudo bash build-image.sh BASE.img.xz cabramaker-pi3.img
```

O script aceita arquivos de imagem e exige uma saída nova. Não grava dispositivos físicos. A imagem limpa é apenas um insumo: não a confunda com o resultado pronto.

Layout MBR de 7 GiB, identificador `43414233`:

| Partição | Início (setores de 512 bytes) | Tamanho (setores) | Uso |
| --- | --- | --- | --- |
| 1 | 16384 | 7323648 | FAT32 MIDIA, firmware e arquivos do usuário |
| 2 | 7340032 | 7340032 | Raiz Linux ext4 |

A raiz é copiada para sua nova posição e ampliada. `cmdline.txt` e `fstab` são ajustados aos PARTUUIDs desse layout. A MIDIA é montada em `/boot/firmware` e exposta somente para leitura ao player por um bind em `/media/MIDIA`.

O instalador usa os repositórios oficiais para obter VLC e dependências. O manifesto registra as versões; pacotes podem mudar entre builds, portanto não há promessa de reprodução bit a bit.

Não use uma FAT que já continha mídia particular para distribuir a imagem: apagar um vídeo não apaga seus dados livres. Formate a FAT de distribuição novamente e copie somente firmware e mídia autorizada. Limpe identificadores, host keys e dados de teste; valide os sistemas de arquivos e compare o SHA256 após descompactar.

Para gravar, selecione o `.img` gerado no Raspberry Pi Imager, sem personalizações. Veja a lista de testes em `VALIDACAO.md`.

O VLC é fixado em `1:3.0.24-0+deb13u1+rpt3`, a revisão testada no 3 B. O arquivo `src/vlc-packages.json` registra URLs oficiais e SHA256 dos sete pacotes. A instalação verifica os hashes e mantém esses pacotes em hold; não substitui silenciosamente por revisões novas. Para atualizar o VLC, valide na placa antes de alterar os pins. As demais dependências são registradas no manifesto de cada build.

A construção também pode ser iniciada manualmente em Actions → Build Raspberry Pi image. O workflow usa ARM64 nativo e não sobrescreve releases publicadas.

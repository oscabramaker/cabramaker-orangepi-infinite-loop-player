# Reconstruir a imagem

Os cabramaker 1.0 — @oscabramaker.

Base usada: Armbian 26.8.1 Minimal CLI, Debian 13, Orange Pi One, kernel
6.18.44-current-sunxi. SHA-256 do `.img.xz` original:

```text
7babe415b7e55e0554572af24d0177d1f69b41388d0f3ab11357abbcd790a1a6
```

Obtenha a base pelo projeto Armbian e confira esse checksum. Outra versão exige
nova validação, principalmente do plugin GStreamer V4L2 stateless.

## Ambiente Linux

O script `build-image.sh` espera Linux x86_64 com permissão de root, ferramentas
de partições/sistemas de arquivos, Python 3, xz e emulação ARM por `binfmt_misc`.
O ambiente deve conseguir executar binários ARM dentro de um chroot.
Debian/Ubuntu podem fornecer isso com QEMU user e o registro binfmt de ARM.
Reserve pelo menos 16 GB livres e acesso à internet para os pacotes.

```sh
sudo bash build-image.sh /caminho/armbian.img.xz /caminho/cabramaker-1.0.img
```

O script só aceita a base como arquivo e exige uma saída `.img` inexistente.
Ele associa o arquivo a um dispositivo loop; não grava cartões físicos.
O primeiro setor e a área anterior à partição Linux preservam o boot da base.

## Estrutura

- Imagem: 7 GiB, cabe em cartões comercializados como 8 GB.
- Partição 1: ext4, começa no setor 8192; aproximadamente 3 GiB.
- Partição 2: FAT32, rótulo MIDIA; 4 GiB.
- Expansão automática Armbian desabilitada para não alterar essa estrutura.
- MIDIA montada somente para leitura pelo aparelho; gravações são feitas no PC.
- HDMI fixado em 1280×720 a 60 Hz nesta primeira versão.

O instalador usa os repositórios de pacotes da base. A lista de versões é
exportada junto da imagem. Isso permite auditar a composição, mas não promete
uma reconstrução byte a byte idêntica quando os repositórios forem atualizados.

## Verificação antes de uma release

1. Conferir sintaxe Python/Bash e unidades systemd.
2. Conferir partições, ext4 e FAT32 desmontados, e preservar o bootloader.
3. Conferir ausência de vídeos particulares, senhas, chaves SSH e histórico.
4. Gravar **outro cartão** e iniciar na Orange Pi One.
5. Testar MP4 com e sem áudio, loop, lista com vários arquivos e reinício.
6. Testar troca de `splash.png` e de vídeos diretamente pelo Windows.
7. Testar SSH por chave opcional e os botões.

A montagem em um PC não testa Cedrus, KMS, HDMI ou o comportamento da TV.
Só marcar a release como estável depois da verificação física.

# Validação — Os cabramaker 1.0

Estado: imagem candidata **v1.0-rc1**, preparada em 11/10/2026.
Não marcar como release estável antes de testar o novo cartão na placa.

## Verificações concluídas na montagem

- Checksum da base Armbian conferido com o esperado.
- Área de boot entre os bytes 512 e 4.194.303 preservada, comparada à base.
- Partições: ext4 de aproximadamente 3 GiB e FAT32 MIDIA de 4 GiB.
- `e2fsck -f -n` e `fsck.vfat -n`: sem erros.
- Sintaxe Python/Bash e unidades systemd verificadas.
- `dpkg --audit`: sem pacotes pendentes.
- Overlay PA6 aplicado a uma cópia do DTB: KEY_POWER 116, GPIO PA6 ativo baixo.
- Vídeo demonstrativo MP4/H.264 decodificado no PC, 125 quadros em 5 segundos.
- Integração do player em ARM emulado, com decoder por software e sinks de
  teste: arquivo único repetiu várias vezes; lista alternou arquivos com e
  sem áudio; nome com aspas foi aceito.
- Acesso SSH por chave pública testado no root filesystem ARM emulado.
- Chave pública de teste, chaves de servidor e arquivos temporários removidos.
- Root com senha bloqueada, SSH comum desabilitado, primeiro login HDMI
  mascarado, rotina Armbian que poderia reativar SSH mascarada.
- `machine-id` vazio para gerar uma identidade por instalação.

## Referência previamente testada

Na instalação particular, Orange Pi One H3, Armbian 26.8.1, kernel
6.18.44-current-sunxi, Cedrus `v4l2slh264dec` e `kmssink` reproduziram um MP4
H.264 1080p/30 com saída HDMI, sem quadros perdidos. A camada de vídeo com
`zpos=2` foi necessária para ficar acima do framebuffer do console.

## Pendente na nova imagem

- Boot completo na placa, em outro cartão.
- Windows reconhecendo MIDIA no leitor real.
- Banner por framebuffer, demonstração animada, vídeo real, áudio e repetição.
- Lista de vídeos e arquivo sem áudio usando **Cedrus/KMS reais**.
- Troca de banner pelo Windows, arquivo inválido e ausência de vídeos.
- SSH opcional no boot real, remoção da chave e chaves distintas entre cartões.
- Botão da placa e contato externo entre PA6 e GND.

Os testes por software não medem HDMI, aceleração Cedrus ou fluidez na placa.
Não modificar o cartão que já está funcionando para executar esses testes.

# Como usar — Os cabramaker 1.0

Criador: **Os cabramaker**, Instagram **@oscabramaker**.

## Material

- Orange Pi **One**, com processador Allwinner H3. Esta imagem não é destinada
  à One Plus, Zero, PC ou outras placas.
- Cartão microSD de pelo menos 8 GB e leitor para o computador.
- Fonte estável adequada à placa e cabo HDMI.
- Windows 10 versão 1703 ou posterior, ou Windows 11, para acessar a partição
  de mídia em leitores que identificam o cartão como dispositivo removível.

## Gravar

1. Baixe a imagem compactada e o arquivo SHA-256 da mesma release.
2. Confira o checksum. No PowerShell, execute `Get-FileHash` no arquivo
   baixado e compare com o arquivo de checksum.
3. Grave a imagem com balenaEtcher ou uma ferramenta equivalente, selecionando
   o cartão correto. A gravação apaga o cartão escolhido.
4. Ao terminar, retire e recoloque o cartão no leitor.
5. Abra a unidade **MIDIA**. A letra pode variar entre computadores.
6. Copie os vídeos para a pasta `videos` e, se quiser, um banner para
   `splash.png`, na raiz dessa unidade.
7. Ejete o cartão, coloque na placa, conecte HDMI e ligue.

Exemplo de verificação no PowerShell, aberto na pasta do download:

```powershell
Get-FileHash .\os-cabramaker-orangepi-one-v1.0-rc1.img.xz -Algorithm SHA256
```

Compare o valor com a linha desse arquivo em `SHA256SUMS.txt`. O
[balenaEtcher](https://etcher.balena.io/) pode receber a imagem `.img.xz`
diretamente; o formato XZ consta dos [testes oficiais](https://etcher-docs.balena.io/MANUAL-TESTING/).
Se a ferramenta exigir uma imagem extraída, descompacte para `.img` com 7-Zip.

Se o Windows oferecer formatação de outra partição do cartão, clique em
**Cancelar**. Essa partição contém o Linux e não precisa ser aberta.

## Trocar vídeos

Uma demonstração curta acompanha a imagem. Apague `01-demonstracao.mp4` antes
de colocar seus próprios vídeos, se não quiser que ela continue na lista.

Desligue a placa antes de retirar o cartão. Coloque no PC, abra **MIDIA/videos**,
apague o vídeo antigo e copie o novo. Ejete, recoloque e ligue.

Pode haver mais de um vídeo: os arquivos `.mp4` são reproduzidos em ordem de
nome. Use `01.mp4`, `02.mp4`, `03.mp4` para definir a ordem. A lista repete
quando chega ao final. Arquivos fora dessa pasta são ignorados.

Use **MP4 com vídeo H.264, 8 bits, 4:2:0**, até 1920×1080 a 30 quadros/s.
1080p é decodificado pelo Cedrus e escalado para a saída HDMI de 720p.
Áudio, quando presente, é encaminhado ao dispositivo ALSA padrão da placa.
MP4 é um contêiner: um MP4 com vídeo HEVC/H.265, AV1 ou H.264 de 10 bits não é
compatível com esse player. Não há conversão automática nem fallback por CPU.

FAT32 aceita arquivos de até 4 GiB menos 1 byte; a área de mídia desta versão
tem aproximadamente 4 GB no total. Em cartões maiores, o espaço extra fica
sem uso nesta versão para manter a estrutura simples.

A proporção do vídeo é preservada. Podem existir faixas em telas ou vídeos
com proporções diferentes. Ajustes de tamanho da própria TV também influenciam.

## Trocar o banner

O banner padrão identifica Os cabramaker, versão 1.0, e @oscabramaker.

Copie um PNG chamado **splash.png** para a raiz de **MIDIA**, substituindo o
anterior. Não coloque esse arquivo dentro de `videos`.

Ele é lido a cada boot, centralizado sobre fundo preto e ajustado à tela sem
distorção. Não precisa de SSH nem reconstrução da imagem. Use um PNG de até
20 megapixels; para iniciar mais rápido, prefira 1280×720.

O banner aparece quando o Linux disponibiliza a tela e monta o cartão. Os
textos do Linux são silenciados no HDMI; as mensagens iniciais do U-Boot podem
aparecer antes do banner. A imagem não promete um logo desde o primeiro instante.
Sem banner válido, o vídeo deve continuar iniciando normalmente.

## Botões

O botão da placa solicita uma reinicialização normal. Opcionalmente, ligue
um botão momentâneo normalmente aberto entre **pino físico 7 (PA6)** e
**pino físico 9 (GND)** do conector. É apenas contato seco entre esses pinos,
sem alimentação externa. PA6 fica reservado para essa função nesta imagem.

## SSH opcional

Por padrão, não há senha pública de SSH nem servidor SSH ativo. Para habilitar
acesso, crie uma chave no seu computador:

```powershell
ssh-keygen -t ed25519
```

Copie somente o arquivo **público**, normalmente
`C:\Users\SEU_USUARIO\.ssh\id_ed25519.pub`, para **MIDIA/ssh.pub**.
Guarde a chave privada no computador; não a copie para o cartão.

Ao iniciar, a placa valida a chave e ativa SSH. Encontre o endereço atribuído
pelo roteador e conecte:

```powershell
ssh root@ENDERECO_IP
```

Para desativar, remova `ssh.pub` do cartão com a placa desligada e reinicie.
O endereço IP não é fixo; esta imagem não inclui o endereço da instalação do
criador nem suas credenciais. Cada cartão gera suas próprias chaves de servidor.

## Diagnóstico

Por SSH:

```sh
systemctl status cabramaker-video --no-pager
cat /run/cabramaker/status.json
journalctl -u cabramaker-video -n 50 --no-pager
journalctl -u cabramaker-splash -n 20 --no-pager
```

Se não houver vídeo, confira se há MP4/H.264 na pasta correta. Se houver erro
de decodificação, confira o codec do arquivo. Se a TV estiver sem sinal,
teste o cabo e verifique se ela aceita 1280×720 a 60 Hz.

Não há desktop nem controle por mouse. As alterações normais de mídia são
feitas no cartão, com a placa desligada.

Referência de compatibilidade de várias partições em mídia removível:
[Microsoft Learn](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe--use-a-single-usb-key-for-winpe-and-a-wim-file---wim?view=windows-11).

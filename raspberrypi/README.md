# Os cabramaker 1.0 — Raspberry Pi 3 B / 3 B+

Criador: **Os cabramaker** · Instagram: [@oscabramaker](https://www.instagram.com/oscabramaker/).

Player automático sem desktop: liga, exibe o banner e reproduz MP4/H.264 em repetição, com HDMI em **720p/60 Hz**.
Inicialização e reprodução confirmadas em **Raspberry Pi 3 Model B v1.2**. O **3 Model B+** usa a mesma imagem, mas seu teste físico ainda está pendente. [Resultados e limites dos testes](docs/VALIDACAO.md).

## Baixar e gravar

1. Baixe a imagem ZIP no [release Raspberry Pi v1.0](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player/releases/tag/raspberrypi-v1.0).
2. Extraia e escolha o arquivo **os-cabramaker-raspberrypi3-v1.0.img** no Raspberry Pi Imager, em imagem personalizada.
3. Grave em um microSD de **8 GB ou maior**, sem aplicar personalizações do Imager. A gravação apaga o cartão selecionado.
4. Retire e recoloque o cartão no computador. Abra a unidade **MIDIA**.
5. Copie seus vídeos para `videos`, apague a demonstração se desejar e substitua `splash.png` pelo seu banner.
6. Ejete, coloque na placa, conecte HDMI e ligue com uma fonte micro USB adequada.

**Não grave a imagem limpa usada na construção.** Somente os arquivos da release já contêm o player e o início automático.

## Trocar vídeo e banner pelo Windows

```text
MIDIA/
├── videos/
│   └── 01-demonstracao.mp4
├── splash.png
├── LEIA-ME.txt
└── arquivos de firmware e boot — preservar
```

A MIDIA é a primeira partição FAT32 e também contém os arquivos necessários para ligar a placa. Altere somente os vídeos, o banner e, opcionalmente, `ssh.pub`.
Se o Windows não atribuir uma letra, use o **Gerenciamento de Disco → MIDIA (FAT32) → Alterar letra de unidade**. Não formate a partição Linux que o Windows não reconhece.
Desligue a placa antes de retirar o cartão e ejete com segurança no PC.

São cerca de **3,4 GiB disponíveis** para mídia após o firmware. FAT32 limita cada arquivo a menos de 4 GiB. O espaço adicional de cartões maiores não é expandido automaticamente.

## Reprodução

- MP4 com vídeo H.264; para o primeiro teste prefira 720p/30 fps. Arquivos 1080p/30 fps são reproduzidos com saída em 720p.
- Um vídeo ou uma lista ordenada por nome, repetida automaticamente. As transições podem ter um intervalo.
- Áudio dirigido ao HDMI. A imagem conserva a proporção; faixas existentes no arquivo ou na configuração da TV podem continuar visíveis.
- Banner PNG centralizado, sem distorção, com suporte a framebuffer RGB565 e 32 bits.
- Não exige criar usuário nem digitar login. Sem comando de desligamento automático.
- Com a pasta de vídeos vazia, o player aguarda conteúdo; reinicie depois de trocar os arquivos.

O banner aparece após o framebuffer Linux e a mídia ficarem disponíveis; não cobre necessariamente os primeiros instantes do firmware.

## Botão e SSH

Um botão momentâneo entre **pino físico 7 (BCM4)** e **pino físico 9 (GND)** solicita reinício via Linux. Não aplique tensão no contato. O botão não é um reset elétrico e ainda precisa de validação física nesta edição.

SSH é opcional: copie sua **chave pública OpenSSH** para `MIDIA/ssh.pub` e conecte Ethernet. Use `ssh root@cabramaker-pi.local` ou o IP do roteador, com a chave privada permanecendo no PC.
Não há senha padrão nem credenciais de Wi-Fi pré-configuradas. Remova `ssh.pub` e reinicie para desativar o acesso.

## Diagnóstico e construção

O arquivo `STATUS-PI3.txt` é atualizado na MIDIA aproximadamente um minuto após cada partida, sem parar a reprodução. Ele contém informações do sistema e dos vídeos; revise antes de compartilhar. Não está incluído na imagem de fábrica.

- [Construir a imagem](docs/CONSTRUIR.md)
- [Testes e validação](docs/VALIDACAO.md)
- [Componentes e licenças](docs/THIRD_PARTY.md)
- [Base oficial e checksum](docs/BASE.json)

MIT para o código próprio. Raspberry Pi OS, Debian, VLC e demais componentes preservam suas licenças. A distribuição inclui apenas banner e demonstração próprios, sem vídeos comerciais nem credenciais particulares.

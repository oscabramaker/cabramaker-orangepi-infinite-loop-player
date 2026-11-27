# Validação — Raspberry Pi 1.0

Versão fechada em 2026-11-27. Inicialização automática e reprodução confirmadas pelo proprietário em **Raspberry Pi 3 Model B v1.2**, após manter `console=tty1` e corrigir o splash para framebuffer de 16 ou 32 bits.

O diagnóstico físico registrou HDMI 1280×720/60 Hz, plano DRM cobrindo toda a área de saída, temperatura de 47,8 °C e `throttled=0x0`. Esses números representam a amostra coletada, não um ensaio térmico prolongado. Pequenas faixas do arquivo de teste foram preservadas.

A imagem pública usa a mesma configuração final com uma demonstração própria; a cópia particular testada utilizou o vídeo original do proprietário. O conteúdo comercial não é distribuído.

| Verificação | Estado |
| --- | --- |
| Boot e início do vídeo no 3 B v1.2 | Confirmados pelo proprietário |
| HDMI 720p e plano de vídeo em tela inteira | Confirmados no diagnóstico |
| Partição MIDIA acessível pelo Windows | Confirmada; pode exigir atribuição de letra |
| Splash RGB565/BGR565/32 bits | Codificação testada; ajuste aplicado à configuração confirmada |
| Python, shell, unidades systemd e pacotes | Verificados durante a preparação |
| Decodificação VLC ARM64 emulada | Confirmada com saída dummy |
| SSH por chave em ARM64 emulado | Confirmado; chaves de teste removidas |
| FAT32/ext4 e integridade do pacote | Verificados no fechamento |
| Teste físico no 3 B+ | Pendente |
| Ensaio cronometrado de 30 minutos, lista e áudio HDMI | Pendente |
| Botão GPIO e acesso SSH por rede na placa | Pendente |

A execução emulada não comprova desempenho, decodificação de hardware, HDMI ou GPIO. Não foi feita certificação desses componentes. Novas builds devem repetir as verificações de integridade e os testes físicos.

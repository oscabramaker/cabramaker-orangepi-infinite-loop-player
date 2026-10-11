# Publicação no GitHub

Os cabramaker 1.0 — @oscabramaker.

1. Crie um repositório público, por exemplo `orangepi-video-player`.
2. Envie o conteúdo desta pasta, exceto `build/` e as imagens compactadas.
   A licença MIT já contém a autoria Os cabramaker.
3. Faça o teste físico descrito em `VALIDACAO.md` e registre o resultado.
4. Crie uma release. Durante o teste use uma release de pré-lançamento;
   só publique `v1.0` como estável depois de validar na placa.
5. Anexe a imagem `.img.xz`, `SHA256SUMS.txt` e `packages.tsv`.
6. Mantenha o README apontando para a release e para as instruções.

A imagem deve ficar nos anexos da release. Não envie o arquivo `.img` de
7 GiB para o histórico Git. A pasta `build/` é privada de preparação e contém
arquivos temporários do ambiente de montagem; ela não entra no pacote público.

Antes da publicação, confira créditos/fontes/licenças de terceiros indicados
em `THIRD_PARTY.md`, os resultados dos testes e os anexos da release.

Repositório: [https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player](https://github.com/oscabramaker/cabramaker-orangepi-infinite-loop-player).
A release inicial deve ser marcada como pré-lançamento v1.0-rc1.

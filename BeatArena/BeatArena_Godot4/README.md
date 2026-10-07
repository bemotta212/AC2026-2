# Beat Arena - Godot 4

Projeto acadêmico para a disciplina de Jogos Digitais.

## Objetivo

Demonstrar o mapeamento do espectro sonoro para parâmetros de animação, usando:

- Graves (20-250 Hz): escala e velocidade dos inimigos.
- Médios (250-2000 Hz): trajetória e direção.
- Agudos (2000-10000 Hz): partículas e rotação.
- Energia geral: frequência de surgimento de inimigos.

## Como abrir

1. Instale Godot 4.x.
2. Abra o arquivo `project.godot`.
3. Execute o projeto.
4. Use WASD ou as setas para mover o jogador.

O projeto já possui um áudio de demonstração sintetizado, portanto funciona mesmo sem música externa.

## Usar uma música real

Coloque um arquivo chamado:

`assets/music.ogg`

Depois execute novamente. O projeto tentará usar esse arquivo antes de utilizar o áudio de demonstração.

Para evitar problemas de distribuição, não incluí nenhuma música comercial no projeto.

## Estrutura

- `scenes/Main.tscn` - cena principal.
- `scripts/main.gd` - arena, música, partículas e geração de inimigos.
- `scripts/audio_analyzer.gd` - FFT/análise das bandas.
- `scripts/enemy.gd` - comportamento dos inimigos.
- `scripts/player.gd` - movimentação do jogador.
- `scripts/hud.gd` - interface e barras do espectro.

## Mapeamento

| Banda | Faixa | Parâmetros |
|---|---|---|
| Graves | 20-250 Hz | escala e velocidade |
| Médios | 250-2000 Hz | trajetória e direção |
| Agudos | 2000-10000 Hz | partículas e rotação |
| Geral | média das três | frequência de spawn |

Os valores são suavizados por interpolação para evitar movimentos bruscos.

## Observação

O áudio de demonstração é gerado proceduralmente pelo próprio projeto. Isso facilita a apresentação sem depender de um arquivo de música externo.

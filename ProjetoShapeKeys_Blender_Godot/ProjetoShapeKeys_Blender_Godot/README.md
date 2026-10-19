# Projeto Shape Keys — Blender 5.2.2 LTS + Godot 4.6

Este ZIP contém um script para preparar Suzanne no Blender, um projeto inicial do Godot e instruções de exportação/importação.

## Conteúdo
- `Blender/criar_suzanne_shape_keys.py`: executado no Blender, cria Suzanne, 3 Shape Keys e animação na timeline.
- `Godot/`: projeto inicial Godot 4.6 com controles de teclado.
- `Godot/models/`: coloque aqui o arquivo `Suzanne.glb` exportado do Blender.

## Parte 1 — Blender
1. Abra o Blender 5.2.2.
2. Vá para a aba **Scripting**.
3. Clique em **Open** e selecione `Blender/criar_suzanne_shape_keys.py`.
4. Clique em **Run Script**.
5. Volte à aba Layout e pressione Espaço na Timeline para testar.
6. Exporte por **File > Export > glTF 2.0**.
7. Escolha **glTF Binary (.glb)** e salve como `Suzanne.glb`.
8. Nas opções de exportação, inclua os objetos selecionados e habilite as opções de animação/Shape Keys, quando disponíveis.

O script gera as chaves `Boca_Aberta`, `Olhos` e `Alongar`, além de keyframes para testar os pesos. As deformações são demonstrativas e podem ser refinadas manualmente no Blender.

## Parte 2 — Godot
1. Abra o Godot 4.6.
2. Importe/abra a pasta `Godot` deste ZIP como projeto.
3. Copie o arquivo exportado para `Godot/models/Suzanne.glb`.
4. Aguarde a importação terminar.
5. Execute o projeto com **F6** ou **F5**.

## Controles
- `Espaço`: reproduzir/pausar a animação importada.
- `1`, `2`, `3`: selecionar o primeiro, segundo ou terceiro Shape Key.
- `Seta para cima`: aumenta o peso em 0,1.
- `Seta para baixo`: diminui o peso em 0,1.
- O peso é limitado ao intervalo de 0 a 1.

Ao editar manualmente um Shape Key, o programa pausa a animação para que os keyframes não substituam imediatamente o valor definido pelo teclado.

## Observações
- O ZIP não contém `Suzanne.glb`, porque esse arquivo precisa ser exportado pelo Blender instalado no seu computador.
- O script do Godot procura a cena importada, um `MeshInstance3D` e um `AnimationPlayer`. Se o arquivo exportado tiver uma hierarquia diferente, veja a árvore de nós importada e ajuste o script.
- Se os nomes das animações importadas forem diferentes, o script toca a primeira animação encontrada.

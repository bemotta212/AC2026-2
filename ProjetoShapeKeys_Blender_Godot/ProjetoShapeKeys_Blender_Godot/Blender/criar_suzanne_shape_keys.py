import bpy
import math

# Limpa a cena e cria Suzanne.
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

bpy.ops.mesh.primitive_monkey_add(location=(0, 0, 0))
obj = bpy.context.object
obj.name = "Suzanne"

# Suaviza visualmente a malha.
for poly in obj.data.polygons:
    poly.use_smooth = True
sub = obj.modifiers.new("Subdivision", 'SUBSURF')
sub.levels = 2
sub.render_levels = 2

# Cria Basis e três Shape Keys.
obj.shape_key_add(name="Basis", from_mix=False)
mouth = obj.shape_key_add(name="Boca_Aberta", from_mix=False)
eyes = obj.shape_key_add(name="Olhos", from_mix=False)
stretch = obj.shape_key_add(name="Alongar", from_mix=False)

# Deformações demonstrativas baseadas na posição dos vértices.
# Suzanne olha para -Y; a parte inferior/frontal do rosto é aproximada por z < 0.
basis = obj.data.shape_keys.key_blocks["Basis"]
for i, v in enumerate(basis.data):
    x, y, z = v.co
    # Abrir a região inferior da boca: desloca vértices inferiores para baixo.
    if y < 0.0 and z < -0.15:
        mouth.data[i].co.z -= 0.18 * min(1.0, abs(z))
    # Aumenta levemente a área em torno dos olhos.
    if y < -0.1 and 0.05 < z < 0.55 and abs(x) > 0.18:
        eyes.data[i].co.x += math.copysign(0.10, x)
        eyes.data[i].co.z += 0.035
    # Alongamento horizontal sutil.
    stretch.data[i].co.x *= 1.18
    stretch.data[i].co.z *= 0.96

# Animação dos pesos na timeline: 1 a 72 quadros.
scene = bpy.context.scene
scene.frame_start = 1
scene.frame_end = 72
scene.render.fps = 24

for key in (mouth, eyes, stretch):
    key.value = 0.0
    key.keyframe_insert(data_path="value", frame=1)

mouth.value = 1.0
mouth.keyframe_insert(data_path="value", frame=18)
eyes.value = 0.0
eyes.keyframe_insert(data_path="value", frame=18)
stretch.value = 0.0
stretch.keyframe_insert(data_path="value", frame=18)

mouth.value = 0.0
mouth.keyframe_insert(data_path="value", frame=36)
eyes.value = 1.0
eyes.keyframe_insert(data_path="value", frame=36)
stretch.value = 0.0
stretch.keyframe_insert(data_path="value", frame=36)

mouth.value = 0.0
mouth.keyframe_insert(data_path="value", frame=54)
eyes.value = 0.0
eyes.keyframe_insert(data_path="value", frame=54)
stretch.value = 1.0
stretch.keyframe_insert(data_path="value", frame=54)

for key in (mouth, eyes, stretch):
    key.value = 0.0
    key.keyframe_insert(data_path="value", frame=72)

# Deixa Suzanne selecionado para facilitar a inspeção/exportação.
bpy.context.view_layer.objects.active = obj
obj.select_set(True)
scene.frame_set(1)
print("Pronto: Suzanne com Basis + 3 Shape Keys e animação nos quadros 1–72.")

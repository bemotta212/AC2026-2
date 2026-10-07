extends CanvasLayer

@onready var audio: AudioAnalyzer = get_parent().get_node("AudioAnalyzer")

var title_label: Label
var info_label: Label
var bass_bar: ProgressBar
var mid_bar: ProgressBar
var treble_bar: ProgressBar
var overall_bar: ProgressBar

func _ready() -> void:
	_build_ui()

func _process(_delta: float) -> void:
	if audio == null:
		return

	bass_bar.value = audio.bass * 100.0
	mid_bar.value = audio.mid * 100.0
	treble_bar.value = audio.treble * 100.0
	overall_bar.value = audio.overall * 100.0

	info_label.text = (
        "WASD / SETAS  •  Mova o jogador  •  "
		+ "Graves = escala/velocidade  •  Médios = trajetória  •  Agudos = partículas/rotação"
	)

func _build_ui() -> void:
	title_label = Label.new()
	title_label.position = Vector2(48, 44)
	title_label.text = "BEAT ARENA"
	title_label.add_theme_font_size_override("font_size", 28)
	add_child(title_label)

	info_label = Label.new()
	info_label.position = Vector2(48, 675)
	info_label.add_theme_font_size_override("font_size", 14)
	add_child(info_label)

	var panel := PanelContainer.new()
	panel.position = Vector2(925, 42)
	panel.size = Vector2(300, 230)
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var header := Label.new()
	header.text = "AUDIO SPECTRUM"
	header.add_theme_font_size_override("font_size", 20)
	box.add_child(header)

	bass_bar = _make_bar("GRAVES 20-250 Hz", box)
	mid_bar = _make_bar("MÉDIOS 250-2000 Hz", box)
	treble_bar = _make_bar("AGUDOS 2-10 kHz", box)
	overall_bar = _make_bar("ENERGIA GERAL", box)

func _make_bar(label_text: String, parent: VBoxContainer) -> ProgressBar:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 0
	bar.show_percentage = true
	bar.custom_minimum_size = Vector2(260, 24)
	parent.add_child(bar)
	return bar

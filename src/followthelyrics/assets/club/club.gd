extends Node3D

const PORT := 39671
const CROWD_SIZE := 44

var receiver := PacketPeerUDP.new()
var energy := 0.0
var bass := 0.0
var beat := 0.0
var clock := 0.0
var dancers: Array[Node3D] = []
var lamps: Array[SpotLight3D] = []
var led_panels: Array[MeshInstance3D] = []
var camera: Camera3D
var view_mode := 0


func _ready() -> void:
	DisplayServer.window_set_title("FTL Club Mode | 1: DJ  2: Balcony  3: Dancefloor  F11: Fullscreen")
	receiver.bind(PORT, "127.0.0.1")
	_build_room()
	_build_dj_booth()
	_build_crowd()
	_build_lights()
	camera = Camera3D.new()
	add_child(camera)
	_set_camera(0)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("070410")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("302447")
	environment.environment.ambient_light_energy = 0.35
	add_child(environment)
	var label := Label.new()
	label.text = "FTL CLUB MODE  |  1 DJ  /  2 BALCONY  /  3 FLOOR  /  F11 FULLSCREEN"
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(20, 18)
	var ui := CanvasLayer.new()
	add_child(ui)
	ui.add_child(label)


func _box(name: String, size: Vector3, location: Vector3, color: Color, metallic := 0.0) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.name = name
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = location
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = 0.25 if metallic > 0.0 else 0.8
	mesh.material_override = mat
	add_child(mesh)
	return mesh


func _build_room() -> void:
	_box("Dancefloor", Vector3(24, 0.3, 20), Vector3(0, -0.3, 0), Color("141324"), 0.3)
	_box("Back wall", Vector3(24, 9, 0.4), Vector3(0, 4.2, -10), Color("10101b"))
	_box("Left wall", Vector3(0.4, 9, 20), Vector3(-12, 4.2, 0), Color("0b0b17"))
	_box("Right wall", Vector3(0.4, 9, 20), Vector3(12, 4.2, 0), Color("0b0b17"))
	_box("Ceiling", Vector3(24, 0.4, 20), Vector3(0, 8.7, 0), Color("080811"))
	for i in range(14):
		var x := -10.5 + i * 1.62
		_box("Floor strip", Vector3(0.04, 0.02, 19), Vector3(x, -0.12, 0), Color("31314d"))
	for i in range(11):
		var z := -8.8 + i * 1.8
		_box("Floor grid", Vector3(23, 0.02, 0.04), Vector3(0, -0.11, z), Color("272740"))


func _build_dj_booth() -> void:
	_box("Stage", Vector3(11, 1.1, 4), Vector3(0, 0.35, -7.3), Color("1d1b29"))
	_box("DJ desk", Vector3(7, 1.25, 1.4), Vector3(0, 1.55, -7.4), Color("080811"), 0.3)
	for i in range(17):
		var x := -4.8 + i * 0.6
		led_panels.append(_box("LED", Vector3(0.39, 3.4, 0.12), Vector3(x, 4.6, -9.6), Color("4721a4")))
	for i in range(2):
		_box("Speaker", Vector3(1.4, 3.2, 1.2), Vector3(-6.8 if i == 0 else 6.8, 1.6, -8.8), Color("08080e"))
		for j in range(2):
			var speaker := _box("Cone", Vector3(0.85, 0.85, 0.08), Vector3(-6.8 if i == 0 else 6.8, 0.9 + j * 1.25, -8.13), Color("26233a"))
			speaker.rotation.x = 0


func _build_crowd() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 73201
	for i in range(CROWD_SIZE):
		var dancer := Node3D.new()
		dancer.position = Vector3(random.randf_range(-9.2, 9.2), 0, random.randf_range(-3.2, 7.6))
		dancer.set_meta("offset", random.randf_range(0.0, TAU))
		dancer.set_meta("speed", random.randf_range(0.8, 1.35))
		add_child(dancer)
		var body := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = random.randf_range(0.27, 0.35)
		capsule.height = random.randf_range(1.4, 2.0)
		body.mesh = capsule
		body.position.y = capsule.height * 0.5
		var material := StandardMaterial3D.new()
		material.albedo_color = Color.from_hsv(random.randf_range(0.55, 0.9), 0.35, random.randf_range(0.18, 0.48))
		body.material_override = material
		dancer.add_child(body)
		dancers.append(dancer)


func _build_lights() -> void:
	for i in range(8):
		var lamp := SpotLight3D.new()
		lamp.position = Vector3(-9 + (i % 4) * 6.0, 8.1, -4 + (i / 4) * 8.0)
		lamp.light_color = Color.from_hsv(float(i) / 8.0, 0.85, 1.0)
		lamp.light_energy = 5.0
		lamp.spot_range = 17
		lamp.spot_angle = 27
		add_child(lamp)
		lamps.append(lamp)


func _set_camera(mode: int) -> void:
	view_mode = mode
	match mode:
		0:
			camera.position = Vector3(0, 4.4, -6.0)
			camera.look_at(Vector3(0, 1.0, 3.5))
		1:
			camera.position = Vector3(11, 7.0, 8.5)
			camera.look_at(Vector3(0, 1.0, -2.0))
		2:
			camera.position = Vector3(0, 1.9, 6.5)
			camera.look_at(Vector3(0, 2.2, -8.0))


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1, KEY_2, KEY_3:
				_set_camera(event.keycode - KEY_1)
			KEY_F11:
				var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
			KEY_ESCAPE:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _process(delta: float) -> void:
	clock += delta
	while receiver.get_available_packet_count() > 0:
		var payload = JSON.parse_string(receiver.get_packet().get_string_from_utf8())
		if payload is Dictionary:
			energy = clampf(float(payload.get("energy", 0.0)), 0.0, 1.0)
			bass = clampf(float(payload.get("bass", 0.0)), 0.0, 1.0)
			beat = maxf(beat, clampf(float(payload.get("beat", 0.0)), 0.0, 1.0))
	beat = maxf(0.0, beat - delta * 2.8)
	for i in range(dancers.size()):
		var dancer := dancers[i]
		var phase: float = clock * (1.5 + energy * 4.0) * float(dancer.get_meta("speed")) + float(dancer.get_meta("offset"))
		dancer.position.y = maxf(0.0, sin(phase) * (0.04 + 0.18 * bass) + beat * 0.24)
		dancer.rotation.z = sin(phase * 0.7) * (0.07 + energy * 0.16)
		dancer.rotation.y = sin(phase * 0.32) * 0.3
	for i in range(lamps.size()):
		var lamp := lamps[i]
		lamp.rotation.x = sin(clock * 0.65 + i) * 0.25
		lamp.rotation.z = sin(clock * 0.55 + i * 1.8) * 0.5
		lamp.light_energy = 1.4 + energy * 4.0 + beat * 4.5
	for i in range(led_panels.size()):
		var panel := led_panels[i]
		var material := panel.material_override as StandardMaterial3D
		material.albedo_color = Color.from_hsv(fmod(clock * 0.035 + float(i) / 22.0, 1.0), 0.82, 0.3 + energy * 0.7)

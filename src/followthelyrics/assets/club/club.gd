extends Node3D

const PORT := 39671
const CROWD_SIZE := 38

var receiver := PacketPeerUDP.new()
var energy := 0.0
var bass := 0.0
var beat := 0.0
var clock := 0.0
var dancers: Array[Node3D] = []
var dancer_data: Array[Dictionary] = []
var lamps: Array[SpotLight3D] = []
var led_panels: Array[MeshInstance3D] = []
var floor_tiles: Array[MeshInstance3D] = []
var camera: Camera3D
var view_mode := 0


func _ready() -> void:
	DisplayServer.window_set_title("FTL Club Mode | 1: DJ  2: Balcony  3: Dancefloor  F11: Fullscreen")
	receiver.bind(PORT, "127.0.0.1")
	_build_room()
	_build_dj_booth()
	_build_furnishings()
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
	environment.environment.ambient_light_color = Color("54496a")
	environment.environment.ambient_light_energy = 0.45
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


func _part(parent: Node3D, name: String, radius: float, height: float, location: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = maxf(height, radius * 2.0)
	part.mesh = shape
	part.position = location
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	part.material_override = material
	parent.add_child(part)
	return part


func _emissive(mesh: MeshInstance3D, color: Color) -> void:
	var material := mesh.material_override as StandardMaterial3D
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color


func _build_room() -> void:
	_box("Dancefloor", Vector3(24, 0.3, 20), Vector3(0, -0.3, 0), Color("101017"), 0.4)
	_box("Back wall", Vector3(24, 9, 0.4), Vector3(0, 4.2, -10), Color("0e0d16"))
	_box("Left wall", Vector3(0.4, 9, 20), Vector3(-12, 4.2, 0), Color("0d0d14"))
	_box("Right wall", Vector3(0.4, 9, 20), Vector3(12, 4.2, 0), Color("0d0d14"))
	_box("Ceiling", Vector3(24, 0.4, 20), Vector3(0, 8.7, 0), Color("08080d"))
	for x in range(-10, 11, 2):
		for z in range(-4, 9, 2):
			var tile := _box("Dance tile", Vector3(1.91, 0.018, 1.91), Vector3(float(x), -0.12, float(z)), Color("17151f"), 0.2)
			floor_tiles.append(tile)
	for i in range(9):
		var x := -11.0 + i * 2.75
		_box("Acoustic wall left", Vector3(0.08, 4.7, 1.95), Vector3(-11.72, 3.45, -8.5 + i * 2.2), Color("16151c"))
		_box("Acoustic wall right", Vector3(0.08, 4.7, 1.95), Vector3(11.72, 3.45, -8.5 + i * 2.2), Color("16151c"))
		var strip := _box("Ceiling truss", Vector3(0.2, 0.2, 19.0), Vector3(x, 8.0, 0), Color("2d2a36"), 0.6)
		strip.rotation.z = 0.0
	for z in [-7.5, -2.0, 3.5, 8.0]:
		_box("Cross truss", Vector3(23, 0.19, 0.19), Vector3(0, 8.0, z), Color("35323c"), 0.6)
		_emissive(_box("Wall neon left", Vector3(0.07, 0.1, 4.0), Vector3(-11.54, 5.7, z), Color("6540b8")), Color("403074"))
		_emissive(_box("Wall neon right", Vector3(0.07, 0.1, 4.0), Vector3(11.54, 5.7, z), Color("305c9b")), Color("2c436c"))


func _build_dj_booth() -> void:
	_box("Stage", Vector3(13, 0.9, 4), Vector3(0, 0.32, -7.9), Color("20202c"), 0.4)
	_box("Stage lip", Vector3(13.2, 0.16, 0.16), Vector3(0, 0.85, -5.88), Color("6e49b6"), 0.5)
	_box("DJ desk", Vector3(7, 1.25, 1.4), Vector3(0, 1.65, -7.3), Color("11131c"), 0.3)
	var desk_screen := _box("DJ booth screen", Vector3(6.8, 0.65, 0.07), Vector3(0, 1.66, -6.56), Color("32166f"))
	_emissive(desk_screen, Color("361e72"))
	for i in range(2):
		_box("Deck", Vector3(1.7, 0.08, 0.7), Vector3(-1.7 if i == 0 else 1.7, 2.34, -7.3), Color("393a43"), 0.8)
		_box("Mixer", Vector3(0.6, 0.09, 0.75), Vector3(0, 2.35, -7.3), Color("0e0e11"), 0.7)
	for i in range(17):
		var x := -4.8 + i * 0.6
		var panel := _box("LED", Vector3(0.39, 3.4, 0.12), Vector3(x, 4.8, -9.63), Color("4721a4"))
		_emissive(panel, Color("4721a4"))
		led_panels.append(panel)
	for i in range(2):
		_box("Speaker", Vector3(1.4, 3.2, 1.2), Vector3(-6.8 if i == 0 else 6.8, 1.6, -8.8), Color("08080e"))
		for j in range(2):
			_box("Cone", Vector3(0.85, 0.85, 0.08), Vector3(-6.8 if i == 0 else 6.8, 0.9 + j * 1.25, -8.13), Color("26233a"))


func _build_furnishings() -> void:
	for side in [-1.0, 1.0]:
		_box("Raised lounge", Vector3(2.7, 0.55, 12), Vector3(side * 10.2, 0.12, 0), Color("22202a"), 0.2)
		_box("Lounge railing", Vector3(0.1, 0.85, 12), Vector3(side * 8.8, 1.05, 0), Color("35323c"), 0.8)
		for z in [-4.5, -1.5, 1.5, 4.5]:
			_box("Sofa", Vector3(1.6, 0.48, 1.45), Vector3(side * 10.5, 0.72, z), Color("352b40"))
			_box("Sofa back", Vector3(0.25, 0.65, 1.45), Vector3(side * 11.3, 1.15, z), Color("302638"))
			_box("Table", Vector3(0.7, 0.08, 0.75), Vector3(side * 9.12, 0.79, z), Color("433d49"), 0.7)
	for x in [-8.0, 8.0]:
		_box("Pillar", Vector3(0.55, 8.2, 0.55), Vector3(x, 4.0, -7.0), Color("25232b"), 0.8)
		_emissive(_box("Pillar light", Vector3(0.59, 0.09, 0.59), Vector3(x, 5.6, -7.0), Color("7b40b1")), Color("603093"))


func _build_crowd() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 73201
	for i in range(CROWD_SIZE):
		var dancer := Node3D.new()
		var col := i % 8
		var row := i / 8
		dancer.position = Vector3(-7.0 + col * 2.0 + random.randf_range(-0.55, 0.55), 0.0, -3.3 + row * 2.3 + random.randf_range(-0.4, 0.4))
		dancer.rotation.y = random.randf_range(-0.55, 0.55)
		add_child(dancer)
		var scale_value := random.randf_range(0.88, 1.13)
		dancer.scale = Vector3.ONE * scale_value
		var skin := Color.from_hsv(random.randf_range(0.05, 0.11), random.randf_range(0.12, 0.6), random.randf_range(0.32, 0.83))
		var shirt := Color.from_hsv(random.randf(), random.randf_range(0.16, 0.65), random.randf_range(0.13, 0.55))
		var trousers := Color.from_hsv(random.randf_range(0.57, 0.77), 0.19, random.randf_range(0.1, 0.28))

		var torso := Node3D.new()
		torso.position.y = 0.97
		dancer.add_child(torso)
		_part(torso, "Jacket", 0.27, 0.75, Vector3(0, 0.31, 0), shirt)
		_part(torso, "Neck", 0.08, 0.17, Vector3(0, 0.72, 0), skin)
		var head := Node3D.new()
		head.position.y = 0.87
		torso.add_child(head)
		_part(head, "Head", 0.17, 0.34, Vector3.ZERO, skin)
		var hair := _part(head, "Hair", 0.177, 0.18, Vector3(0, 0.13, -0.01), Color.from_hsv(random.randf_range(0.05, 0.17), 0.29, random.randf_range(0.06, 0.3)))
		hair.scale.z = 1.06

		var arms: Array[Node3D] = []
		var elbows: Array[Node3D] = []
		var legs: Array[Node3D] = []
		var knees: Array[Node3D] = []
		for side in [-1.0, 1.0]:
			var shoulder := Node3D.new()
			shoulder.position = Vector3(side * 0.33, 0.6, 0)
			torso.add_child(shoulder)
			_part(shoulder, "Sleeve", 0.115, 0.48, Vector3(0, -0.22, 0), shirt)
			var elbow := Node3D.new()
			elbow.position.y = -0.42
			shoulder.add_child(elbow)
			_part(elbow, "Forearm", 0.085, 0.4, Vector3(0, -0.18, 0), skin)
			_part(elbow, "Hand", 0.09, 0.17, Vector3(0, -0.38, 0), skin)
			arms.append(shoulder)
			elbows.append(elbow)

			var hip := Node3D.new()
			hip.position = Vector3(side * 0.17, 0.94, 0)
			dancer.add_child(hip)
			_part(hip, "Trouser leg", 0.13, 0.58, Vector3(0, -0.28, 0), trousers)
			var knee := Node3D.new()
			knee.position.y = -0.53
			hip.add_child(knee)
			_part(knee, "Lower leg", 0.12, 0.47, Vector3(0, -0.22, 0), trousers)
			_part(knee, "Shoe", 0.14, 0.22, Vector3(0, -0.48, -0.09), Color("141419"))
			legs.append(hip)
			knees.append(knee)

		dancer_data.append({
			"torso": torso, "head": head, "arms": arms, "elbows": elbows,
			"legs": legs, "knees": knees,
			"phase": random.randf_range(0.0, TAU),
			"speed": random.randf_range(0.86, 1.18),
			"style": i % 4,
			"energy": random.randf_range(0.56, 1.0),
			"heading": dancer.rotation.y,
		})
		dancers.append(dancer)


func _build_lights() -> void:
	for i in range(8):
		var lamp := SpotLight3D.new()
		lamp.position = Vector3(-9 + (i % 4) * 6.0, 7.8, -4 + (i / 4) * 8.0)
		lamp.light_color = Color.from_hsv(float(i) / 8.0, 0.85, 1.0)
		lamp.light_energy = 3.0
		lamp.spot_range = 16
		lamp.spot_angle = 23
		add_child(lamp)
		lamps.append(lamp)
		_box("Moving head fixture", Vector3(0.48, 0.28, 0.46), lamp.position + Vector3(0, 0.38, 0), Color("212028"), 0.9)
	for i in range(8):
		var light := OmniLight3D.new()
		light.position = Vector3(-10.5 if i % 2 == 0 else 10.5, 4.5, -7.5 + i * 2.0)
		light.light_color = Color("7546aa") if i % 2 == 0 else Color("29628f")
		light.light_energy = 0.8
		light.omni_range = 6
		add_child(light)


func _set_camera(mode: int) -> void:
	view_mode = mode
	match mode:
		0:
			camera.position = Vector3(0, 4.8, -5.2)
			camera.look_at(Vector3(0, 1.5, 4.0))
		1:
			camera.position = Vector3(10.8, 6.3, 8.3)
			camera.look_at(Vector3(0, 1.0, -2.0))
		2:
			camera.position = Vector3(0, 2.2, 7.3)
			camera.look_at(Vector3(0, 2.2, -8.0))


func _animate_dancer(dancer: Node3D, data: Dictionary, time_step: float) -> void:
	var phase: float = time_step * (1.65 + energy * 2.7) * float(data["speed"]) + float(data["phase"])
	var activity: float = (0.19 + energy * 0.55 + bass * 0.35 + beat * 0.55) * float(data["energy"])
	var rhythm := sin(phase)
	var counter := sin(phase + PI)
	var style: int = data["style"]
	var torso: Node3D = data["torso"]
	var head: Node3D = data["head"]
	var arms: Array = data["arms"]
	var elbows: Array = data["elbows"]
	var legs: Array = data["legs"]
	var knees: Array = data["knees"]

	dancer.position.y = maxf(0.0, activity * 0.065 * (1.0 + rhythm) + beat * 0.1)
	dancer.rotation.y = float(data["heading"]) + sin(phase * 0.24) * activity * 0.16
	torso.rotation.z = rhythm * activity * (0.11 if style != 2 else 0.24)
	torso.rotation.x = sin(phase * 0.5) * activity * 0.08
	head.rotation.z = -torso.rotation.z * 0.42 + sin(phase + 0.5) * 0.045
	head.rotation.x = sin(phase * 0.75) * activity * 0.1

	for i in range(2):
		var side := -1.0 if i == 0 else 1.0
		var shoulder: Node3D = arms[i]
		var elbow: Node3D = elbows[i]
		var leg: Node3D = legs[i]
		var knee: Node3D = knees[i]
		var opposite := rhythm if i == 0 else counter
		match style:
			0:
				shoulder.rotation.z = side * (0.18 + activity * 0.38) + opposite * 0.17
				shoulder.rotation.x = opposite * activity * 0.42
			1:
				shoulder.rotation.z = side * (1.2 + 0.26 * sin(phase * 0.52 + i))
				shoulder.rotation.x = 0.28 * sin(phase + i)
			2:
				shoulder.rotation.z = side * (0.32 + 0.48 * activity * (0.5 + 0.5 * sin(phase + i)))
				shoulder.rotation.x = 0.58 * sin(phase * 0.68 + i * PI)
			_:
				shoulder.rotation.z = side * (0.12 + activity * 0.26) + opposite * 0.31
				shoulder.rotation.x = 0.44 + opposite * activity * 0.4
		elbow.rotation.x = -0.26 - activity * (0.25 + 0.4 * (0.5 + 0.5 * opposite))
		leg.rotation.x = opposite * (0.12 + activity * 0.16)
		leg.rotation.z = side * (0.015 + activity * 0.045)
		knee.rotation.x = 0.08 + activity * 0.1 * (0.5 + 0.5 * opposite)


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
		_animate_dancer(dancers[i], dancer_data[i], clock)
	for i in range(lamps.size()):
		var lamp := lamps[i]
		lamp.rotation.x = sin(clock * 0.65 + i) * 0.25
		lamp.rotation.z = sin(clock * 0.55 + i * 1.8) * 0.5
		lamp.light_energy = 1.3 + energy * 2.5 + beat * 3.5
	for i in range(led_panels.size()):
		var panel := led_panels[i]
		var material := panel.material_override as StandardMaterial3D
		material.albedo_color = Color.from_hsv(fmod(clock * 0.035 + float(i) / 22.0, 1.0), 0.82, 0.3 + energy * 0.7)
	for i in range(floor_tiles.size()):
		var tile := floor_tiles[i]
		var mat := tile.material_override as StandardMaterial3D
		var wave := maxf(0.0, sin(float(i % 11) * 0.44 + clock * 1.5))
		mat.albedo_color = Color("17151f").lerp(Color("2a2042"), (0.08 + beat * 0.4 + energy * 0.25) * wave)

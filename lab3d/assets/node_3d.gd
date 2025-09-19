extends Node3D

@onready var anim: AnimationPlayer = $Entry/AnimationPlayer

# map ปุ่ม → ชื่อแอนิเมชันใน AnimationPlayer (ต้องตรงตัวอักษร)
const ACTION_TO_ANIM := {
	"atk_light": "Melee-Library--OLD/SlashATK1",
	"atk_heavy": "Melee-Library--OLD/HeavyATK1",
	"run":       "Melee-Library--OLD/run",
	"idle":      "Melee-Library--OLD/Idle"
}

func _ready() -> void:
	_ensure_actions()

	# ใช้ชื่อ idle จากแมป และ fallback ถ้าไม่มี
	var idle_clip := ACTION_TO_ANIM["idle"]
	if not anim.has_animation(idle_clip):
		var list := anim.get_animation_list()
		push_warning("ไม่พบแอนิเมชัน idle: %s → จะใช้คลิปแรกแทน" % idle_clip)
		if list.is_empty():
			push_error("AnimationPlayer ไม่มีคลิปใดเลย ตรวจ path ของโหนดให้ถูก")
			return
		idle_clip = list[0]

	_play_clip(idle_clip)
	anim.animation_finished.connect(_on_anim_finished)

func _unhandled_input(event: InputEvent) -> void:
	for action in ACTION_TO_ANIM.keys():
		if event.is_action_pressed(action):
			_play_clip(ACTION_TO_ANIM[action])

# เปลี่ยนชื่อพารามิเตอร์ไม่ให้ชน Node.name
func _play_clip(clip: String) -> void:
	if not anim.has_animation(clip):
		push_warning("Animation not found: %s" % clip)
		return
	if anim.current_animation == clip:
		anim.seek(0.0, true)
	anim.play(clip)

func _on_anim_finished(finished_clip: StringName) -> void:
	var idle_clip := ACTION_TO_ANIM["idle"]
	if anim.has_animation(idle_clip) and finished_clip != StringName(idle_clip):
		_play_clip(idle_clip)

func _ensure_actions() -> void:
	var defs := {
		"atk_light": KEY_J,
		"atk_heavy": KEY_K,
		"run":       KEY_L,
		"idle":      KEY_H,
	}
	for a in defs.keys():
		if not InputMap.has_action(a):
			InputMap.add_action(a)
			var ev := InputEventKey.new()
			ev.physical_keycode = defs[a]
			InputMap.action_add_event(a, ev)

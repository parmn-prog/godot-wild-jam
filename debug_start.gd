extends Control
const PLAYGROUND = preload("uid://b8u2g7ssgxcsq")


func _on_physics_pressed() -> void:
	GameManager.ship_type = GameManager.Ship.Physics
	get_tree().change_scene_to_packed(PLAYGROUND)




func _on_direct_pressed() -> void:
	GameManager.ship_type = GameManager.Ship.Direct
	get_tree().change_scene_to_packed(PLAYGROUND)

extends Sprite

func _ready():
	print(scale)
	material.set_shader_param("sprite_scale", scale)

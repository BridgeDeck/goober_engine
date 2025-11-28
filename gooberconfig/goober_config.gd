extends Resource
class_name GooberConfig

@export var sprite_normal:Texture2D = preload("res://sprites/m_sticker_1.png")
@export var sprite_jumping:Texture2D = preload("res://sprites/m_sticker_2.png")

@export var speed:float = 200
@export var acceleration:float  = 400
@export var gravity:float = 300
@export var jumpforce:float = 150

@export var time_jump_minimum:float = 10
@export var time_jump_maximum:float = 10

@export var time_pause_minimum:float = 2.0
@export var time_pause_maximum:float = 3.0

@export var time_topause_minimum:float = 2
@export var time_topause_maximum:float = 3

extends Node

signal instance_player(id, cord, team)
signal toggle_network_setup(toggle)
signal change_health(id, health, attacker)
signal add_bullets(add_num)
signal spawn_sentry()

var server:bool = false
var player_pos = {}
var blue_sentry_alive = true
var red_sentry_alive = true
var debug = true

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_F4:
			get_tree().quit() # quits game

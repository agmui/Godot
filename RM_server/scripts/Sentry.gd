extends KinematicBody

# How fast the player moves in meters per second.
export var speed = 1

const rail_len = 100

var velocity = Vector3.ZERO
export var team = ""
export var health = 600
var fire_cooldown = false
var dead = false
var sensitivity = .2
var head_acc = 0 # when the player dies or overheats just have the head exponetaly plop down
var rng = RandomNumberGenerator.new()
var current_offset = 0
var offset = 0
# var move = 0
var shoot = false

onready var bullet = preload("res://scenes/Bullet.tscn") # loading in bullet into var

var puppet_position = Vector3.ZERO
var puppet_velocity = Vector3.ZERO
var puppet_rotation = Vector2.ZERO

func _ready():
	# Global.connect("change_health", self, "change_health")
	rng.randomize()

	# changes skin color
	#$Pivot.add_child(blue_standard if team=="blue" else red_standard)
	Global.connect("start_sentry", self, "_start_timer")

func _start_timer():
	$NetworkTickRate.start()

func _physics_process(delta):
	if dead: # power down animation
		if $Spatial/Pivot.rotation_degrees.x > -30:
			head_acc -= deg2rad(35)*delta
			$Spatial/Pivot.rotation.x += head_acc
		return
	# We create a local variable to store the input direction.
	var body_dir = Vector3.ZERO

	var random_number = rng.randf_range(-10.0, 10.0)	
	# randomly change offset
	if random_number<1 and random_number>-1:
		offset = random_number*speed#Vector2(random_number, random_number).dot(Vector2.RIGHT)
	if offset+current_offset>rail_len/2 or offset+current_offset<(-rail_len+24)/2:
		offset = -offset

	if offset > 0:
		body_dir.x += offset
		body_dir.z -= offset
	else:
		body_dir.x += offset
		body_dir.z -= offset
	current_offset += offset
	
	auto_aim()
	if !fire_cooldown and shoot:
		var b = bullet.instance() # making an object b (kinda like Bullet b = new Bullet)
		$Spatial/Pivot/Barrel/Spatial.add_child(b) # spawning bullet to head
		rpc_unreliable("fired")
		b.shoot = true # lets bullet move
		$FireCooldown.start()
		fire_cooldown = true
	# Ground velocity
	velocity.x = body_dir.x
	velocity.z = body_dir.z
	if !$Tween.is_active():
		# Moving the character	
		velocity = move_and_slide(velocity, Vector3.UP)

func _on_FireCooldown_timeout():
	fire_cooldown = false

#aim bot code
func auto_aim():
	var closest = 100#FIXME
	var closest_point
	shoot = false
	for player in Global.player_pos:
		#to stop friendly fire
		if Network.player_list.has(player) and Network.player_list[player].team == team:#FIXME handle players leaving
			continue
		var plates = Global.player_pos[player]
		for cords in plates:
			$RayCast.look_at(cords, Vector3.UP) # TODO make it so it does not snap to the opponate
			$RayCast.force_raycast_update() # raycasts get up dated every _physics_prosses()
			# checking if the sentry can see the player
			var obj_hit = $RayCast.get_collider()	
			if obj_hit !=null and "KinematicBody".is_subsequence_of(obj_hit.to_string()):
				var distance = $RayCast.global_translation.distance_to(cords)#$RayCast.get_collision_point())#$Spatial/Pivot.transform.origin.distance_to(cords)S
				if distance < closest:
					closest = distance
					closest_point = cords
	if closest_point!=null:
		$Spatial/Pivot.look_at(closest_point, Vector3.UP)
		shoot = true


func _on_PanelHitbox_body_entered(body):
	#TODO check if bullet is moving fast enough
	if body.is_in_group("bullet"):# iff a bullet hits yourself
		if !dead:#if you get hit
			print(team, " Sentry is taking dmg")
			health -= 10
			if health == 0:
				print("dead")
				dead = true
				rpc_unreliable("killed_server")
			rpc_unreliable("hit_panel_server", team, health) #tell other senttry
			Global.emit_signal("change_health", team+"_sentry", health) #tell master player ui sentry got hit


"""
master func change_health(player_id, current_health):
	#STEP 3
	#after returning from global
	print("changing health for ",Network.player_list[player_id].name)
	UI.change_enemy_health(player_id, current_health)

"""

"""
puppet func overheat():
	print(Network.player_list[get_tree().get_rpc_sender_id()]," overheated")

puppet func killed_player():
	print(Network.player_list[get_tree().get_rpc_sender_id()].name," was killed")

puppet func revived():
	var player_id = get_tree().get_rpc_sender_id()
	print(Network.player_list[player_id].name," revived")
	health = 100
	Global.emit_signal("change_enemy_health", player_id, health)

"""

func _on_NetworkTickRate_timeout():
	rpc_unreliable("update_state", global_transform.origin, velocity, Vector2($Spatial/Pivot.rotation.x, $Spatial/Pivot.rotation.y))

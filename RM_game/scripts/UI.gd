extends Node2D

var id_to_player = {}
var mouse_sensitivity = 0.2 setget set_mouse_sens, get_mouse_sens
var paused = false

func _ready():
	$SettingsPanel/MouseSensText.text = String(mouse_sensitivity)
	$SettingsPanel/MouseSensSlider.value = mouse_sensitivity

	$Bars/enemyBar2.hide()
	var enemy1_taken:bool = false
	for id in Network.player_list.keys():
		var p = Network.player_list[id]
		var personal_id = get_tree().get_network_unique_id()
		#skip yourself
		if id == personal_id:
			pass
		#same team
		elif p.team == Network.player_list[personal_id].team:
			id_to_player[id] = $Bars/teamateBar
		#diffrent team
		elif !enemy1_taken:
			id_to_player[id] = $Bars/enemyBar
			enemy1_taken = true
		else:
			id_to_player[id] = $Bars/enemyBar2
	if len(id_to_player) >= 2:#FIXME
		$Bars/enemyBar2.show()

func change_health(health):
	$Bars/HealthBar.value = health
	$Bars/HealthBar/Health.text = str(health)+"/600"

func set_heat(heat_value):
	#TODO add white
	if heat_value >= 80:
		$overheat.show()
		$overheat.modulate.a8 = pow(2,heat_value/9)
	else:
		$overheat.hide()
		
	if heat_value>=75:
		$Bars/HeatWhite.hide()
		$Bars/HeatRed.show()
		$Bars/HeatRed.value = heat_value
	elif 65 < heat_value and heat_value < 75:
		$Bars/HeatWhite.show()
		$Bars/HeatRed.hide()
		$Bars/HeatWhite.value = heat_value
	else:
		$Bars/HeatWhite.value = heat_value

func change_enemy_health(id, health):
	id_to_player[id].value = health

func change_sentry(team, health):
	if team=="blue_sentry":
		$Bars/BlueSentryBar.value = health
		$Bars/BlueSentryBar/BlueSentry.text = str(health)
	else:
		$Bars/RedSentryBar.value = health
		$Bars/RedSentryBar/RedSentry.text = str(health)

func change_base(team, health):
	if team=="blue_base":#FIXME
		$Bars/BlueBaseHealth.value = health
		$Bars/BlueBaseHealth/Label.text = str(health)
	else:
		$Bars/RedBaseHealth.value = health
		$Bars/RedBaseHealth/Label.text = str(health)

func toggle_tips():
	if ($TipsPanel.visible):
		$TipsPanel.hide();
	else:
		$TipsPanel.show();

func toggle_settings():
	if ($SettingsPanel.visible):
		paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$SettingsPanel.hide()
	else:
		paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$SettingsPanel.show();

func set_mouse_sens(sensitivity):
	mouse_sensitivity = sensitivity;
	$SettingsPanel/MouseSensText.text = sensitivity;
	$SettingsPanel/MouseSensSlider.value = sensitivity;

func get_mouse_sens():
	return mouse_sensitivity;

func _on_MouseSensSlider_value_changed(value):
	print("Sensitivity changed to " + String(value))
	mouse_sensitivity = value;
	$SettingsPanel/MouseSensText.text = String(mouse_sensitivity)

func _on_MouseSensText_text_entered(new_text):
	if (new_text.is_float):
		mouse_sensitivity = new_text.to_float()
		$SettingsPanel/MouseSensSlider.value = mouse_sensitivity
	else:
		$SettingsPanel/MouseSensText.text = String(mouse_sensitivity)

func toggle_buy_screen(show):
	if ($BuyScreen.visible):
		paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$BuyScreen.hide()
	elif(show):
		print("buy screen")
		paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$BuyScreen.show();

func _on_Buy50_pressed():
	Global.emit_signal("add_bullets", 50)
	_on_Exit_pressed()

func _on_Buy100_pressed():
	Global.emit_signal("add_bullets", 100)
	_on_Exit_pressed()

func _on_Buy150_pressed():
	Global.emit_signal("add_bullets", 150)
	_on_Exit_pressed()

func _on_Buy200_pressed():
	Global.emit_signal("add_bullets", 200)
	_on_Exit_pressed()

func _on_Exit_pressed():
	if ($BuyScreen.visible):
		paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$BuyScreen.hide()

func change_bullet_display(num):
	$AmmoCount.text = str(num)

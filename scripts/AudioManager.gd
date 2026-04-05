extends Node

# Audio channels
var music_player: AudioStreamPlayer
var sfx_players: Array = []
var max_sfx_players: int = 8

# Volume settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 1.0

# Sound categories
enum SoundType {
	WEAPON_FIRE,
	WEAPON_RELOAD,
	FOOTSTEP,
	EXPLOSION,
	WRAITH_GROWL,
	WRAITH_DEATH,
	PLAYER_HURT,
	PLAYER_DEATH,
	ZONE_WARNING,
	ABILITY_ACTIVATE,
	ITEM_PICKUP,
	UI_CLICK
}

var sound_paths = {
	SoundType.WEAPON_FIRE: "res://assets/sounds/weapon_fire.ogg",
	SoundType.WEAPON_RELOAD: "res://assets/sounds/weapon_reload.ogg",
	SoundType.FOOTSTEP: "res://assets/sounds/footstep.ogg",
	SoundType.EXPLOSION: "res://assets/sounds/explosion.ogg",
	SoundType.WRAITH_GROWL: "res://assets/sounds/wraith_growl.ogg",
	SoundType.WRAITH_DEATH: "res://assets/sounds/wraith_death.ogg",
	SoundType.PLAYER_HURT: "res://assets/sounds/player_hurt.ogg",
	SoundType.PLAYER_DEATH: "res://assets/sounds/player_death.ogg",
	SoundType.ZONE_WARNING: "res://assets/sounds/zone_warning.ogg",
	SoundType.ABILITY_ACTIVATE: "res://assets/sounds/ability_activate.ogg",
	SoundType.ITEM_PICKUP: "res://assets/sounds/item_pickup.ogg",
	SoundType.UI_CLICK: "res://assets/sounds/ui_click.ogg"
}

func _ready():
	print("Audio Manager ready!")
	setup_sfx_players()

func setup_sfx_players():
	for i in range(max_sfx_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

func play_sound(sound_type: SoundType, volume_scale: float = 1.0):
	var player = get_available_sfx_player()
	if not player:
		return
	var path = sound_paths.get(sound_type, "")
	if path == "":
		return
	if ResourceLoader.exists(path):
		player.stream = load(path)
		player.volume_db = linear_to_db(sfx_volume * master_volume * volume_scale)
		player.play()
	else:
		print("Sound not found: ", path)

func play_music(path: String, loop: bool = true):
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
	if ResourceLoader.exists(path):
		music_player.stream = load(path)
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		music_player.play()
	else:
		print("Music not found: ", path)

func stop_music():
	if music_player:
		music_player.stop()

func get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)

func play_footstep():
	play_sound(SoundType.FOOTSTEP, 0.5)

func play_weapon_fire():
	play_sound(SoundType.WEAPON_FIRE)

func play_weapon_reload():
	play_sound(SoundType.WEAPON_RELOAD)

func play_explosion():
	play_sound(SoundType.EXPLOSION)

func play_zone_warning():
	play_sound(SoundType.ZONE_WARNING)

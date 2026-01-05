extends Control

# Die Geschwindigkeit des Scrollens (Pixel pro Sekunde)
@export var scroll_speed: float = 50.0

# Der Text-Node, der bewegt werden soll
@onready var credits_text: RichTextLabel = $Creditstext

# Optional: Ein Button zum Überspringen
# @onready var skip_button: Button = $SkipButton

const main_credits =  """
[b][font_size=64]Battle for Bachelor[/font_size][/b]

[font_size=32]Ein Projekt der Hochschule Düsseldorf[/font_size]

[i]Unter der Leitung von:[/i]
Prof. Dennis Müller
Christopher Antes

[b]--- Entwickler ---[/b]
Dennis Strutmann
Sebastian Rindfleisch
Sebastian Wendland
Jonas Holzem
David Otten

[b]--- Assets & Tools ---[/b]
Godot Engine 4.5
"""


const music_credits = """
[b][font_size=40]Music[/font_size][/b]

[b]Hubworld Theme[/b]
Generated with Suno AI
[url]https://suno.com[/url]

[b]Main Menu Theme[/b]
Generated with 8BitComposer
[url]https://www.8bitcomposer.com/[/url]


[b][font_size=40]Sound Effects[/font_size][/b]

[b]Environment & Objects[/b]

"Chair on the floor" (slide-char-back-and-forth)
by [i]MaslovyTygr[/i]
[color=#888888]License: Attribution 4.0[/color]

"DoorHandle"
by [i]EvaMusik[/i]
[color=#888888]License: CC0[/color]

"Locked Door"
by [i]-+Fugu+-[/i]
[color=#888888]License: CC0[/color]

"Classroom Ambience"
by [i]janica_uys241180[/i]
[color=#888888]License: Attribution NonCommercial 4.0[/color]

"Alarm clock beep close perspective"
by [i]SpliceSound[/i]
[color=#888888]License: CC0[/color]


[b]Character & Action[/b]

"Yawning Man"
by [i]husky70[/i]
[color=#888888]License: CC0[/color]

"Coin Pickup Sound V 0.2"
by [i]Davidsraba[/i]
[color=#888888]License: CC0[/color]

"Woosh - MediumBlast" (Dash)
by [i]jwsounddesign[/i]
[color=#888888]License: Attribution 4.0[/color]

"Punch 8" (Hit)
by [i]CastIronCarousel[/i]
[color=#888888]License: Attribution 3.0[/color]

"SNES Jump - Tinyfarts"
by [i]JelloApocalypse[/i]
[color=#888888]License: CC0[/color]

"Punch"
by [i]theredshore[/i]
[color=#888888]License: CC0[/color]

"SFX Lo-Fi Shoot"
by [i]bolkmar[/i]
[color=#888888]License: Attribution 4.0[/color]

"Kenny Assets"


[b]Enemies (Bugs & Ducks)[/b]

"Bug Sounds" (bug1, 2)
by [i]Vegemyte[/i]
[color=#888888]License: CC0[/color]

"Katydid or Cricket on street" (Dash)
by [i]standing_water[/i]
[color=#888888]License: CC0[/color]

"Smashed Bug"
by [i]Gcastanera[/i]
[color=#888888]License: CC0[/color]

"Bug 04" (Hurt)
by [i]sandyrb[/i]
[color=#888888]License: Attribution 4.0[/color]

"Bug's steps"
by [i]Hawkeye_Sprout[/i]
[color=#888888]License: Attribution 4.0[/color]

"Duck Quack" (Death)
by [i]gibarroule[/i]
[color=#888888]License: CC0[/color]

"Breaking Eggs" (Hit)
by [i]Ultra-Edward[/i]
[color=#888888]License: CC0[/color]

"Duck Flapping Wings"
by [i]OwennewO[/i]
[color=#888888]License: CC0[/color]

"Duck Quacking Quietly"
by [i]OwennewO[/i]
[color=#888888]License: CC0[/color]

"Plop" (Shoot Egg)
by [i]edschaefer[/i]
[color=#888888]License: CC0[/color]

"Wet Footsteps" (Duck Walk)
by [i]sqeeeek[/i]
[color=#888888]License: CC0[/color]
"""

const full_credits = "[center]" + main_credits + music_credits + "[/center]"

# Flag, um zu wissen, wann wir fertig sind
var scrolling_finished: bool = false

func _ready() -> void:
	# 1. Text setzen (falls nicht im Editor gemacht)
	credits_text.text = full_credits
	
	# 2. Startposition setzen:
	# Wir setzen den Text genau unterhalb des Bildschirms
	var screen_height = get_viewport_rect().size.y
	credits_text.position.y = screen_height
	
	# Optional: Musik starten (falls gewünscht)
	# MusicManager.playMusic(MusicManager.MusicType.CREDITS) # Falls du das Enum hast

func _process(delta: float) -> void:
	if scrolling_finished:
		return
		
	# 1. Bewegung nach oben (y wird kleiner)
	credits_text.position.y -= scroll_speed * delta
	
	# 2. Prüfen, ob der Text komplett aus dem Bild ist
	# Wir brauchen die untere Kante des Textes.
	# credits_text.size.y gibt die Höhe des Textblocks an.
	var text_bottom = credits_text.position.y + credits_text.size.y
	
	# Wenn die untere Kante oben den Bildschirm (y=0) verlassen hat...
	if text_bottom < 0:
		finish_credits()

func _input(event: InputEvent) -> void:
	# Optional: Credits beschleunigen bei Tastendruck
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		scroll_speed *= 4.0 # Turbo-Modus
	elif event.is_action_released("ui_accept") or event.is_action_released("interact"):
		scroll_speed /= 4.0

func finish_credits() -> void:
	if scrolling_finished: return
	scrolling_finished = true
	
	print("Credits beendet.")
	
	# Zurück zum Hauptmenü
	# Falls SaveManager deine Szenen verwaltet:
	# SaveManager.load_last_scene() # Eher nicht, Credits sind ja oft das Ende
	
	# Besser: Hart zurück zum Menü
	get_tree().change_scene_to_file("res://src/shared/ui/MainMenu.tscn")

# Falls du einen Skip-Button hast
func _on_skip_button_pressed() -> void:
	finish_credits()

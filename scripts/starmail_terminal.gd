extends StaticBody3D

@onready var mail_list := $Screen/Viewport/Control/ScrollContainer/MailList
@onready var msg_count_label := $Screen/Viewport/Control/TitleContainer/MessageCount
@onready var audio_player := $SFXPlayer

@onready var base = get_node("/root/base")

var blackscreen: StandardMaterial3D
var defaultscreen: StandardMaterial3D

func _ready() -> void:
	print()
	start_sending_random_mails()
	defaultscreen = $Screen.mesh.material

	blackscreen = StandardMaterial3D.new()
	blackscreen.albedo_color = Color(0, 0, 0, 1)
	blackscreen.roughness = defaultscreen.roughness
	
	base.PowerOff.connect(_PowerOff)
	base.PowerOn.connect(_PowerOn)

func _PowerOff():
	$Screen.mesh.material = blackscreen

func _PowerOn():
	$Screen.mesh.material = defaultscreen

var senders: Array[String] = [
	"Gordon Freeman",
	"Anonymous User",
	"Dr. Wallace Breen",
	"Dr. Isaac Kleiner",
	"Barney Calhoun"
]

var subjects: Array[String] = [
	"Look behind you.",
	"...",
	"Hello! I am using Starmail Messenger!",
	"Don't drink the water. They put something in it... to make you forget... I don't even remember how i got here.",
	"do you know what these weird glowing pillars are?"
]

var mails: Array[Dictionary] = []

var sound_incoming_mail := preload("res://assets/sound/sfx/ui/email.wav")

func new_mail(sender: String, subject: String, time: String) -> VBoxContainer:
	var container = VBoxContainer.new()

	var title = HBoxContainer.new()
	var sender_label = Label.new()
	sender_label.text = sender
	sender_label.custom_minimum_size = Vector2(100, 0)
	sender_label.modulate = Color(0.8, 0.9, 1)
	
	var time_label = Label.new()
	time_label.text = " - " + time
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT 
	time_label.custom_minimum_size = Vector2(60, 0)
	time_label.modulate = Color(0.6, 0.6, 0.6)
	
	title.add_child(sender_label)
	title.add_child(time_label)

	var subject_label = Label.new()
	subject_label.text = subject


	container.add_child(title)
	container.add_child(subject_label)
	
	var data = {
		"sender": sender,
		"subject": subject,
		"time": time
	}
	
	mails.append(data)
	
	msg_count_label.text = "  -  " + str(mails.size()) + " messages"

	return container

func send_mail(sender: String, subject: String, time: String):
	var email = new_mail(sender, subject, time)
	mail_list.add_child(email)
	audio_player.play_stream(sound_incoming_mail, 0.0, 0.0, 1.0)

func send_random_mail():
	var sender = senders[randi_range(0, senders.size() - 1)]
	var subject = subjects[randi_range(0, subjects.size() - 1)]
	var time = "12:00"
	send_mail(sender, subject, time)

func start_sending_random_mails():
	while true:
		await get_tree().create_timer(randi_range(10, 20)).timeout
		if randi_range(1, 10) == 1:
			send_random_mail()

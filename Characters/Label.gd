extends Label

var lines = [
	"I'LL EAT YA",
	"GET OVER HERE",
	"MMM, DINNER",
]

func _ready():
	text = lines[randi() % lines.size()]

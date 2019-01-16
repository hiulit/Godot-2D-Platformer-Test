extends CanvasModulate

export(int) var day_duration = 1 # In minutes
export var color_dawn = Color(0.86, 0.70, 0.70, 1)
export var color_day = Color(1, 1, 1, 1)
export var color_dusk = Color(0.59, 0.66, 0.78, 1)
export var color_night = Color(0.07, 0.09, 0.38, 1)

var tick = 0
var length_day = 0
var hour = 0
var number_day = 0

enum { NIGHT, DAWN, DAY, DUSK }
var cycle = DAWN

func _ready():
	length_day = 60 * 60 * day_duration # In seconds
	
	tick = length_day / 3 # Start at 8h

	color = color_dawn

func _physics_process(delta):
	tick += 1
	day_cycle()


func day_cycle():
	hour = tick / (length_day / 24)
	
	if tick > length_day:
		tick = 0
		number_day += 1
	
	if hour >= 18 or hour <= 5:
		cycle_test(NIGHT)
	
	if hour >= 5 and hour <= 8:
		cycle_test(DAWN)
	
	if hour >= 8 and hour <= 16:
		cycle_test(DAY)
	
	if hour >= 16 and hour <= 18:
		cycle_test(DUSK)


	print(str(tick) + " - " + str(hour) + " - " + str(cycle))


func cycle_test(new_cycle):
	if cycle != new_cycle:
		cycle = new_cycle

		if cycle == NIGHT:
			$Tween.interpolate_property(self, "color", color_dusk, color_night, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
#			yield($Tween, "tween_completed")
			
		if cycle == DAWN:
			$Tween.interpolate_property(self, "color", color_night, color_dawn, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
	
		if cycle == DAY:
			$Tween.interpolate_property(self, "color", color_dawn, color_day, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
	
		if cycle == DUSK:
			$Tween.interpolate_property(self, "color", color_day, color_dusk, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()

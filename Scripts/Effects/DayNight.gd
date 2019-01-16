extends CanvasModulate

var day_duration = 0.5 # In minutes
var start_hour = 4 # 24 hours time (0-23)
var color_dawn = Color(0.86, 0.70, 0.70, 1)
var color_day = Color(1, 1, 1, 1)
var color_dusk = Color(0.59, 0.66, 0.78, 1)
var color_night = Color(0.07, 0.09, 0.38, 1)

var tick = 0
var day_length = 0
var current_hour = 0
var day_number = 1
var transition_duration

enum { NIGHT, DAWN, DAY, DUSK }
var cycle

func _ready():
	day_length = 60 * 60 * day_duration # Hours in seconds
	
	tick = (day_length / 24) * start_hour
	
	current_hour = tick / (day_length / 24)
	
	if current_hour >= 18 or current_hour <= 5:
		cycle = NIGHT
		color = color_night
	elif current_hour >= 5 and current_hour <= 8:
		cycle = DAWN
		color = color_dawn
	elif current_hour >= 8 and current_hour <= 16:
		cycle = DAY
		color = color_day
	elif current_hour >= 16 and current_hour <= 18:
		cycle = DUSK
		color = color_dusk
		
	transition_duration = (((day_length / 24) * 1) / 60)

func _physics_process(delta):
	day_cycle()
	tick += 1


func day_cycle():
	current_hour = tick / (day_length / 24)
	
	if tick > day_length:
		tick = 0
		day_number += 1
		
	if current_hour >= 19 or current_hour <= 5:
		cycle_test(NIGHT)
	elif current_hour >= 5 and current_hour <= 8:
		cycle_test(DAWN)
	elif current_hour >= 8 and current_hour <= 16:
		cycle_test(DAY)
	elif current_hour >= 16 and current_hour <= 19:
		cycle_test(DUSK)

#	print(str(tick) + " - " + str(current_hour) + " - " + str(cycle))


func cycle_test(new_cycle):
	if cycle != new_cycle:
		cycle = new_cycle

		if cycle == NIGHT:
			$Tween.interpolate_property(self, "color", color_dusk, color_night, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
			
		if cycle == DAWN:
			$Tween.interpolate_property(self, "color", color_night, color_dawn, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
	
		if cycle == DAY:
			$Tween.interpolate_property(self, "color", color_dawn, color_day, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
	
		if cycle == DUSK:
			$Tween.interpolate_property(self, "color", color_day, color_dusk, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()

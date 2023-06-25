extends ProgressBar

func _process(delta):
	max_value = gvars.maxTeleports
	value = gvars.currentTPs
	
	if max_value > 0:
		visible = true
	else:
		visible = false

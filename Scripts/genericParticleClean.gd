extends GPUParticles2D

@onready var expiryTimer = get_node("Timer")

func _ready():
	self.emitting = true
	self.one_shot = true
	expiryTimer.start(self.lifetime)
	await expiryTimer.timeout
	self.queue_free()

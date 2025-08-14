extends RigidBody2D


func _on_body_entered(body):
	# Ha a test, amivel ütköztünk, a "ground" csoportban van...
	if body.is_in_group("ground"):
		# ...írjuk ki a konzolra, hogy sikerült!
		print(">>> SIKERES ÜTKÖZÉS ÉRZÉKELVE A 'ground' CSOPORTTAL! <<<")

extends Node3D

func _ready():
    var cam = $Camera3D
    cam.position = Vector3(0, 10, 10)
    cam.rotation_degrees = Vector3(-45, 0, 0)
    cam.make_current()
    print("Camera set!")

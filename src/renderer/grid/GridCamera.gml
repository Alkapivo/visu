///@package com.alkapivo.visu.component.grid.renderer.GridCamera

///@param {Struct} [config]
function GridCamera(config = {}) constructor {
    
	///@type {Number}
	x = Assert.isType(Struct.getDefault(config, "x", 4096), Number)

  ///@type {Number}
	y = Assert.isType(Struct.getDefault(config, "y", 5356), Number)

  ///@type {Number}
	z = Assert.isType(Struct.getDefault(config, "z", 0), Number)

  ///@type {Number}
	zoom = Assert.isType(Struct.getDefault(config, "zoom", 5000), Number)

  ///@type {Number}
	angle = Assert.isType(Struct.getDefault(config, "angle", 270), Number)

    ///@type {Number}
	pitch = Assert.isType(Struct.getDefault(config, "pitch", -70), Number)

  ///@type {?Matrix}
  viewMatrix = null

	///@type {?Matrix}
	projectionMatrix = null

	///@type {Boolean}
	enableMouseLook = Struct.getDefault(config, "enableMouseLook", false)

	///@type {Number}
	moveSpeed = Assert.isType(Struct.getDefault(config, "moveSpeed", 16), Number)

	///@type {GMCamera}
	gmCamera = camera_create()

	executor = new TaskExecutor(this)

	///@return {Camera}
	update = function() {
		this.executor.update()
		this.enableMouseLook = keyboard_check_pressed(vk_f5)
			? !this.enableMouseLook 
			: this.enableMouseLook
			
		if (!this.enableMouseLook) {
			return this
		}

		this.angle -= (window_mouse_get_x() - GuiWidth() / 2) / 10
		this.pitch -= (window_mouse_get_y() - GuiHeight() / 2) / 10
		this.pitch = clamp(this.pitch, -85, 85)
		window_mouse_set(GuiWidth() / 2, GuiHeight() / 2)

		var dx = 0
		var dy = 0
		var dz = 0
		if (keyboard_check(ord("A"))) {
				dx += dsin(this.angle) * moveSpeed
				dy += dcos(this.angle) * moveSpeed
		}

		if (keyboard_check(ord("D"))) {
				dx -= dsin(this.angle) * moveSpeed
				dy -= dcos(this.angle) * moveSpeed
		}

		if (keyboard_check(ord("W"))) {
				dx -= dcos(this.angle) * moveSpeed
				dy += dsin(this.angle) * moveSpeed
		}

		if (keyboard_check(ord("S"))) {
				dx += dcos(this.angle) * moveSpeed
				dy -= dsin(this.angle) * moveSpeed
		}

		if (mouse_wheel_up()) {
				dz += moveSpeed * 10
		}

		if (mouse_wheel_down()) {
				dz -= moveSpeed * 10
		}
		this.x += dx
		this.y += dy
		this.z += dz

		return this
	}
}

///@package com.alkapivo.visu.service.grid.GridRenderer


///@param {Controller} _controller
///@param {Struct} [config]
function GridRenderer(_controller, config = {}) constructor {

  ///@todo move from GridRenderer
  application_surface_draw_enable(false)
  gpu_set_ztestenable(false)
	gpu_set_zwriteenable(false)
	gpu_set_cullmode(cull_counterclockwise)

  ///@type {Controller}
  controller = Assert.isType(_controller, Struct)

  ///@type {GridOverlayRenderer}
  overlayRenderer = new GridOverlayRenderer(this)

  ///@type {Surface}
  gameSurface = new Surface({ width: GuiWidth(), height: GuiHeight() })

  ///@type {Surface}
  backgroundSurface = new Surface({ width: GuiWidth(), height: GuiHeight() })

  ///@type {Surface}
  gridSurface = new Surface({ width: GuiWidth(), height: GuiHeight() })

  ///@type {Surface}
  shaderSurface = new Surface({ width: GuiWidth(), height: GuiHeight() })

  ///@type {GridCamera}
  camera = new GridCamera()
  
  ///@type {GMVertexBuffer}
  vertexBuffer = new DefaultVertexBuffer(new Array(DefaultVertex, [
	  new DefaultVertex(0, 0, 0, 0, 0, 1, 0, 0, ColorUtil.WHITE, 1),
    new DefaultVertex(GRID_SERVICE_PIXEL_WIDTH, 0, 0,  0, 0, 1, 1, 0, ColorUtil.WHITE, 1),
    new DefaultVertex(GRID_SERVICE_PIXEL_WIDTH, GRID_SERVICE_PIXEL_HEIGHT, 0, 0, 0, 1, 1, 1, ColorUtil.WHITE, 1),
    new DefaultVertex(GRID_SERVICE_PIXEL_WIDTH, GRID_SERVICE_PIXEL_HEIGHT, 0, 0, 0, 1, 1, 1, ColorUtil.WHITE, 1),
    new DefaultVertex(0, GRID_SERVICE_PIXEL_HEIGHT, 0, 0, 0, 1, 0, 1, ColorUtil.WHITE, 1),
    new DefaultVertex(0, 0, 0, 0, 0, 1, 0, 0, ColorUtil.WHITE, 1)
  ])).build().buffer

  ///@type {BKTGlitch}
  bktGlitchService = new BKTGlitchService()

  ///@private
  ///@type {Timer}
  ///@description Z demo
  playerZTimer = new Timer(pi * 2, { loop: Infinity }) 

  ///@private
  ///@return {GridRenderer}
  renderSeparators = function() {
    var gridService = this.controller.gridService
    var properties = gridService.properties
    var view = gridService.view
    if (!properties.renderGrid) || (properties.separators <= 0) {
      return this
    }

    var separators = properties.separators
    var primaryColor = properties.separatorsPrimaryColor.toGMColor()
    var primaryAlpha = properties.separatorsPrimaryAlpha
    var primaryThickness = properties.separatorsPrimaryThickness
    var secondaryColor = properties.separatorsSecondaryColor.toGMColor()
    var secondaryAlpha = properties.separatorsSecondaryAlpha
    var secondaryThickness = gridService.properties.separatorsSecondaryThickness
    var separatorHeight = (view.height * 2) / separators
    var time = gridService.properties.separatorTimer.time
    var offset = 2.0
    var separatorsSize = separators * 3
    for (var index = 0; index <= floor(separatorsSize); index++) {
      var beginX = -5.0 * GRID_SERVICE_PIXEL_WIDTH
      var beginY = ((-5 * view.height) + (index * separatorHeight) + offset + time) 
        * GRID_SERVICE_PIXEL_HEIGHT
      var endX = 5.0 * GRID_SERVICE_PIXEL_WIDTH
      var endY = beginY
      if (index < separators || index > 0) {
        GPU.render.texturedLine(beginX, beginY, endX, endY, secondaryThickness, secondaryAlpha, secondaryColor)
      } else {
        GPU.render.texturedLine(beginX, beginY, endX, endY, primaryThickness, primaryAlpha, primaryColor)
      }
    }

    return this
  }

  ///@private
  ///@return {GridRenderer}
  renderChannels = function() {
    static renderPrimaryChannels = function(viewXOffset, amount, thickness, color, alpha) {
      var gridService = this.controller.gridService
      var channelWidth = gridService.view.width / gridService.properties.channels
      for (var index = 0; index <= amount; index++) {
        var beginX = (viewXOffset + (index * channelWidth)) * GRID_SERVICE_PIXEL_WIDTH
        var beginY = -5.0 * GRID_SERVICE_PIXEL_HEIGHT
        var endX = beginX
        var endY = (gridService.view.height + 5.0) * GRID_SERVICE_PIXEL_HEIGHT
        GPU.render.texturedLine(beginX, beginY, endX, endY, thickness, alpha, color)
      }
    }

    static renderRightChannels = function(viewXOffset, amount, thickness, color, alpha) {
      var gridService = this.controller.gridService
      var channelWidth = gridService.view.width / gridService.properties.channels
      for (var index = 1; index <= amount; index++) {
        var beginX = (viewXOffset + (index * channelWidth)) * GRID_SERVICE_PIXEL_WIDTH
        var beginY = -5.0 * GRID_SERVICE_PIXEL_HEIGHT
        var endX = beginX
        var endY = (gridService.view.height + 5.0) * GRID_SERVICE_PIXEL_HEIGHT
        GPU.render.texturedLine(beginX, beginY, endX, endY, thickness, alpha, color)
      }
    }

    static renderLeftChannels = function(viewXOffset, amount, thickness, color, alpha) {
      var gridService = this.controller.gridService
      var channelWidth = gridService.view.width / gridService.properties.channels
      for (var index = 0; index <= amount; index++) {
        var beginX = (viewXOffset + (index * channelWidth)) * GRID_SERVICE_PIXEL_WIDTH
        var beginY = -5.0 * GRID_SERVICE_PIXEL_HEIGHT
        var endX = beginX
        var endY = (gridService.view.height + 5.0) * GRID_SERVICE_PIXEL_HEIGHT
        GPU.render.texturedLine(beginX, beginY, endX, endY, thickness, alpha, color)
      }
    }

    var gridService = this.controller.gridService
    var properties = gridService.properties
    if (!gridService.properties.renderGrid || properties.channels <= 0) {
      return this
    }

    var view = gridService.view
    var primaryColor = properties.channelsPrimaryColor.toGMColor()
    var primaryAlpha = properties.channelsPrimaryAlpha
    var primaryThickness = properties.channelsPrimaryThickness
    var secondaryColor = properties.channelsSecondaryColor.toGMColor()
    var secondaryAlpha = properties.channelsSecondaryAlpha
    var secondaryThickness = properties.channelsSecondaryThickness
    var channels = properties.channels
    var channelWidth = view.width / channels
    var viewXOffset = channelWidth * (floor(view.x / view.width) - view.x)

    renderLeftChannels(
      viewXOffset - ((view.width + ((ceil(channels) - channels) * channelWidth)) * 2.0),
      ceil(channels * 2.0),
      secondaryThickness, 
      secondaryColor, 
      secondaryAlpha
    )

    renderRightChannels(
      viewXOffset + view.width + ((ceil(channels) - channels) * channelWidth),
      ceil(channels * 2.0),
      secondaryThickness, 
      secondaryColor, 
      secondaryAlpha
    )

    renderPrimaryChannels(
      viewXOffset, 
      ceil(channels),
      primaryThickness,
      primaryColor,
      primaryAlpha
    )

    return this
  }

  ///@private
  renderBorders = function() {
    var gridService = this.controller.gridService
    var view = gridService.view

    // bottom
    var beginX = -5.0 * GRID_SERVICE_PIXEL_WIDTH
    var beginY = (gridService.height - view.y) * GRID_SERVICE_PIXEL_HEIGHT
    var endX = (5.0 + view.width) * GRID_SERVICE_PIXEL_WIDTH
    var endY = beginY
    var thickness = 64
    var alpha = 1.0
    var color = c_red
    GPU.render.texturedLine(beginX, beginY, endX, endY, thickness, alpha, color)
  }

  ///@private
  ///@return {GridRenderer}
  renderPlayer = function() { 
    var player = this.controller.playerService.player
    if (!this.controller.gridService.properties.renderElements
      || !Core.isType(player, Player)) {
      return this
    }

    var gridService = this.controller.gridService
    var useBlendAsZ = false
    if (useBlendAsZ) {
      shader_set(shader_gml_use_blend_as_z)
      shader_set_uniform_f(shader_get_uniform(shader_gml_use_blend_as_z, "size"), 1024.0)
      player.sprite.blend = (sin(this.playerZTimer.update().time) * 0.5 + 0.5) * 255     
      player.sprite.render(
        (player.x - (player.sprite.texture.width / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y - (player.sprite.texture.height / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT
      )
      /*
      GPU.render.rectangle(
        (player.x - ((player.mask.getWidth() * player.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y - ((player.mask.getHeight() * player.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        (player.x + ((player.mask.getWidth() * player.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y + ((player.mask.getHeight() * player.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        false, 
        c_lime
      )
      */
      shader_reset()
    } else {
      player.sprite.render(
        (player.x - ((player.sprite.texture.width * player.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y - ((player.sprite.texture.height * player.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT
      )

      /*
      GPU.render.rectangle(
        (player.x - ((player.mask.getWidth() * player.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y - ((player.mask.getHeight() * player.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        (player.x + ((player.mask.getWidth() * player.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (player.y + ((player.mask.getHeight() * player.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        false, 
        c_lime
      )
      */
    }
    
    return this
  }

  ///@private
  ///@return {GridRenderer}
  renderShrooms = function() {
    static renderShroom = function(shroom, index, gridService) {
      shroom.sprite.render(
        (shroom.x - ((shroom.sprite.texture.width * shroom.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (shroom.y - ((shroom.sprite.texture.height * shroom.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT
      )

      /*
      GPU.render.rectangle(
        (shroom.x - ((shroom.mask.getWidth() * shroom.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (shroom.y - ((shroom.mask.getHeight() * shroom.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        (shroom.x + ((shroom.mask.getWidth() * shroom.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (shroom.y + ((shroom.mask.getHeight() * shroom.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        false, 
        c_red
      )
      */
    }

    var gridService = this.controller.gridService
    if (!gridService.properties.renderElements 
      || !gridService.properties.renderShrooms) {
      return this
    }

    this.controller.shroomService.shrooms.forEach(renderShroom, gridService)

    // Render spawner
    var spawner = this.controller.shroomService.spawner
    if (Core.isType(spawner, Struct)) {
      spawner.sprite.render(
        (spawner.x * GRID_SERVICE_PIXEL_WIDTH) - ((spawner.sprite.getWidth() * spawner.sprite.getScaleX()) / 2.0), 
        (spawner.y * GRID_SERVICE_PIXEL_HEIGHT) - ((spawner.sprite.getHeight() * spawner.sprite.getScaleY()) / 2.0)
      )
      this.controller.shroomService.spawner = null
    }

    // Render particleArea
    var particleArea = this.controller.shroomService.particleArea
    if (Core.isType(particleArea, Struct)) {
      particleArea.topLeft.sprite.render(
        particleArea.topLeft.x * GRID_SERVICE_PIXEL_WIDTH,
        particleArea.topLeft.y * GRID_SERVICE_PIXEL_HEIGHT,
      )
      particleArea.topRight.sprite.render(
        particleArea.topRight.x * GRID_SERVICE_PIXEL_WIDTH,
        particleArea.topRight.y * GRID_SERVICE_PIXEL_HEIGHT,
      )
      particleArea.bottomLeft.sprite.render(
        particleArea.bottomLeft.x * GRID_SERVICE_PIXEL_WIDTH,
        particleArea.bottomLeft.y * GRID_SERVICE_PIXEL_HEIGHT,
      )
      particleArea.bottomRight.sprite.render(
        particleArea.bottomRight.x * GRID_SERVICE_PIXEL_WIDTH,
        particleArea.bottomRight.y * GRID_SERVICE_PIXEL_HEIGHT,
      )

      this.controller.shroomService.particleArea = null
    }

    return this
  }

  ///@private
  ///@return {GridRenderer}
  renderBullets = function() {
    static renderBullet = function(bullet, index, gridService) {
      bullet.sprite
        .setAngle(bullet.angle)
        .render(
          (bullet.x + ((bullet.sprite.texture.offsetX * bullet.sprite.scaleX) / GRID_SERVICE_PIXEL_WIDTH) - (bullet.sprite.texture.width / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
          (bullet.y + ((bullet.sprite.texture.offsetY * bullet.sprite.scaleY) / GRID_SERVICE_PIXEL_HEIGHT) - (bullet.sprite.texture.height / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT
        )

      /*
      GPU.render.rectangle(
        (bullet.x - ((bullet.mask.getWidth() * bullet.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (bullet.y - ((bullet.mask.getHeight() * bullet.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        (bullet.x + ((bullet.mask.getWidth() * bullet.sprite.scaleX) / (2.0 * GRID_SERVICE_PIXEL_WIDTH)) - gridService.view.x) * GRID_SERVICE_PIXEL_WIDTH,
        (bullet.y + ((bullet.mask.getHeight() * bullet.sprite.scaleY) / (2.0 * GRID_SERVICE_PIXEL_HEIGHT)) - gridService.view.y) * GRID_SERVICE_PIXEL_HEIGHT,
        false, 
        c_blue
      )
      */
    }
    
    var gridService = this.controller.gridService
    if (!gridService.properties.renderElements
        || !gridService.properties.renderBullets) {
      return this
    }

    this.controller.bulletService.bullets.forEach(renderBullet, gridService)
    return this
  }

  ///@private
  ///@return {GridRenderer}
  renderParticles = function() {
    if (!this.controller.gridService.properties.renderParticles) {
      return this
    }

    this.controller.particleService.systems.get("main").render()
    return this
  }

  ///@private
  ///@return {GridRenderer}
  renderBackground = function() {
    if (!this.controller.gridService.properties.renderBackground) {
      return this
    }

    this.backgroundSurface.render()
    var shaderPipeline = this.controller.shaderBackgroundPipeline
    if (this.controller.gridService.properties.renderBackgroundShaders 
      && shaderPipeline.executor.tasks.size() > 0) {

      shaderPipeline.render(function(task, index, renderer) {
        var properties = renderer.controller.gridService.properties
        var alpha = task.state.getDefault("alpha", 1.0)
        renderer.backgroundSurface.render(0, 0, alpha)
      }, this)
    }
  }

  ///@private
  ///@param {GridRenderer} renderer
  renderForeground = function() {
    if (!this.controller.gridService.properties.renderForeground) {
      return this
    }

    var width = this.backgroundSurface.width
    var height = this.backgroundSurface.height
    this.overlayRenderer.renderForegrounds(width, height)
    return this
  }
  
  ///@private
  ///@param {GridRenderer} renderer
  renderBackgroundSurface = function(renderer) {
    var properties = renderer.controller.gridService.properties
    var width = this.backgroundSurface.width
    var height = this.backgroundSurface.height
    GPU.render.clear(properties.backgroundColor)
    if (properties.renderVideo) {
      renderer.overlayRenderer.renderVideo(width, height) 
    }

    if (properties.renderBackground) {
      renderer.overlayRenderer.renderBackgrounds(width, height)
    }
  }

  ///@private
  ///@param {GridRenderer} renderer
  renderGridSurface = function(renderer) {
    var properties = renderer.controller.gridService.properties
    if (properties.gridClearFrame) {
      GPU.render.clear(properties.gridClearColor)
    }

    var depths = renderer.controller.gridService.properties.depths
      
    var cameraDistance = 160 ///@todo extract parameter
    var xto = renderer.camera.x
    var yto = renderer.camera.y
    var zto = renderer.camera.z + renderer.camera.zoom
    var xfrom = xto + cameraDistance * dcos(renderer.camera.angle) * dcos(renderer.camera.pitch)
    var yfrom = yto - cameraDistance * dsin(renderer.camera.angle) * dcos(renderer.camera.pitch)
    var zfrom = zto - cameraDistance * dsin(renderer.camera.pitch)
    renderer.camera.viewMatrix = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1)
    camera_set_view_mat(renderer.camera.gmCamera, renderer.camera.viewMatrix)
    renderer.camera.projectionMatrix = matrix_build_projection_perspective_fov(-60, -1 * renderer.gridSurface.width / renderer.gridSurface.height, 1, 32000) ///@todo extract parameters
    camera_set_proj_mat(renderer.camera.gmCamera, renderer.camera.projectionMatrix)
    camera_apply(renderer.camera.gmCamera)

    var baseX = GRID_SERVICE_PIXEL_WIDTH + GRID_SERVICE_PIXEL_WIDTH * 0.5
    var baseY = GRID_SERVICE_PIXEL_HEIGHT + GRID_SERVICE_PIXEL_HEIGHT * 0.5

    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.channelZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderChannels()
    renderer.renderBorders()
    
    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.separatorZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderSeparators()

    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.bulletZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderBullets()

    gpu_set_alphatestenable(true)
    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.shroomZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderShrooms()
    gpu_set_alphatestenable(false)

    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.particleZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderParticles()

    matrix_set(matrix_world, matrix_build(
      baseX, baseY, depths.playerZ, 
      0, 0, 0, 
      1, 1, 1
    ))
    renderer.renderPlayer()

    matrix_set(matrix_world, matrix_build_identity())
  }

  ///@private
  ///@param {GridRenderer} renderer
  renderShaderSurface = function(renderer) {
    var properties = renderer.controller.gridService.properties
    if (!properties.renderGridShaders) {
      return
    }

    if (properties.shaderClearFrame) {
      GPU.render.clear(properties.shaderClearColor)
    }

    var size = renderer.controller.shaderPipeline
      .render(function(task, index, renderer) {
        renderer.gridSurface.render(0, 0, task.state
          .getDefault("alpha", 1.0))
      }, renderer)
      .executor.tasks.size()

    // Render support-grid
    if (properties.renderSupportGrid 
      && size >= properties.renderSupportGridTreshold) {

      GPU.set.blendMode(BlendMode.ADD)
      renderer.gridSurface.render(0, 0, properties.renderSupportGridAlpha)
      GPU.reset.blendMode()
    }
  }

  ///@private
  ///@param {GridRenderer} renderer
  renderGameSurface = function(renderer) {
    GPU.render.clear(renderer.controller.gridService.properties.clearColor)
    renderer.renderBackground() 
    renderer.gridSurface.render()
    renderer.shaderSurface.render()
    renderer.renderForeground()
  }

  ///@return {GridRenderer}
  clear = function() {
    this.camera = new GridCamera()
    this.overlayRenderer.clear()
    return this
  }

  ///@return {GridRenderer}
  update = function() {
    this.camera.update()
    this.overlayRenderer.update()
    this.bktGlitchService.update(GuiWidth(), GuiHeight())
  }

  ///@return {GridRenderer}
  render = function(config) {
    var width = Struct.contains(config, "width") ? config.width : GuiWidth()
    var height = Struct.contains(config, "height") ? config.height : GuiHeight()
    this.backgroundSurface
      .update(width, height)
      .renderOn(this.renderBackgroundSurface, this)
    this.gridSurface
      .update(width, height)
      .renderOn(this.renderGridSurface, this)
    this.shaderSurface
      .update(width, height)
      .renderOn(renderShaderSurface, this)
    this.gameSurface
      .update(width, height)
      .renderOn(this.renderGameSurface, this)
    return this
  }

  renderBKTGlitch = function(config) {
    var width = Struct.contains(config, "width") ? config.width : GuiWidth()
    var height = Struct.contains(config, "height") ? config.height : GuiHeight()
    var _x = Struct.contains(config, "x") ? config.x : 0
    var _y = Struct.contains(config, "y") ? config.y : 0
    this.gameSurface.update(width, height).render(_x, _y)
  }

  ///@param {?Struct} [config]
  ///@return {GridRenderer}
  renderGUI = function(config = null) {
    this.bktGlitchService.renderOn(renderBKTGlitch, config)
    return this
  }

  ///@return {GridRenderer}
  free = function() {
    this.backgroundSurface.free()
    this.gridSurface.free()
    this.gameSurface.free()
    this.shaderSurface.free()
    return this
  }
}


///@package io.alkapivo.visu

///@enum
function _GameMode(): Enum() constructor {
  IDLE = "idle"
  BULLETHELL = "bulletHell"
  PLATFORMER = "platformer"
}
global.__GameMode = new _GameMode()
#macro GameMode global.__GameMode


#macro BeanVisuController "visuController"
///@param {String} layerName
function VisuController(layerName) constructor {

  ///@type {DisplayService}
  displayService = new DisplayService(this)

  ///@type {FileService}
  fileService = new FileService(this)

  ///@type {ShaderPipeline}
  shaderPipeline = new ShaderPipeline()

  ///@type {ShaderPipeline}
  shaderBackgroundPipeline = new ShaderPipeline(shaderPipeline)

  ///@type {ParticleService}
  particleService = new ParticleService(this, { layerName: layerName })

  ///@type {TrackService}
  trackService = new TrackService(this, {
    handlers: new Map(String, Callable)
      .merge(
        DEFAULT_TRACK_EVENT_HANDLERS,
        grid_track_event,
        shader_track_event,
        shroom_track_event,
        view_track_event
      ),
    isTrackLoaded: function() {
      var stateName = this.context.fsm.getStateName()
      return (stateName == "play" || stateName == "pause") 
        && Core.isType(this.track, Track)
    },
  })

  ///@type {PlayerService}
  playerService = new PlayerService(this)

	///@type {ShroomService}
  shroomService = new ShroomService(this)

	///@type {BulletService}
  bulletService = new BulletService(this)

  ///@type {GridService}
  gridService = new GridService(this)

  ///@type {GridRenderer}
  gridRenderer = new GridRenderer(this)

  ///@type {VideoService}
  videoService = new VideoService(this)

  ///@type {LyricsService}
  lyricsService = new LyricsService(this)

  ///@type {LyricsRenderer}
  lyricsRenderer = new LyricsRenderer(this)

  ///@type {UIService}
  uiService = new UIService(this)

  ///@type {VisuEditor}
  editor = new VisuEditor(this)

  ///@type {GridSystem}
  //gridSystem = new GridSystem(this) ///@ecs

  ////@type {Gamemode}
  gameMode = GameMode.BULLETHELL

  ///@type {Keyboard}
  keyboard = new Keyboard(
    { 
      controlTrack: KeyboardKeyType.SPACE,
      renderUI: KeyboardKeyType.F1,
      freeCamera: KeyboardKeyType.F5,
      fullscreen: KeyboardKeyType.F11,
      exitModal: KeyboardKeyType.ESC,
      newProject: "N",
      loadProject: "L",
      saveProject: "O",
    }
  )

  ///@type {Mouse}
  mouse = new Mouse({ 
    left: MouseButtonType.LEFT,
    right: MouseButtonType.RIGHT,
    wheelUp: MouseButtonType.WHEEL_UP,
    wheelDown: MouseButtonType.WHEEL_DOWN,
  })

  ///@type {VisuTrackLoader}
  loader = new VisuTrackLoader(this)

  ///@type {Boolean}
  renderUI = true

  ///@private
  ///@type {Number}
  spinnerFactor = 0

  ///@private
  ///@type {Sprite}
  spinner = Assert.isType(SpriteUtil
    .parse({ 
      name: "texture_spinner", 
      scaleX: 0.25, 
      scaleY: 0.25,
    }), Sprite)
  
  ///@type {FSM}
  fsm = new FSM(this, {
    initialState: { 
      name: "idle",
      data: Core.getProperty("visu.manifest.autoload", false) 
        ? new Event("load", {
            manifest: FileUtil.get(Core
              .getProperty("visu.manifest.path", 
                $"{working_directory}manifest.visu")),
            autoplay: Assert.isType(Core
              .getProperty("visu.autoplay", false), Boolean),
          })
        : null,
    },
    states: {
      "idle": {
        actions: {
          onStart: function(fsm, fsmState, data) {
            if (Core.isType(data, Event)) {
              fsm.context.send(data)
            }
          },
        },
        transitions: GMArray.toStruct([ "load", "play", "pause", "quit" ]),
      },
      "load": {
        actions: {
          onStart: function(fsm, fsmState, data) {
            fsmState.state.set("autoplay", data.autoplay)
            fsm.context.loader.fsm.dispatcher.send(new Event("transition", {
              name: "parse-manifest",
              data: data.manifest,
            }))
            
            audio_stop_all()
            VideoUtil.runGC()
            Beans.get(BeanSoundService).free()
            Beans.get(BeanTextureService).free()
          },
        },
        update: function(fsm) {
          try {
            var loaderState = fsm.context.loader.fsm.getStateName()
            Assert.areEqual(loaderState != null && loaderState != "idle", true, $"Invalid loader state: {loaderState}")
            if (loaderState == "loaded") {
              fsm.dispatcher.send(new Event("transition", {
                name: this.state.get("autoplay") ? "play" : "pause",
              }))
            }
          } catch (exception) {
            var message = $"'load' fatal error: {exception.message}"
            Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
            Logger.error("VisuController::FSM", message)
            fsm.dispatcher.send(new Event("transition", { name: "idle" }))
            fsm.context.loader.fsm.dispatcher.send(new Event("transition", { name: "idle" }))
          }
        },
        transitions: GMArray.toStruct([ "idle", "play", "pause" ]),
      },
      "play": {
        actions: {
          onStart: function(fsm, fsmState, data) {
            var promises = new Map(String, Promise, {
              "player": fsm.context.playerService
                .send(new Event("spawn-player")),
            })

            if (Optional.is(fsm.context.videoService.video)) {
              promises.set("video", fsm.context.videoService
                .send(new Event("resume-video")))
            }

            fsmState.state.set("promises", promises)
          },
        },
        update: function(fsm) {
          try {
            if (this.state.get("promises-resolved") != "success") {
              var promises = this.state.get("promises")
              var filtered = promises.filter(fsm.context.loader.utils.filterPromise)
              if (filtered.size() != promises.size()) {
                return
              }

              if (!promises.contains("track")) {
                promises.set("track", fsm.context.trackService.send(new Event("resume-track")))
                return
              }

              this.state.set("promises-resolved", "success")
              return
            }

            //Assert.isType(fsm.context.playerService.player, Player)
            //Assert.areEqual(fsm.context.videoService.getVideo().getStatus(), VideoStatus.PLAYING)
            //Assert.areEqual(fsm.context.trackService.track.getStatus(), TrackStatus.PLAYING)
          } catch (exception) {
            var message = $"'play': {exception.message}"
            Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
            Logger.error("VisuController::FSM", message)
            fsm.dispatcher.send(new Event("transition", { name: "idle" }))
          }
        },
        transitions: GMArray.toStruct([ "idle", "load", "pause", "rewind", "quit" ]),
      },
      "pause": {
        actions: {
          onStart: function(fsm, fsmState, data) {
            var promises = new Map(String, Promise, {
              "track": fsm.context.trackService
                .send(new Event("pause-track")),
            })

            if (Optional.is(fsm.context.videoService.video)) {
              promises.set("video", fsm.context.videoService
                .send(new Event("pause-video")))
            }

            fsmState.state.set("promises", promises)
          },
        },
        update: function(fsm) {
          try {
            if (this.state.get("promises-resolved") != "success") {
              var promises = this.state.get("promises")
              var filtered = promises.filter(fsm.context.loader.utils.filterPromise)
              if (filtered.size() != promises.size()) {
                return
              }
              this.state.set("promises-resolved", "success")
            }

            //Assert.areEqual(fsm.context.videoService.video.getStatus(), VideoStatus.PAUSED)
            //Assert.areEqual(fsm.context.trackService.track.getStatus(), TrackStatus.PAUSED)
          } catch (exception) {
            var message = $"'pause' fatal error: {exception.message}"
            Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
            Logger.error("VisuController", message)
            fsm.dispatcher.send(new Event("transition", { name: "idle" }))
          }
        },
        transitions: GMArray.toStruct([ "idle", "load", "play", "rewind", "quit" ]),
      },
      "rewind": {
        actions: {
          onStart: function(fsm, fsmState, data) {
            var promises = new Map(String, Promise, {
              "pause-track": fsm.context.trackService
                .send(new Event("pause-track")),
            })

            var trackDuration = fsm.context.trackService.duration
            var video = fsm.context.videoService.video
            if (Optional.is(video) && trackDuration > 0.0) {
              var videoData = JSON.clone(data)
              var videoDuration = video.getDuration()
              if (videoData.timestamp > videoDuration) {
                videoData.timestamp = videoData.timestamp mod videoDuration
              }
              
              promises.set("rewind-video", fsm.context.videoService
                .send(new Event("rewind-video", videoData)))
            }

            fsmState.state
              .set("resume", data.resume)
              .set("data", data)
              .set("promises", promises)
          },
        },
        update: function(fsm) {
          try {
            if (this.state.get("promises-resolved") != "success") {
              var promises = this.state.get("promises")
              ///@description gml bug answered by videoServiceAttempts "feature"
              try {
                var filtered = promises.filter(fsm.context.loader.utils.filterPromise)
                if (filtered.size() != promises.size()) {
                  return
                }
              } catch (exception) {
                var message = $"Rewind exception: {exception.message}"
                Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
                Logger.warn("VisuController", message)
                if (!promises.contains("rewind-video")) {
                  return
                }

                promises.forEach(function(promise, name) {
                  if (name != "rewind-video" && promise.status == PromiseStatus.REJECTED) {
                    throw new Exception($"non-video promise failed: '{name}'")
                  }
                })

                var data = this.state.get("data")
                var videoServiceAttempts = Struct.get(data, "videoServiceAttempts")
                if (!Core.isType(videoServiceAttempts, Number) 
                  || videoServiceAttempts == 0) {
                  throw new Exception($"video promise failed. 'videoServiceAttempts' value: {videoServiceAttempts}")
                }
                data.videoServiceAttempts = videoServiceAttempts - 1
                Logger.debug("VisuController", $"videoServiceAttempts value: {data.videoServiceAttempts}")
                promises.set("rewind-video", fsm.context.videoService.send(new Event("rewind-video", data)))
                return
              }

              if (!promises.contains("rewind-track")) {
                promises.set("rewind-track", fsm.context.trackService.send(new Event(
                  "rewind-track", this.state.get("data"))))
                return
              }

              this.state.set("promises-resolved", "success")
              fsm.context.send(new Event(this.state.get("resume") ? "play" : "pause"))
              return
            }
          } catch (exception) {
            var message = $"'rewind' fatal error: {exception.message}"
            Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
            Logger.error("VisuController", message)
            fsm.dispatcher.send(new Event("transition", {
              name: this.state.get("resume") ? "play" : "pause",
            }))
          }
        },
        transitions: GMArray.toStruct([ "idle", "play", "pause", "quit" ]),
      },
      "quit": {
        actions: {
          onStart: function(fsm, fsmState, data) { 
            fsm.context.free()
            game_end()
          }
        },
      },
    },
  })

  ///@type {VisuNewProjectModal}
  newProjectModal = new VisuNewProjectModal(this)

  ///@type {VisuModal}
  exitModal = new VisuModal(this, {
    message: { text: "Changes you made may not be saved." },
    accept: {
      text: "Leave",
      callback: function() {
        game_end()
      }
    },
    deny: {
      text: "Cancel",
      callback: function() {
        this.context.modal.send(new Event("close"))
      }
    }
  })

  ///@type {EventPump}
  dispatcher = new EventPump(this, new Map(String, Callable, {
    "change-gamemode": function(event) {
      this.gameMode = Assert.isEnum(event.data, GameMode)
    },
    "load": function(event) {
      this.fsm.dispatcher.send(new Event("transition", { 
        name: "load", 
        data: event.data
      }))
    },
    "play": function(event) {
      /*
      if (this.fsm.getStateName() != "pause") {
        return
      }
      */
      this.fsm.dispatcher.send(new Event("transition", { name: "play" }))
    },
    "pause": function(event) {
      /*
      if (this.fsm.getStateName() != "play") {
        return
      }
      */
      this.fsm.dispatcher.send(new Event("transition", { name: "pause" }))
    },
    "rewind": function(event) {
      var fsmEvent = new Event("transition", { 
        name: "rewind", 
        data: {
          resume: this.fsm.getStateName() == "play",
          timestamp: Assert.isType(event.data.timestamp, Number),
          videoServiceAttempts: Struct.getDefault(event.data, "videoServiceAttempts", 5),
        }
      })
      
      if (Core.isType(event.promise, Promise)) {
        fsmEvent.setPromise(event.promise)
        event.setPromise(null)
      }
      this.fsm.dispatcher.send(fsmEvent)
    },
    "quit": function(event) {
      this.fsm.dispatcher.send(new Event("transition", { name: "quit" }))
    },
    "spawn-popup": function(event) {
      this.editor.popupQueue.send(new Event("push", event.data))
    }
  }, {
    enableLogger: true,
    catchException: false,
  }))

  ///@type {TaskExecutor}
  executor = new TaskExecutor(this, {
    enableLogger: true,
    catchException: false,
  })

  ///@private
  ///@type {Array<Struct>}
  services = new Array(Struct, GMArray.map([
    "fsm",
    "loader",
    "displayService",
    "fileService",
    "dispatcher",
    "executor",
    "uiService",
    "particleService",
    "shaderPipeline",
    "shaderBackgroundPipeline",
    "trackService",
    "gridService",
    //"gridSystem", ///@ecs
    "lyricsService",
    "gridRenderer",
    "videoService",
    "editor",
    "exitModal",
    "newProjectModal"
  ], function(name, index, controller) {
    Logger.debug("VisuController", $"Load service '{name}'")
    return {
      name: name,
      struct: Assert.isType(Struct.get(controller, name), Struct),
    }
  }, this))

  ///@param {Event}
  ///@return {?Promise}
  send = function(event) {
    return this.dispatcher.send(event)
  }

  ///@private
  ///@return {VisuController}
  init = function() {
    Core.debugOverlay(Assert.isType(Core.getProperty("visu.debug-overlay", false), Boolean))
    var fullscreen = Assert.isType(Core.getProperty("visu.fullscreen", false), Boolean)
    this.displayService
      .resize(
        Assert.isType(Core.getProperty("visu.window.width", 1280), Number),
        Assert.isType(Core.getProperty("visu.window.height", 720), Number)
      )
      .setFullscreen(fullscreen)
      .setCursor(Cursor.DEFAULT)
    
    return this
  }

  ///@private
  ///@return {VisuController}
  updateIO = function() {
    this.keyboard.update()
    this.mouse.update()  

    global.GMTF_DATA.update()
    
    if (!Optional.is(global.GMTF_DATA.active) && 
      this.keyboard.keys.controlTrack.pressed) {
      switch (this.fsm.getStateName()) {
        case "play": this.send(new Event("pause")) break
        case "pause": this.send(new Event("play")) break
      }
    }

    if (this.keyboard.keys.fullscreen.pressed) {
      var fullscreen = this.displayService.getFullscreen()
      Logger.debug("VisuController", String.join("Set fullscreen to ",
        fullscreen ? "'false'" : "'true'", "."))
      this.displayService.setFullscreen(!fullscreen)
    }

    if (this.keyboard.keys.renderUI.pressed) {
      this.renderUI = !this.renderUI
    }

    if (!Optional.is(global.GMTF_DATA.active)
      && this.keyboard.keys.exitModal.pressed) {
      this.exitModal.send(new Event("open").setData({
        layout: new UILayout({
          name: "display",
          x: function() { return 0 },
          y: function() { return 0 },
          width: function() { return GuiWidth() },
          height: function() { return GuiHeight() },
        }),
      }))
      this.gridRenderer.camera.enableMouseLook = false
    }

    if (!this.renderUI) {
      return this
    }

    if (this.mouse.buttons.left.pressed) {
      this.uiService.send(new Event("MousePressedLeft", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }

    if (this.mouse.buttons.left.released) {
      this.uiService.send(new Event("MouseReleasedLeft", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))

      Beans.get(BeanVisuController).displayService.setCursor(Cursor.DEFAULT)
    }

    if (this.mouse.buttons.left.drag) {
      this.uiService.send(new Event("MouseDragLeft", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }

    if (this.mouse.buttons.left.drop) {
      this.uiService.send(new Event("MouseDropLeft", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }

    if (this.mouse.buttons.right.pressed) {
      this.uiService.send(new Event("MousePressedRight", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }

    if (this.mouse.buttons.right.released) {
      this.uiService.send(new Event("MouseReleasedRight", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }
    
    if (this.mouse.buttons.wheelUp.on) {  
      this.uiService.send(new Event("MouseWheelUp", { 
        x: MouseUtil.getMouseX(), 
        y: MouseUtil.getMouseY(),
      }))
    }
    
    if (this.mouse.buttons.wheelDown.on) {  
      this.uiService.send(new Event("MouseWheelDown", {
        x: MouseUtil.getMouseX(),
        y: MouseUtil.getMouseY(),
      }))
    }

    if (MouseUtil.hasMoved()) {  
      this.uiService.send(new Event("MouseHoverOver", {
        x: MouseUtil.getMouseX(),
        y: MouseUtil.getMouseY(),
      }))
    }

    return this
  }

  ///@private
  ///@param {Struct} service
  ///@param {Number} iterator
  ///@param {VisuController} controller
  updateService = function(service, iterator, controller) {
    try {
      service.struct.update()
    } catch (exception) {
      var name = Core.isType(Struct.get(controller, "name"), String) 
        ? service.name 
        : iterator
      var message = $"'update-service-{name}' fatal error: {exception.message}"
      Logger.error("VisuController", message)
      controller.send(new Event("spawn-popup", { message: message }))
      fsm.dispatcher.send(new Event("transition", { name: "idle" }))
    }
  }
  
  ///@return {VisuController}
  update = function() {
    try {
      this.updateIO()
    } catch (exception) {
      var message = $"'updateIO' set fatal error: {exception.message}"
      this.send(new Event("spawn-popup", { message: message }))
      Logger.error("VisuController", message)
    }

    if (this.renderUI) {
      try {
        this.uiService.update()
      } catch (exception) {
        var message = $"'update' set fatal error: {exception.message}"
        this.send(new Event("spawn-popup", { message: message }))
        Logger.error("UIService", message)
      }
    }

    this.services.forEach(this.updateService, this)

    return this
  }

  ///@return {VisuController}
  render = function() {
    try {
      gpu_set_alphatestenable(true) ///@todo investigate
      var enable = this.renderUI
      var preview = this.editor.layout.nodes.preview
      this.gridRenderer.render({ 
        width: enable ? ceil(preview.width()) : GuiWidth(), 
        height: enable ? ceil(preview.height()) : GuiHeight(),
      })
      //this.gridSystem.render()
    } catch (exception) {
      var message = $"render throws exception: {exception.message}"
      Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
      Logger.error("VisuController", message)
      GPU.reset.shader()
      GPU.reset.surface()
      GPU.reset.blendMode()
    }
    
    return this
  }

  ///@return {VisuController}
  renderGUI = function() {
    try {
      var enable = this.renderUI
      var preview = this.editor.layout.nodes.preview
      this.gridRenderer.renderGUI({ 
        width: enable ? ceil(preview.width()) : GuiWidth(), 
        height: enable ? ceil(preview.height()) : GuiHeight(), 
        x: enable ? ceil(preview.x()) : 0, 
        y: enable ? ceil(preview.y()) : 0,
      })
      this.lyricsRenderer.renderGUI()
      if (this.renderUI) {
        this.uiService.render()
        var loaderState = Beans.get(BeanVisuController).loader.fsm.getStateName()
        if (loaderState != "idle" && loaderState != "loaded") {
          var color = c_black
          this.spinnerFactor = lerp(this.spinnerFactor, 100.0, 0.1)
  
          GPU.render.rectangle(
            0, 0, 
            GuiWidth(), GuiHeight(), 
            false, 
            color, color, color, color, 
            (this.spinnerFactor / 100) * 0.5
          )
  
          this.spinner
            .setAlpha(this.spinnerFactor / 100.0)
            .render(
              (GuiWidth() / 2) - ((this.spinner.getWidth() * this.spinner.getScaleX()) / 2),
              (GuiHeight() / 2) - ((this.spinner.getHeight() * this.spinner.getScaleY()) / 2)
                - (this.spinnerFactor / 2)
          )
        } else if (this.spinnerFactor > 0) {
          var color = c_black
          this.spinnerFactor = lerp(this.spinnerFactor, 0.0, 0.1)
  
          GPU.render.rectangle(
            0, 0, 
            GuiWidth(), GuiHeight(), 
            false, 
            color, color, color, color, 
            (this.spinnerFactor / 100) * 0.5
          )
  
          this.spinner
            .setAlpha(this.spinnerFactor / 100.0)
            .render(
            (GuiWidth() / 2) - ((this.spinner.getWidth() * this.spinner.getScaleX()) / 2),
            (GuiHeight() / 2) - ((this.spinner.getHeight() * this.spinner.getScaleY()) / 2)
              - (this.spinnerFactor / 2)
          )
        }
      }
      
      //MouseUtil.renderSprite()
      //this.editor.render()
    } catch (exception) {
      var message = $"renderGUI throws exception: {exception.message}"
      Beans.get(BeanVisuController).send(new Event("spawn-popup", { message: message }))
      Logger.error("VisuController", message)
      GPU.reset.shader()
      GPU.reset.surface()
      GPU.reset.blendMode()
    }

    return this
  }

  ///@return {VisuController}
  onSceneEnter = function() {
    Logger.info("VisuController", "onSceneEnter")
    this.editor.send(new Event("open"))
    return this
  }

  ///@return {VisuController}
  onSceneLeave = function() {
    Logger.info("VisuController", "onSceneLeave")
    return this
  }

  ///@return {VisuController}
  onNetworkEvent = function() {
    try {
      var json = json_encode(async_load)
      var event = JSON.parse(json)
      var message = buffer_read(event.buffer, buffer_string)
      Core.print("[onNetworkEvent] event:", event)
      Core.print("[onNetworkEvent] message:", message)
    } catch (exception) {
      var message = $"'onNetworkEvent' fatal error: {exception.message}"
      this.send(new Event("spawn-popup", { message: message }))
      Logger.error("VisuController", message)	
    }

    return this
  }

  ///@return {VisuController}
  free = function() {
    Struct.toMap(this)
      .filter(function(value) {
        if (!Core.isType(value, Struct)
          || !Struct.contains(value, "free")
          || !Core.isType(Struct.get(value, "free"), Callable)) {
          return false
        }
        return true
      })
      .forEach(function(struct, key, context) {
        try {
          Logger.debug("VisuController", $"Free '{key}'")
          Callable.run(Struct.get(struct, "free"))
          var ref = ref_create(context, key)
          delete ref
        } catch (exception) {
          Logger.error("VisuController", $"Unable to free '{key}'. {exception.message}")
        }
      }, this)
    
    return this
  }

  this.init()
}

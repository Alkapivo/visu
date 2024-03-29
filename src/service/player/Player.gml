///@package io.alkapivo.visu.service.player

///@param {Struct} json
function PlayerTemplate(json) constructor {

  ///@type {String}
  name = Assert.isType(json.name, String)

  ///@type {Struct}
  sprite = Assert.isType(json.sprite, Struct)

  ///@type {?Struct}
  mask = Core.isType(Struct.get(json, "mask"), Struct) ? json.mask : null

  ///@type {Keyboard}
  keyboard = new Keyboard(json.keyboard)

  ///@type {Struct}
  gameModes = Struct.appendUnique(
    Struct.filter(Struct.getDefault(json, "gameModes", {}), function(gameMode, key) { 
      return Core.isType(gameMode, Struct) && Core.isEnum(key, GameMode)
    }),
    PLAYER_GAME_MODES.toStruct(function() { return {} })
  )

  ///@return {Struct}
  serialize = function() {
    var json = {
      sprite: this.sprite,
      gameModes: this.gameModes,
      keyboard: this.keyboard,
    }

    if (Core.isType(this.mask, Struct)) {
      Struct.set(json, "mask", this.mask)
    }

    return JSON.clone(json)
  }
}

///@param {PlayerTemplate} json
function Player(template): GridItem(template) constructor {

  ///@type {Keyboard}
  keyboard = Assert.isType(template.keyboard, Keyboard)

  ///@private
  ///@param {VisuController} controller
  ///@return {GridItem}
  _update = method(this, this.update)
  
  ///@override
  ///@return {GridItem}
  update = function(controller) {
    this.keyboard.update()
    this._update(controller)

    var _xx = controller.gridService.view.x
    var _yy = controller.gridService.view.y
    return this
  }

  this.gameModes
    .set(GameMode.IDLE, PlayerIdleGameMode(Struct
      .getDefault(Struct.get(template, "gameModes"), "idle", {})))
    .set(GameMode.BULLETHELL, PlayerBulletHellGameMode(Struct
      .getDefault(Struct.get(template, "gameModes"), "bulletHell", {})))
    .set(GameMode.PLATFORMER, PlayerPlatformerGameMode(Struct
      .getDefault(Struct.get(template, "gameModes"), "platformer", {})))
}

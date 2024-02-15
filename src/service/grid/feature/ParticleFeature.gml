///@package io.alkapivo.visu.service.grid.feature

///@param {Struct} [json]
///@return {GridItemFeature}
function ParticleFeature(json = {}) {
  return new GridItemFeature(Struct.append(json, {

    ///@param {Callable}
    type: ParticleFeature,

    ///@type {String}
    particle: Assert.isType(Struct.getDefault(json, "particle", "particle_default"), String),

    ///@override
    ///@param {GridItem} item
    ///@param {VisuController} controller
    update: function(item, controller) {
      if (Optional.is(this.particle)) {
        var view = controller.gridService.view
        var _x = (item.x - view.x) * GRID_SERVICE_PIXEL_WIDTH
        var _y = (item.y - view.y) * GRID_SERVICE_PIXEL_HEIGHT

        if ((_x < 0 || _x > GRID_SERVICE_PIXEL_WIDTH) 
          || (_y < 0 || _y > GRID_SERVICE_PIXEL_HEIGHT)) {
          Core.print("escape", _x, _y)
          return
        }

        controller.particleService.send(controller.particleService
          .factoryEventSpawnParticleEmitter(
            {
              particleName: this.particle,
              beginX: _x,
              beginY: _y,
              endX: _x,
              endY: _y,
            }, 
          ))
      }
    },
  }))
}
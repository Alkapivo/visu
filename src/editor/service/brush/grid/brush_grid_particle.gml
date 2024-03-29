///@package io.alkapivo.visu.editor.service.brush.grid

///@param {?Struct} [json]
///@return {Struct}
function brush_grid_particle(json = null) {

  generateParticleAreaMethods = function() {
    return {
      onMouseHoverOver: function(event) { },
      onMouseHoverOut: function(event) { },
      preRender: function() {
        if (!this.isHoverOver) {
          return
        }

        var store = null
        if (Core.isType(this.context.state.get("brush"), VEBrush)) {
          store = this.context.state.get("brush").store
        } else if (Core.isType(this.context.state.get("event"), VEEvent)) {
          store = this.context.state.get("event").store
        } else {
          return
        }

        var shroomService = Beans.get(BeanVisuController).shroomService
        shroomService.particleArea = {
          topLeft: shroomService.factorySpawner({ 
            x: store.getValue("grid-particle_beginX"), 
            y: store.getValue("grid-particle_beginY"),
          }),
          topRight: shroomService.factorySpawner({ 
            x: store.getValue("grid-particle_endX"), 
            y: store.getValue("grid-particle_beginY"),
          }),
          bottomLeft: shroomService.factorySpawner({ 
            x: store.getValue("grid-particle_beginX"), 
            y: store.getValue("grid-particle_endY"),
          }),
          bottomRight: shroomService.factorySpawner({ 
            x: store.getValue("grid-particle_endX"), 
            y: store.getValue("grid-particle_endY"),
          })
        }
      },
    }
  }

  return {
    name: "brush_grid_particle",
    store: new Map(String, Struct, {
      "grid-particle_template": {
        type: String,
        value: Struct.getDefault(json, "grid-particle_template", "particle_default"),
      },
      "grid-particle_beginX": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_beginX", 0.5),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), -3.0, 3.0) 
          //return NumberUtil.parse(value, this.value)
        },
      },
      "grid-particle_beginY": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_beginY", 0.5),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), -3.0, 3.0)
          //return NumberUtil.parse(value, this.value)
        },
      },
      "grid-particle_endX": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_endX", 0.5),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), -3.0, 3.0) 
          //return NumberUtil.parse(value, this.value)
        },
      },
      "grid-particle_endY": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_endY", 0.5),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), -3.0, 3.0) 
          //return NumberUtil.parse(value, this.value)
        },
      },
      "grid-particle_amount": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_amount", 10),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), 1, 999.0) 
        },
      },
      "grid-particle_interval": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_interval", FRAME_MS),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), FRAME_MS, 999.0) 
        },
      },
      "grid-particle_duration": {
        type: Number,
        value: Struct.getDefault(json, "grid-particle_duration", 0),
        passthrough: function(value) {
          return clamp(NumberUtil.parse(value, this.value), 0.0, 999.0) 
        },
      },
      "grid-particle_shape": {
        type: String,
        value: Struct.getDefault(json, "grid-particle_shape", ParticleEmitterShape.keys().get(0)),
        validate: function(value) {
          Assert.areEqual(true, this.data.contains(value))
        },
        data: ParticleEmitterShape.keys(),
      },
      "grid-particle_distribution": {
        type: String,
        value: Struct.getDefault(json, "grid-particle_distribution", ParticleEmitterDistribution.keys().get(0)),
        validate: function(value) {
          Assert.areEqual(true, this.data.contains(value))
        },
        data: ParticleEmitterDistribution.keys(),
      },
    }),
    components: new Array(Struct, [
      {
        name: "grid-particle_template",  
        template: VEComponents.get("text-field"),
        layout: VELayouts.get("text-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Particle" },
          field: { store: { key: "grid-particle_template" } },
        },
      },
      {
        name: "grid-particle_beginX",  
        template: VEComponents.get("numeric-slider-field"),
        layout: VELayouts.get("numeric-slider-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Begin X" },
          field: Struct.appendUnique(
            { store: { key: "grid-particle_beginX" } },
            generateParticleAreaMethods(),
            false
          ),
          slider: Struct.appendUnique(
            { 
              store: { key: "grid-particle_beginX" },
              minValue: -3.0,
              maxValue: 3.0,
            },
            generateParticleAreaMethods(),
            false
          ),
        },
      },
      {
        name: "grid-particle_beginY",  
        template: VEComponents.get("numeric-slider-field"),
        layout: VELayouts.get("numeric-slider-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Begin Y" },
          field: Struct.appendUnique(
            { store: { key: "grid-particle_beginY" } },
            generateParticleAreaMethods(),
            false
          ),
          slider: Struct.appendUnique(
            { 
              store: { key: "grid-particle_beginY" },
              minValue: -3.0,
              maxValue: 3.0,
            },
            generateParticleAreaMethods(),
            false
          ),
        },
      },
      {
        name: "grid-particle_endX",  
        template: VEComponents.get("numeric-slider-field"),
        layout: VELayouts.get("numeric-slider-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "End X" },
          field: Struct.appendUnique(
            { store: { key: "grid-particle_endX" } },
            generateParticleAreaMethods(),
            false
          ),
          slider: Struct.appendUnique(
            { 
              store: { key: "grid-particle_endX" },
              minValue: -3.0,
              maxValue: 3.0,
            },
            generateParticleAreaMethods(),
            false
          ),
        },
      },
      {
        name: "grid-particle_endY",  
        template: VEComponents.get("numeric-slider-field"),
        layout: VELayouts.get("numeric-slider-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "End Y" },
          field: Struct.appendUnique(
            { store: { key: "grid-particle_endY" } },
            generateParticleAreaMethods(),
            false
          ),
          slider: Struct.appendUnique(
            { 
              store: { key: "grid-particle_endY" },
              minValue: -3.0,
              maxValue: 3.0,
            },
            generateParticleAreaMethods(),
            false
          ),
        },
      },
      {
        name: "grid-particle_amount",  
        template: VEComponents.get("text-field"),
        layout: VELayouts.get("text-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Amount" },
          field: { store: { key: "grid-particle_amount" } },
        },
      },
      {
        name: "grid-particle_interval",  
        template: VEComponents.get("text-field"),
        layout: VELayouts.get("text-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Interval" },
          field: { store: { key: "grid-particle_interval" } },
        },
      },
      {
        name: "grid-particle_duration",  
        template: VEComponents.get("text-field"),
        layout: VELayouts.get("text-field"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Duration" },
          field: { store: { key: "grid-particle_duration" } },
        },
      },
      {
        name: "grid-particle_shape",
        template: VEComponents.get("spin-select"),
        layout: VELayouts.get("spin-select"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Shape" },
          previous: { store: { key: "grid-particle_shape" } },
          preview: Struct.appendRecursive({ 
            store: { key: "grid-particle_shape" },
          }, Struct.get(VEStyles.get("spin-select-label"), "preview"), false),
          next: { store: { key: "grid-particle_shape" } },
        },
      },
      {
        name: "grid-particle_distribution",
        template: VEComponents.get("spin-select"),
        layout: VELayouts.get("spin-select"),
        config: { 
          layout: { type: UILayoutType.VERTICAL },
          label: { text: "Dist." },
          previous: { store: { key: "grid-particle_distribution" } },
          preview: Struct.appendRecursive({ 
            store: { key: "grid-particle_distribution" },
          }, Struct.get(VEStyles.get("spin-select-label"), "preview"), false),
          next: { store: { key: "grid-particle_distribution" } },
        },
      },
    ]),
  }
}
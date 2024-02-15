///@package io.alkapivo.visu.service.grid.feature

///@param {Struct} [json]
///@return {GridItemFeature}
function CounterFeature(json = {}) {
  return new GridItemFeature(Struct.append(json, {

    ///@param {Callable}
    type: CounterFeature,

    ///@type {Number}
    value: Assert.isType(Struct.getDefault(json, "value", 0), Number),

    ///@type {Number}
    amount: Assert.isType(Struct.getDefault(json, "amount", 1), Number),

    ///@type {Number}
    minValue: Assert.isType(Struct.getDefault(json, "minValue", 0), Number),

    ///@type {Number}
    maxValue: Assert.isType(Struct.getDefault(json, "maxValue", 1), Number),

    ///@type {String}
    field: Assert.isType(Struct.getDefault(json, "field", "counter"), String),

    ///@override
    ///@param {GridItem} item
    ///@param {VisuController} controller
    update: function(item, controller) {
      Struct.inject(item, this.field, this.value)
      this.value = clamp(Struct.get(item, this.field) + this.amount, this.minValue, this.maxValue)
      Struct.set(item, this.field, this.value)
      Core.print("field", this.field, this.value)
    },
  }))
}

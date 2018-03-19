LayerInfo = require '../layer_info.coffee'
Descriptor = require '../descriptor.coffee'

module.exports = class PlacedLayer extends LayerInfo
  @shouldParse: (key) -> key is 'SoLd'

  parse: ->
    @file.seek 12, true
    @data = new Descriptor(@file).parse()

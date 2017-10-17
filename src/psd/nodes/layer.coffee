merge    = require 'lodash/merge'
Node = require '../node.coffee'

module.exports = class Layer extends Node
  type: 'layer'

  isEmpty: -> @width is 0 or @height is 0

  export: ->
    merge super(),
      type: 'layer'
      mask: @layer.mask.export()
      text: @get('typeTool')?.export()
      image: {}

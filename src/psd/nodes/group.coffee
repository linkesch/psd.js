merge    = require 'lodash/merge'
Node = require '../node.coffee'

module.exports = class Group extends Node
  type: 'group'

  passthruBlending: ->
    @get('blendingMode') is 'passthru'

  isEmpty: ->
    return false unless child.isEmpty() for child in @_children

  export: ->
    merge super(),
      type: 'group'
      mask: @layer.mask.export()
      children: @_children.map((c) -> c.export())

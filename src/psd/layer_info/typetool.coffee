reduce = require 'lodash/reduce'
parseEngineData = require 'parse-engine-data'
LayerInfo = require '../layer_info.coffee'
Descriptor = require '../descriptor.coffee'

module.exports = class TextElements extends LayerInfo
  @shouldParse: (key) -> key is 'TySh'

  TRANSFORM_VALUE = ['xx', 'xy', 'yx', 'yy', 'tx', 'ty']
  COORDS_VALUE = ['left', 'top', 'right', 'bottom']

  constructor: (layer, length) ->
    super(layer, length)

    @version = null
    @transform = {}
    @textVersion = null
    @descriptorVersion = null
    @textData = null
    @engineData = null
    @textValue = null
    @warpVersion = null
    @descriptorVersion = null
    @warpData = null
    @coords = {}

  parse: ->
    @version = @file.readShort()

    @parseTransformInfo()

    @textVersion = @file.readShort()
    @descriptorVersion = @file.readInt()

    @textData = new Descriptor(@file).parse()
    @textValue = @textData['Txt ']
    @engineData = parseEngineData(@textData.EngineData)

    @warpVersion = @file.readShort()

    @descriptorVersion = @file.readInt()

    @warpData = new Descriptor(@file).parse()

    for name, index in COORDS_VALUE
      @coords[name] = @file.readInt()

  parseTransformInfo: ->
    for name, index in TRANSFORM_VALUE
      @transform[name] = @file.readDouble()

  fonts: ->
    return [] if not @engineData? or !@styles().Font
    @styles().Font.map (f) => @engineData.ResourceDict.FontSet[f].Name

  sizes: ->
    return [] if not @engineData? or !@styles().FontSize
    @styles().FontSize

  alignment: ->
    return [] unless @engineData?
    alignments = ['left', 'right', 'center', 'justify']
    @engineData.EngineDict.ParagraphRun.RunArray.map (s) ->
      alignments[Math.min(parseInt(s.ParagraphSheet.Properties.Justification, 10), 3)]

  # Return all colors used for text in this layer. The colors are returned in RGBA
  # format as an array of arrays.
  colors: ->
    # If the color is opaque black, this field is sometimes omitted.
    return [[0, 0, 0, 255]] if not @engineData? or not @styles().FillColor?

    @styles().FillColor.map (s) ->
      values = s.Values.map (v) -> Math.round(v * 255)
      values.push values.shift() # Change ARGB -> RGBA for consistency
      values

  styles: ->
    return {} unless @engineData?
    return @_styles if @_styles?

    data = @engineData.EngineDict.StyleRun.RunArray.map (r) ->
      r.StyleSheet.StyleSheetData

    @_styles = reduce(data, (m, o) ->
      for own k, v of o
        m[k] or= []
        m[k].push v
      m
    , {})

  # Creates the CSS string and returns it. Each property is newline separated
  # and not all properties may be present depending on the document.
  #
  # Colors are returned in rgba() format and fonts may include some internal
  # Photoshop fonts.
  toCSS: ->
    definition =
      'font-family': @fonts().join(', ')
      'font-size': "#{@sizes()[0]}pt"
      'color': "rgba(#{@colors()[0].join(', ')})"
      'text-align': @alignment()[0]
      'line-height': "#{@lineHeight()[0]}pt"
      'letter-spacing': "#{(@tracking()[0] || 0) / 1000}em"

    css = []
    for k, v of definition
      continue unless v?
      css.push "#{k}: #{v};"

    css.join("\n")

  lengthArray: ->
    arr = @engineData.EngineDict.StyleRun.RunLengthArray
    sum = reduce arr, (m, o) ->
      m + o

    if sum - @textValue.length == 1
      arr[arr.length - 1] = arr[arr.length - 1] - 1

    arr

  fontStyles: ->
    data = @engineData.EngineDict.StyleRun.RunArray.map (r) ->
      r.StyleSheet.StyleSheetData

    data = data.map (f) ->
      if f.FauxItalic
        return 'italic'

      return 'normal'

  fontWeights: ->
    data = @engineData.EngineDict.StyleRun.RunArray.map (r) ->
      r.StyleSheet.StyleSheetData

    data = data.map (f) ->
      if f.FauxBold
        return 'bold'

      return 'normal'

  textDecoration: ->
    data = @engineData.EngineDict.StyleRun.RunArray.map (r) ->
      r.StyleSheet.StyleSheetData

    data = data.map (f) ->
      if f.Underline
        return 'underline'

      return 'normal'

  lineHeight: ->
    return [] if not @engineData? or !@styles().Leading
    @styles().Leading

  tracking: ->
    return [] if not @engineData? or !@styles().Tracking
    @styles().Tracking

  export: ->
    value: @textValue
    font:
      name: @fonts()
      sizes: @sizes()
      colors: @colors()
      alignment: @alignment()
      lengthArray: @lengthArray()
      styles: @fontStyles()
      weights: @fontWeights()
      textDecoration: @textDecoration()
      lineHeight: @lineHeight()
      tracking: @tracking()
    left: @coords.left
    top: @coords.top
    right: @coords.right
    bottom: @coords.bottom
    transform: @transform

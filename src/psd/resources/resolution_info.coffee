module.exports = class ResolutionInfo
  id: 1005
  name: 'resolutionInfo'

  constructor: (@resource) ->
    @file = @resource.file

  parse: ->
    # 32-bit fixed-point number (16.16)
    @h_res = @file.readUInt() / 65536 #.to_f / (1 << 16)
    @h_res_unit = @file.readUShort()
    @width_unit = @file.readUShort()

    # 32-bit fixed-point number (16.16)
    @v_res = @file.readUInt() / 65536 #.to_f / (1 << 16)
    @v_res_unit = @file.readUShort()
    @height_unit = @file.readUShort()

    @resource.data = @

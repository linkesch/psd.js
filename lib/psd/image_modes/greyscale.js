// Generated by CoffeeScript 1.7.1
(function() {
  module.exports = {
    setGreyscaleChannels: function() {
      this.channelsInfo = [
        {
          id: 0
        }
      ];
      if (this.channels() === 2) {
        return this.channelsInfo.push({
          id: -1
        });
      }
    },
    combineGreyscaleChannel: function() {
      var alpha, grey, i, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.numPixels; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        grey = this.channelData[i];
        alpha = this.channels() === 2 ? this.channelData[this.channelLength + i] : 255;
        _results.push(this.pixelData.push(grey, grey, grey, alpha));
      }
      return _results;
    }
  };

}).call(this);

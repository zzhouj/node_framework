// Generated by CoffeeScript 1.7.1
(function() {
  var pinyin, _;

  _ = require('underscore');

  pinyin = require('pinyin');

  exports.normal = function(name) {
    return _.flatten(pinyin(name || '', {
      style: pinyin.STYLE_NORMAL
    })).join('');
  };

  exports.firstLetter = function(name) {
    return _.flatten(pinyin(name || '', {
      style: pinyin.STYLE_FIRST_LETTER
    })).join('');
  };

}).call(this);
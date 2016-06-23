_ = require 'underscore'
pinyin = require 'pinyin'

exports.normal = (name) ->
  _.flatten(pinyin (name or ''), { style: pinyin.STYLE_NORMAL}).join('')

exports.firstLetter = (name) ->
  _.flatten(pinyin (name or ''), { style: pinyin.STYLE_FIRST_LETTER}).join('')

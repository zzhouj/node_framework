genNumPass = (len = 6) ->
  pass = (Math.floor(Math.random() * 10) for i in [0...len]).join ''

padzero = (i, min = 3) ->
  str = "#{i}"
  if str.length < min
    pad = min - str.length
    str = "0#{str}" for [0...pad]
  str

RegExpEscape = (str) ->
  str?.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"

replaceAll = (contentText, replaceText, withText) ->
  contentText.replace new RegExp(RegExpEscape(replaceText), 'g'), withText

module.exports = {genNumPass, padzero, RegExpEscape, replaceAll}
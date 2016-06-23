crypto = require 'crypto'

exports.cipher = (data, key) ->
  cipher = crypto.createCipher 'aes-128-ecb', key
  enciphered = cipher.update data, 'utf8', 'base64'
  enciphered += cipher.final 'base64'
  enciphered

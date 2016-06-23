fs = require 'fs'
crypto = require 'crypto'

exports.copyFile = (source, target, cb) ->
  rd = fs.createReadStream source
  rd.on "error", (err) ->
    done err

  wr = fs.createWriteStream target
  wr.on "error", (err) ->
    done err
  wr.on "close", (ex) ->
    done()

  rd.pipe wr

  cbCalled = false
  done = (err) ->
    unless cbCalled
      cb err
      cbCalled = true

exports.sha1OfFile = (srcFile, cb) ->
  h = crypto.createHash 'sha1'
  s = fs.createReadStream srcFile
  s.on 'error', (err) ->
    done err
  s.on 'data', (d) ->
    h.update d
  s.on 'end', ->
    done null, h.digest 'hex'

  cbCalled = false
  done = (err, sha1) ->
    unless cbCalled
      cb err, sha1
      cbCalled = true
express = require 'express'
path = require 'path'
fs = require 'fs'

router = express.Router()

if fs.existsSync path.join __dirname, '../permissions/defaultPermission.js'
  router.all '*', require '../permissions/defaultPermission.js'

files = fs.readdirSync path.join __dirname, '../permissions'
for file in files
  if m = file.match /^(\w+)Permission\.js$/
    name = m[1]
    if name != 'default'
      router.all "/#{name}", require "../permissions/#{name}Permission"

router.get '/', (req, res) ->
  res.redirect '/{{DEFAULT_APP}}'

files = fs.readdirSync path.join __dirname, '../controllers'
for file in files
  if m = file.match /^(\w+)Controller\.js$/
    name = m[1]
    router.use "/#{name}", require "../controllers/#{name}Controller"

files = fs.readdirSync path.join __dirname, '../restful'
for file in files
  if m = file.match /^(\w+)Restful\.js$/
    name = m[1]
    if name != 'base'
      router.use "/rest/#{name}", require "../restful/#{name}Restful"

module.exports = router

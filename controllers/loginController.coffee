express = require 'express'
User = require '../models/user'
_ = require 'underscore'
config = require '../config'

router = express.Router()

router.get '/', (req, res) ->
  res.render 'login'

router.post '/', (req, res) ->
  {username, password} = req.body
  if username == 'root' and password == config.rootSecret
    req.session.user = {username, admin: true}
    res.redirect '../'
  else
    res.render 'login', {err: '用户名或密码错误'}

module.exports = router
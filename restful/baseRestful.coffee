express = require 'express'
_ = require 'underscore'

module.exports = (Model) ->
  router = express.Router()

  router.get '/', (req, res) ->
    Model.query _.extend(req.query, {$user: req.session.user}), (err, rows) ->
      return res.status(500).send err if err
      res.send rows

  router.get '/:id', (req, res) ->
    id = req.param 'id'
    Model.get id, (err, row) ->
      return res.status(500).send err if err
      if typeof row == 'string'
        res.set 'Content-Type', 'text/plain'
      res.send row
    , _.extend(req.query, {$user: req.session.user})

  router.post '/:id', (req, res) ->
    id = req.param 'id'
    item = req.body
    Model.update id, item, (err, result) ->
      return res.status(500).send err if err
      res.send result

  router.delete '/:id', (req, res) ->
    id = req.param 'id'
    Model.delete id, (err, result) ->
      return res.status(500).send err if err
      res.send result

  router.post '/', (req, res) ->
    item = req.body
    Model.create _.extend(item, {$user: req.session.user}), (err, result) ->
      return res.status(500).send err if err
      res.send result

  router

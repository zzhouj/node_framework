// Generated by CoffeeScript 1.7.1
(function() {
  var express, _;

  express = require('express');

  _ = require('underscore');

  module.exports = function(Model) {
    var router;
    router = express.Router();
    router.get('/', function(req, res) {
      return Model.query(_.extend(req.query, {
        $user: req.session.user
      }), function(err, rows) {
        if (err) {
          return res.status(500).send(err);
        }
        return res.send(rows);
      });
    });
    router.get('/:id', function(req, res) {
      var id;
      id = req.param('id');
      return Model.get(id, function(err, row) {
        if (err) {
          return res.status(500).send(err);
        }
        if (typeof row === 'string') {
          res.set('Content-Type', 'text/plain');
        }
        return res.send(row);
      }, _.extend(req.query, {
        $user: req.session.user
      }));
    });
    router.post('/:id', function(req, res) {
      var id, item;
      id = req.param('id');
      item = req.body;
      return Model.update(id, _.extend(item, {
        $user: req.session.user
      }), function(err, result) {
        if (err) {
          return res.status(500).send(err);
        }
        return res.send(result);
      });
    });
    router["delete"]('/:id', function(req, res) {
      var id;
      id = req.param('id');
      return Model["delete"](id, function(err, result) {
        if (err) {
          return res.status(500).send(err);
        }
        return res.send(result);
      });
    });
    router.post('/', function(req, res) {
      var item;
      item = req.body;
      return Model.create(_.extend(item, {
        $user: req.session.user
      }), function(err, result) {
        if (err) {
          return res.status(500).send(err);
        }
        return res.send(result);
      });
    });
    return router;
  };

}).call(this);

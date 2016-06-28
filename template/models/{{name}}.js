// Generated by CoffeeScript 1.7.1
(function() {
  var BaseModel, Model, mysql,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require('./baseModel');

  mysql = require('mysql');

  Model = (function(_super) {
    __extends(Model, _super);

    function Model() {
      return Model.__super__.constructor.apply(this, arguments);
    }

    Model.prototype.getWhereSql = function(options) {
      var name, whereSql;
      name = options.name;
      whereSql = " 1=1 ";
      if (name) {
        whereSql += " AND name LIKE " + (mysql.escape("%" + name + "%")) + " ";
      }
      return whereSql;
    };

    return Model;

  })(BaseModel);

  module.exports = new Model({
    name: '{{name}}',
    id: 'id',
    schema: {
      name: {
        type: String,
        size: 45
      },
      createTime: Date,
      updateTime: Date
    },
    labels: {
      $model: '{{label}}',
      name: '名称',
      createTime: '创建时间',
      updateTime: '更新时间'
    }
  });

}).call(this);

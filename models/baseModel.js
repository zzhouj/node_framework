// Generated by CoffeeScript 1.7.1
(function() {
  var BaseModel, config, dateformat, mysql, mysqlPool, _,
    __hasProp = {}.hasOwnProperty;

  mysql = require('mysql');

  dateformat = require('dateformat');

  _ = require('underscore');

  mysqlPool = require('../utils/mysqlPool');

  config = require('../config');

  BaseModel = (function() {
    function BaseModel(table) {
      this.table = table;
    }

    BaseModel.prototype.query = function(options, cb) {
      var page, sql;
      page = options.page;
      if (page) {
        page = parseInt(page) || 0;
      }
      sql = typeof this.getQuerySql === "function" ? this.getQuerySql(options) : void 0;
      if (!sql) {
        sql = "SELECT\n*\nFROM " + (mysql.escapeId(this.table.name)) + "\n";
      }
      if (this.table.orderBy) {
        sql += " ORDER BY " + this.table.orderBy + " ";
      } else {
        sql += " ORDER BY " + (mysql.escapeId(this.table.id)) + " DESC ";
      }
      if (page != null) {
        sql += " LIMIT " + (page * config.pageSize) + ", " + config.pageSize + " ";
      }
      return mysqlPool.query(sql, function(err, rows) {
        return cb(err, rows);
      });
    };

    BaseModel.prototype.get = function(id, cb) {
      var sql;
      sql = "SELECT\n*\nFROM " + (mysql.escapeId(this.table.name)) + "\nWHERE " + (mysql.escapeId(this.table.id)) + " = " + (mysql.escape(id));
      return mysqlPool.query(sql, function(err, rows) {
        if (err) {
          return cb(err);
        }
        if (!(rows && rows.length > 0)) {
          return cb('not found');
        }
        return cb(err, rows[0]);
      });
    };

    BaseModel.prototype.update = function(id, item, cb) {
      var field, fields, i, sql, type, value, _i, _len, _ref, _ref1;
      sql = "UPDATE " + (mysql.escapeId(this.table.name)) + "\nSET";
      fields = [];
      _ref = this.table.schema;
      for (field in _ref) {
        if (!__hasProp.call(_ref, field)) continue;
        type = _ref[field];
        if ((type != null ? type.type : void 0) != null) {
          type = type.type;
        }
        if (item[field] != null) {
          fields.push({
            field: field,
            type: type
          });
        }
      }
      for (i = _i = 0, _len = fields.length; _i < _len; i = ++_i) {
        _ref1 = fields[i], field = _ref1.field, type = _ref1.type;
        value = item[field];
        if (type === Date) {
          value = dateformat(item[field], 'yyyy-mm-dd HH:MM:ss');
        }
        sql += " " + (mysql.escapeId(field)) + " = " + (mysql.escape(value)) + " ";
        if (i < (fields.length - 1)) {
          sql += " , ";
        }
      }
      sql += " WHERE " + (mysql.escapeId(this.table.id)) + " = " + (mysql.escape(id)) + " ";
      return mysqlPool.query(sql, function(err, result) {
        return cb(err, result);
      });
    };

    BaseModel.prototype["delete"] = function(id, cb) {
      var sql;
      sql = "DELETE\nFROM " + (mysql.escapeId(this.table.name)) + "\nWHERE " + (mysql.escapeId(this.table.id)) + " = " + (mysql.escape(id));
      return mysqlPool.query(sql, function(err, result) {
        return cb(err, result);
      });
    };

    BaseModel.prototype.create = function(item, cb) {
      var field, fields, i, sql, type, value, _i, _len, _ref, _ref1;
      sql = "INSERT\nINTO " + (mysql.escapeId(this.table.name)) + "\nSET";
      fields = [];
      if (item[this.table.id]) {
        fields.push({
          field: this.table.id,
          type: String
        });
      }
      _ref = this.table.schema;
      for (field in _ref) {
        if (!__hasProp.call(_ref, field)) continue;
        type = _ref[field];
        if ((type != null ? type.type : void 0) != null) {
          type = type.type;
        }
        if (item[field] != null) {
          fields.push({
            field: field,
            type: type
          });
        }
      }
      for (i = _i = 0, _len = fields.length; _i < _len; i = ++_i) {
        _ref1 = fields[i], field = _ref1.field, type = _ref1.type;
        value = item[field];
        if (type === Date) {
          value = dateformat(item[field], 'yyyy-mm-dd HH:MM:ss');
        }
        sql += " " + (mysql.escapeId(field)) + " = " + (mysql.escape(value)) + " ";
        if (i < (fields.length - 1)) {
          sql += " , ";
        }
      }
      return mysqlPool.query(sql, function(err, result) {
        return cb(err, result);
      });
    };

    BaseModel.prototype.createTableSql = function() {
      var sql;
      sql = "CREATE TABLE " + (mysql.escapeId(this.table.name)) + " (\n";
      _.each(this.table.schema, (function(_this) {
        return function(option, field) {
          var mysqlType;
          option = (option != null ? option.type : void 0) != null ? _.extend(option) : {
            type: option
          };
          if (option.isNotNull == null) {
            option.isNotNull = true;
          }
          if (option.type === String) {
            mysqlType = "VARCHAR(" + (option.size || 45) + ")";
          } else if (option.type === Number) {
            mysqlType = "BIGINT(" + (option.size || 20) + ")";
          } else if (option.type === Date) {
            mysqlType = "DATETIME";
          }
          return sql += "\t" + (mysql.escapeId(field)) + " " + mysqlType + " " + (option.isNotNull ? 'NOT NULL' : '') + ",\n";
        };
      })(this));
      sql += "\t" + (mysql.escapeId(this.table.id)) + " BIGINT(20) NOT NULL AUTO_INCREMENT,\n";
      sql += "\tPRIMARY KEY (" + (mysql.escapeId(this.table.id)) + ")\n";
      return sql += ") ENGINE=InnoDB DEFAULT CHARSET=utf8;\n";
    };

    return BaseModel;

  })();

  module.exports = BaseModel;

}).call(this);

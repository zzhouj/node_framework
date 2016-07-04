mysql = require 'mysql'
dateformat = require 'dateformat'
_ = require 'underscore'
mysqlPool = require '../utils/mysqlPool'
config = require '../config'
assert = require 'assert'

class BaseModel
  constructor: (@table) ->
    if @table.labels
      _.each @table.labels, (val, key) =>
        assert @table.schema[key], "'#{key}' missing schema" unless key == '$model'
    if @table.defaults
      _.each @table.defaults, (val, key) =>
        assert @table.schema[key], "'#{key}' missing schema"

  query: (options, cb) ->
    {page} = options
    page = parseInt(page) or 0 if page
    sql = @getQuerySql?(options)
    unless sql
      sql = """
            SELECT
            *
            FROM #{mysql.escapeId @table.name}

            """
    whereSql = @getWhereSql?(options)
    sql += " WHERE #{whereSql} " if whereSql
    if @table.orderBy
      sql += " ORDER BY #{@table.orderBy} "
    else
      sql += " ORDER BY #{mysql.escapeId @table.id} DESC "
    sql += " LIMIT #{page * config.pageSize}, #{config.pageSize} " if page?
    mysqlPool.query sql, (err, rows) ->
      cb err, rows

  get: (id, cb) ->
    return cb null, @getDefaults() if id == '$defaults'
    sql = """
          SELECT
          *
          FROM #{mysql.escapeId @table.name}
          WHERE #{mysql.escapeId @table.id} = #{mysql.escape id}
          """
    mysqlPool.query sql, (err, rows) ->
      return cb err if err
      return cb 'not found' unless rows and rows.length > 0
      cb err, rows[0]

  update: (id, item, cb) ->
    sql = """
          UPDATE #{mysql.escapeId @table.name}
          SET
          """
    fields = []
    for own field, type of @table.schema
      type = type.type if type?.type?
      fields.push {field, type} if item[field]?
    for {field, type}, i in fields
      value = item[field]
      if type == Date
        value = dateformat item[field], 'yyyy-mm-dd HH:MM:ss'
      sql += " #{mysql.escapeId field} = #{mysql.escape value} "
      sql += " , " if i < (fields.length - 1)
    sql += " WHERE #{mysql.escapeId @table.id} = #{mysql.escape id} "
    mysqlPool.query sql, (err, result) ->
      cb err, result

  delete: (id, cb) ->
    sql = """
          DELETE
          FROM #{mysql.escapeId @table.name}
          WHERE #{mysql.escapeId @table.id} = #{mysql.escape id}
          """
    mysqlPool.query sql, (err, result) ->
      cb err, result

  create: (item, cb) ->
    sql = """
          INSERT
          INTO #{mysql.escapeId @table.name}
          SET
          """
    fields = []
    fields.push {field: @table.id, type: String} if item[@table.id]
    for own field, type of @table.schema
      type = type.type if type?.type?
      fields.push {field, type} if item[field]?
    for {field, type}, i in fields
      value = item[field]
      if type == Date
        value = dateformat item[field], 'yyyy-mm-dd HH:MM:ss'
      sql += " #{mysql.escapeId field} = #{mysql.escape value} "
      sql += " , " if i < (fields.length - 1)
    mysqlPool.query sql, (err, result) ->
      cb err, result

  createTableSql: ->
    sql = "CREATE TABLE #{mysql.escapeId @table.name} (\n"
    _.each @table.schema, (option, field) =>
      option = if option?.type? then _.extend(option) else {type: option}
      option.isNotNull = true unless option.isNotNull?
      if option.type == String
        mysqlType = "VARCHAR(#{option.size || 45})"
      else if option.type == Number
        mysqlType = "BIGINT(#{option.size || 20})"
      else if option.type == Date
        mysqlType = "DATETIME"
      sql += "\t#{mysql.escapeId field} #{mysqlType} #{if option.isNotNull then 'NOT NULL' else 'NULL'},\n"
    sql += "\t#{mysql.escapeId @table.id} BIGINT(20) NOT NULL AUTO_INCREMENT,\n"
    sql += "\tPRIMARY KEY (#{mysql.escapeId @table.id})\n"
    sql += ") ENGINE=InnoDB DEFAULT CHARSET=utf8;\n"

  getDefaults: ->
    return {} unless @table.defaults
    _.mapObject @table.defaults, (val, key) ->
      if (typeof val) == 'function'
        val()
      else
        val

module.exports = BaseModel
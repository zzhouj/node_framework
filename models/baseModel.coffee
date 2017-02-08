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
    fields = @getFields?(options)
    leftJoin = @getLeftJoin?(options)
    leftJoinFields = @getLeftJoinFields?(options)
    leftJoinFields = " ,#{leftJoinFields} " if leftJoinFields
    unless sql
      sql = """
            SELECT
            #{fields || 't1.*'}
            #{leftJoinFields || ''}
            FROM #{mysql.escapeId @table.name} t1
            #{leftJoin || ''}

            """
    whereSql = @getWhereSql?(options)
    sql += " WHERE #{whereSql} " if whereSql
    if @table.orderBy
      sql += " ORDER BY #{@table.orderBy} "
    else
      sql += " ORDER BY t1.#{mysql.escapeId @table.id} DESC "
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
    items = if _.isArray item then item else [item]
    return cb 'no rows to insert' unless item and items and items.length > 0
    item = items[0]
    fields = []
    fields.push {field: @table.id, type: String} if item[@table.id]
    for own field, type of @table.schema
      type = type.type if type?.type?
      fields.push {field, type} if item[field]?
    fieldList = ("#{mysql.escapeId field}" for {field, type} in fields).join ', '
    sql = """
          INSERT IGNORE
          INTO #{mysql.escapeId @table.name}
          (#{fieldList})
          """
    valueList = _.map items, (item) ->
      values = _.map fields, (field) ->
        {field, type} = field
        if type == Date
          date = item[field]
          if typeof date == 'string' and date.indexOf('T') < 0
            "DATE(#{mysql.escape date})"
          else
            mysql.escape dateformat date, 'yyyy-mm-dd HH:MM:ss'
        else
          mysql.escape item[field]
      "(#{values.join ', '})"
    sql += " VALUES #{valueList.join ', '} "
    mysqlPool.query sql, (err, result) ->
      cb err, result

  createTableSql: ->
    sql = "CREATE TABLE #{mysql.escapeId @table.name} (\n"
    indexKeys = []
    uniqueKeys = []
    _.each @table.schema, (option, field) =>
      option = if option?.type? then _.extend(option) else {type: option}
      option.isNotNull = true unless option.isNotNull?
      indexKeys.push {field, desc: option.index < 0} if option.index
      uniqueKeys.push {field, desc: option.unique < 0} if option.unique
      if option.type == String
        mysqlType = "VARCHAR(#{option.size || 45})"
      else if option.type == Number
        mysqlType = "BIGINT(#{option.size || 20})"
      else if option.type == Date
        mysqlType = "DATETIME"
      else if (typeof option.type) == "string"
        mysqlType = option.type
      sql += "\t#{mysql.escapeId field} #{mysqlType} #{if option.isNotNull then 'NOT NULL' else 'NULL'},\n"
    sql += "\t#{mysql.escapeId @table.id} BIGINT(20) NOT NULL AUTO_INCREMENT,\n"
    sql += "\tPRIMARY KEY (#{mysql.escapeId @table.id})\n"
    for key in indexKeys
      sql += "\t, KEY #{mysql.escapeId key.field + '_index'} (#{mysql.escapeId key.field}#{if key.desc then ' DESC' else ''})\n"
    for key in uniqueKeys
      sql += "\t, UNIQUE KEY #{mysql.escapeId key.field + '_unique'} (#{mysql.escapeId key.field}#{if key.desc then ' DESC' else ''})\n"
    if @table.indexes
      for index in @table.indexes
        keys = _.keys index.keys
        KEYWORDS = (if index.unique then 'UNIQUE KEY' else 'KEY')
        name = keys.join('_') + (if index.unique then '_unique' else '_index')
        statement = ("#{mysql.escapeId key}#{if index.keys[key] < 0 then ' DESC' else ''}" for key in keys).join ', '
        sql += "\t, #{KEYWORDS} #{mysql.escapeId name} (#{statement})\n"
    autoIncrement = if @table.autoIncrement then "AUTO_INCREMENT=#{@table.autoIncrement} " else ''
    sql += ") ENGINE=InnoDB #{autoIncrement}DEFAULT CHARSET=utf8;\n"

  getDefaults: ->
    return {} unless @table.defaults
    _.mapObject @table.defaults, (val, key) ->
      if (typeof val) == 'function'
        val()
      else
        val

module.exports = BaseModel
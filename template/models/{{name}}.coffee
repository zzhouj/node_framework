BaseModel = require './baseModel'
mysql = require 'mysql'

class Model extends BaseModel
  getWhereSql: (options) ->
    {name} = options
    whereSql = " 1=1 "
    whereSql += " AND name LIKE #{mysql.escape "%#{name}%"} " if name
    whereSql

module.exports = new Model
  name: '{{name}}'
  id: 'id'
#  orderBy: 'name'
  schema:
    name:
      type: String # String | Number | Date
      size: 45 # default: varchar(45) | bigint(20)
    createTime: Date
    updateTime: Date
  labels:
    $model: '{{label}}'
    name: '名称'
    createTime: '创建时间'
    updateTime: '更新时间'

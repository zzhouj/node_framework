BaseModel = require './baseModel'

module.exports = new BaseModel
  name: '{{name}}'
  id: 'id'
#  orderBy: 'name'
  schema:
    name:
      type: String # String | Number | Date
      size: 45 # default: varchar(45) | bigint(20)
    create: Date
  labels:
    $model: '{{label}}'
    name: '名称'

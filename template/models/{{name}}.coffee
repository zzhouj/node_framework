BaseModel = require './baseModel'

module.exports = new BaseModel
  name: '{{name}}'
  id: 'id'
  orderBy: 'name'
  schema:
    name:
      type: String
      size: 45 # default: varchar(45) | bigint(20)
    create: Date
    flag: Number
BaseModel = require './baseModel'

module.exports = new BaseModel
  name: '{{name}}'
  id: 'id'
  orderBy: 'name'
  schema:
    name:
      type: String
    create: Date
    flag: Number
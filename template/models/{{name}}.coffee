BaseModel = require './baseModel'

module.exports = new BaseModel
  name: '{{name}}'
  id: 'id'
  orderBy: 'name'
  schema:
    name: String
  schemaOptions:
    name:
      size: 45

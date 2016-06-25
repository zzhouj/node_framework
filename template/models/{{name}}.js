// Generated by CoffeeScript 1.7.1
(function() {
  var BaseModel;

  BaseModel = require('./baseModel');

  module.exports = new BaseModel({
    name: '{{name}}',
    id: 'id',
    orderBy: 'name',
    schema: {
      name: String
    },
    schemaOptions: {
      name: {
        size: 45
      }
    }
  });

}).call(this);

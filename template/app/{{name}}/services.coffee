services = angular.module 'services', ['ngResource']

services.factory 'Model', ['$resource', ($resource) ->
  $resource '/rest/{{name}}/:id'
]

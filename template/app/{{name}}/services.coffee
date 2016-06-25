services = angular.module 'services', ['ngResource']

services.factory 'Model', ($resource) ->
  $resource '/rest/{{name}}/:id', null,
    update: {method: 'PUT'}
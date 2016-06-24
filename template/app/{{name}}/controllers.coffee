controllers = angular.module 'controllers', ['services', 'ui.bootstrap']

controllers.controller 'ListController', ($scope, Model) ->
  $scope.criteria = {}

controllers.controller 'EditController', ($scope, Model, $routeParams) ->
  {id} = $routeParams

controllers.controller 'NewController', ($scope, Model) ->

controllers = angular.module 'controllers', ['services', 'ui.bootstrap']

controllers.controller 'ListController', ['$scope', 'Model', ($scope, Model) ->
  $scope.criteria = {}
  query = ->
    $scope.collection = Model.query {}
  query()
]

controllers.controller 'EditController', ['$scope', 'Model', '$routeParams', ($scope, Model, $routeParams) ->
  {id} = $routeParams
]

controllers.controller 'NewController', ['$scope', 'Model', ($scope, Model) ->
]
app = angular.module 'app', ['ngRoute', 'controllers']

app.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.when '/',
    controller: 'ListController'
    templateUrl: '/app/{{name}}/tpl/list.tpl.html'
]
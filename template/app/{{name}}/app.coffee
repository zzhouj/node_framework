app = angular.module 'app', ['ngRoute', 'controllers']

app.config ($routeProvider) ->
  $routeProvider.when '/',
    controller: 'ListController'
    templateUrl: '/app/{{name}}/tpl/list.tpl.html'
  $routeProvider.when '/edit/:id',
    controller: 'EditController'
    templateUrl: '/app/{{name}}/tpl/edit.tpl.html'
  $routeProvider.when '/new',
    controller: 'NewController'
    templateUrl: '/app/{{name}}/tpl/edit.tpl.html'

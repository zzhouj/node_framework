// Generated by CoffeeScript 1.7.1
(function() {
  var controllers;

  controllers = angular.module('controllers', ['services', 'ui.bootstrap']);

  controllers.controller('ListController', [
    '$scope', 'Model', function($scope, Model) {
      return $scope.criteria = {};
    }
  ]);

  controllers.controller('EditController', [
    '$scope', 'Model', '$routeParams', function($scope, Model, $routeParams) {
      var id;
      return id = $routeParams.id, $routeParams;
    }
  ]);

  controllers.controller('NewController', ['$scope', 'Model', function($scope, Model) {}]);

}).call(this);

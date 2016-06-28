// Generated by CoffeeScript 1.7.1
(function() {
  var controllers;

  controllers = angular.module('controllers', ['services', 'ui.bootstrap']);

  controllers.controller('ListController', [
    '$scope', '$rootScope', '$modal', 'Model', function($scope, $rootScope, $modal, Model) {
      var query;
      $scope.criteria = {
        page: 0
      };
      query = function() {
        return $scope.collection = Model.query($scope.criteria);
      };
      query();
      $scope.query = function() {
        $scope.criteria.page = 0;
        return query();
      };
      $scope.prevPage = function() {
        if ($scope.criteria.page > 0) {
          $scope.criteria.page -= 1;
          return query();
        }
      };
      $scope.nextPage = function() {
        $scope.criteria.page += 1;
        return query();
      };
      $scope["new"] = function() {
        var modalInstance;
        modalInstance = $modal.open({
          controller: 'EditController',
          templateUrl: '/app/{{name}}/tpl/edit.tpl.html',
          scope: _.extend($rootScope.$new(), {
            isNew: true,
            item: new Model()
          })
        });
        return modalInstance.result.then(function() {
          return query();
        });
      };
      $scope.edit = function(item) {
        var id, modalInstance;
        id = item.id;
        modalInstance = $modal.open({
          controller: 'EditController',
          templateUrl: '/app/{{name}}/tpl/edit.tpl.html',
          scope: _.extend($rootScope.$new(), {
            item: {
              id: id
            }
          })
        });
        return modalInstance.result.then(function() {
          return query();
        });
      };
      return $scope["delete"] = function(item) {
        var id, name;
        id = item.id;
        if (name = prompt("确定删除【" + item.name + "】吗（ID：" + id + "）？\n\n请输入" + item.name + "确定删除：")) {
          if (name === item.name) {
            return typeof item.$delete === "function" ? item.$delete({
              id: id
            }, function() {
              alert('删除成功');
              return query();
            }, function(res) {
              return alert("Error " + res.status + ": " + (JSON.stringify(res.data)));
            }) : void 0;
          }
        }
      };
    }
  ]);

  controllers.controller('EditController', [
    '$scope', '$modalInstance', 'Model', function($scope, $modalInstance, Model) {
      $scope.item = Model.get({
        id: $scope.item.id || '$defaults'
      });
      $scope.save = function() {
        var action, _base;
        action = $scope.isNew ? '$save' : '$update';
        if (!$scope.item.createTime) {
          $scope.item.createTime = new Date();
        }
        $scope.item.updateTime = new Date();
        return typeof (_base = $scope.item)[action] === "function" ? _base[action]({
          id: $scope.item.id
        }, function() {
          alert('保存成功');
          return $modalInstance.close('ok');
        }, function(res) {
          return $scope.err = "Error " + res.status + ": " + (JSON.stringify(res.data));
        }) : void 0;
      };
      return $scope.cancel = function() {
        return $modalInstance.dismiss('cancel');
      };
    }
  ]);

}).call(this);

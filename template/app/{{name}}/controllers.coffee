controllers = angular.module 'controllers', ['services', 'ui.bootstrap']

controllers.controller 'ListController', ['$scope', '$rootScope', '$modal', 'Model',
  ($scope, $rootScope, $modal, Model) ->
    $scope.criteria = {page: 0}

    query = ->
      $scope.collection = Model.query $scope.criteria
    query()

    $scope.keypress = ($event) ->
      if $event.keyCode == 13
        $scope.query()

    $scope.query = ->
      $scope.criteria.page = 0
      query()

    $scope.prevPage = ->
      if $scope.criteria.page > 0
        $scope.criteria.page -= 1
        query()

    $scope.nextPage = ->
      $scope.criteria.page += 1
      query()

    $scope.new = ->
      modalInstance = $modal.open
        controller: 'EditController'
        templateUrl: '/app/{{name}}/tpl/edit.tpl.html'
        scope: _.extend $rootScope.$new(), {isNew: true, item: new Model()}
      modalInstance.result.then ->
        query()

    $scope.edit = (item) ->
      {id} = item
      modalInstance = $modal.open
        controller: 'EditController'
        templateUrl: '/app/{{name}}/tpl/edit.tpl.html'
        scope: _.extend $rootScope.$new(), {item: {id}}
      modalInstance.result.then ->
        query()

    $scope.delete = (item) ->
      {id} = item
      if name = prompt "确定删除【#{item.name}】吗（ID：#{id}）？\n\n请输入#{item.name}确定删除："
        if name == item.name
          item.$delete? {id}, ->
            alert '删除成功'
            query()
          , (res)->
            alert "Error #{res.status}: #{JSON.stringify res.data}"
]

controllers.controller 'EditController', ['$scope', '$modalInstance', 'Model', 'transform',
  ($scope, $modalInstance, Model, transform) ->
    $scope.item = Model.get {id: $scope.item.id || '$defaults'}, ->
      transform?.onLoad? $scope.item
    $scope.save = ->
      transform?.onSave? $scope.item
      $scope.item.$save {id: $scope.item.id}, ->
        alert '保存成功'
        $modalInstance.close('ok')
      , (res)->
        $scope.err = "Error #{res.status}: #{JSON.stringify res.data}"

    $scope.cancel = ->
      $modalInstance.dismiss('cancel')
]

controllers.factory 'transform', ->
  onLoad: (item) ->

  onSave: (item) ->
    item.createTime = new Date() unless item.createTime
    item.updateTime = new Date()

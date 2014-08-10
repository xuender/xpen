###
login.coffee
Copyright (C) 2014 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
LoginCtrl = ($scope, $modalInstance, user, init)->
  ### 登录控制 ###
  $scope.old = false
  $scope.user = user
  $scope.init = init
  $scope.ok = (valid)->
    $scope.old = true
    if valid
      $modalInstance.close($scope.user)
  $scope.cancel = ->
    $modalInstance.dismiss('cancel')

LoginCtrl.$inject = ['$scope', '$modalInstance', 'user', 'init']

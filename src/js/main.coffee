###
main.coffee
Copyright (C) 2014 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
angular.module('xpen', [
  'ui.bootstrap'
  'ngSocket'
  'LocalStorageModule'
])
XpenCtrl = ($scope, $modal, ngSocket, lss)->
  ### 主控制器 ###
  $scope.msg = ''
  ws = ngSocket("ws://#{location.origin.split('//')[1]}/ws")
  ws.onMessage((msg)->
    console.log('接收倒消息:', msg)
  )
  $scope.init = ->
    ### 初始化 ###
    user = lss.get('user')
    if user == null
      console.info('未知的用户')
    else
      $scope.user = user
      console.debug('user:', user)
  $scope.send = ->
    ### 发送消息 ###
    ws.send(
      msg:$scope.msg
    )
  $scope.init()

XpenCtrl.$inject = ['$scope', '$modal', 'ngSocket', 'localStorageService']

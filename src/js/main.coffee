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
  $scope.isLogin = false
  $scope.init = ->
    ### 初始化 ###
    user = lss.get('user')
    if user == null
      $scope.user =
        email: ''
        nick: ''
    else
      $scope.user = user
      $scope.isLogin = true
  $scope.logout = ->
    ### 登出 ###
    $scope.user =
      email: ''
      nick: ''
    lss.remove('user')
    $scope.isLogin = false
  $scope.login = ->
    ### 登录 ###
    lss.set('user', $scope.user)
    $scope.isLogin = true
  $scope.send = ->
    ### 发送消息 ###
    ws.send(
      msg:$scope.msg
    )
  $scope.init()
  console.info $scope.isLogin

XpenCtrl.$inject = ['$scope', '$modal', 'ngSocket', 'localStorageService']

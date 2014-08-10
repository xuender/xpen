###
main.coffee
Copyright (C) 2014 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
angular.module('xpen', [
  'ui.bootstrap'
  'ngSocket'
  'LocalStorageModule'
  'hotkey'
])
XpenCtrl = ($scope, $modal, ngSocket, lss)->
  ### 主控制器 ###
  $scope.msg = ''
  ws = ngSocket("ws://#{location.origin.split('//')[1]}/ws")
  $scope.users = []
  $scope.messages = []
  $scope.showMessages = (messages)->
    ### 显示消息 ###
    console.info messages
    $scope.messages = $scope.messages.concat messages
  ws.onMessage((data)->
    msg = JSON.parse(data.data)
    $('.well')[0].scrollTop = $('.well')[0].scrollHeight
    switch msg.Command
      when 'users' then $scope.users = msg.Users
      when 'chat' then $scope.showMessages(msg.Messages)
  )
  $scope.isLogin = false
  $scope.init = ->
    ### 初始化 ###
    user = lss.get('user')
    if user == null
      $scope.user =
        email: ''
        nick: ''
      $scope.showLogin(true)
    else
      $scope.user = user
      $scope.wsLogin()
      ws.send(
        Command: 'init'
      )
  $scope.showLogin = (init = false)->
    ### 显示登录窗口 ###
    i = $modal.open(
      templateUrl: 'login.html'
      controller: LoginCtrl
      backdrop: 'static'
      keyboard: false
      size: 'sm'
      resolve:
        user: ->
          angular.copy($scope.user)
        init: ->
          init
    )
    i.result.then((user)->
      $scope.user = angular.copy(user)
      lss.set('user', $scope.user)
      $scope.wsLogin()
      if init
        ws.send(
          Command: 'init'
        )

    ,->
      console.info '取消'
    )
  $scope.edit = ->
    ### 编辑用户 ###
    $scope.showLogin()

  $scope.logout = ->
    ### 登出 ###
    $scope.user =
      email: ''
      nick: ''
    lss.remove('user')
    ws.send(
      Command: 'logout'
    )
    $scope.messages = []
    $scope.showLogin(true)
  $scope.send = ->
    ### 发送消息 ###
    if $scope.msg
      ws.send(
        Command: 'chat'
        Messages: [
          {
            Content: $scope.msg
          }
        ]
      )
      $scope.msg = ''
  $scope.wsLogin = ->
    ### 远程用户登陆 ###
    console.info('login', $scope.user)
    ws.send(
      Command: 'login'
      Source: $scope.user
    )
  $scope.init()
XpenCtrl.$inject = ['$scope', '$modal', 'ngSocket', 'localStorageService']

chatResized = ->
  ### 聊天窗口缩放 ###
  chat_height = $.getDocHeight() - 130
  $('.well').css('height',chat_height)
$ ->
  $.getDocHeight = ->
    Math.max($(document).height(), $(window).height(), document.documentElement.clientHeight)
  chatResized()
  window.onresize = chatResized

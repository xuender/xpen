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
    else
      $scope.user = user
      $scope.isLogin = true
      $scope.wsLogin()
    ws.send(
      Command: 'init'
    )
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
    $scope.wsLogin()
  $scope.send = ->
    ### 发送消息 ###
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

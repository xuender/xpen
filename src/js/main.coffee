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
  'angularFileUpload'
])
UploadCtrl = ($scope, $upload)->
  $scope.progress = 0
  $scope.abort = (index)->
    ### 停止 ###
    $scope.upload[index].abort()
    $scope.upload[index] = null

  $scope.hasUploader = (index)->
    $scope.upload[index] != null

  $scope.start = (i)->
    $scope.progress[i] = 0
    $scope.errorMsg = null
    $scope.upload[i] = $upload.upload(
      url: '/upload'
      method: 'POST'
      #headers: {'header-key': 'header-value'},
      #withCredentials: true,
      #data: {myObj: $scope.myModelObj},
      file: $scope.selectedFiles[i]
      #fileName: 'doc.jpg' or ['1.jpg', '2.jpg', ...] // to modify the name of the file(s)
      # customize file formData name ('Content-Desposition'), server side file variable name. 
      #fileFormDataName: myFile, //or a list of names for multiple files (html5). Default is 'file' 
      # customize how data is added to formData. See #40#issuecomment-28612000 for sample code
      #formDataAppender: function(formData, key, val){}
    ).progress((evt)->
      console.log('percent: ' + parseInt(100.0 * evt.loaded / evt.total))
      $scope.progress[i] = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
    ).success((data, status, headers, config)->
      # file is uploaded successfully
      console.log(data)
    )

  $scope.onFileSelect = ($files)->
    $scope.selectedFiles = []
    $scope.progress = []
    if $scope.upload && $scope.upload.length > 0
      for i in [0...$scope.upload.length]
        if $scope.upload[i] != null
          $scope.upload[i].abort()
    $scope.upload = []
    $scope.uploadResult = []
    $scope.selectedFiles = $files
    for i in [0...$files.length]
      $scope.start i
UploadCtrl.$inject = [
  '$scope'
  '$upload'
]

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
XpenCtrl.$inject = [
  '$scope'
  '$modal'
  'ngSocket'
  'localStorageService'
]

chatResized = ->
  ### 聊天窗口缩放 ###
  chat_height = $.getDocHeight() - 130
  $('.well').css('height',chat_height)
$ ->
  $.getDocHeight = ->
    Math.max($(document).height(), $(window).height(), document.documentElement.clientHeight)
  chatResized()
  window.onresize = chatResized

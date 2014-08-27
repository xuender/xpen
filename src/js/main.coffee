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
  'textAngular'
]).config(['$provide', ($provide)->
  $provide.decorator('taOptions', ['taRegisterTool', '$delegate', (taRegisterTool, taOptions)->
    taRegisterTool('send',
      iconclass: "fa fa-send"
      buttontext: '发送'
      action: ->
        angular.element('body').scope().send()
    )
    taOptions.toolbar[1].push('send')
    taOptions
  ])
])

XpenCtrl = ($scope, $modal, ngSocket, lss, $upload, $sce)->
  ### 主控制器 ###
  $scope.pointer = ''
  ws = ngSocket("ws://#{location.origin.split('//')[1]}/ws")
  $scope.users = []
  $scope.messages = []
  $scope.progress = []
  $scope.tabs = [{
    name: '聊天室'
    messages: []
    msg: ''
    to: ''
    active: true
  }]
  $scope.showMessages = (messages, to)->
    ### 显示消息 ###
    if messages
      for i in [0...messages.length]
        messages[i].Content = $sce.trustAsHtml(messages[i].Content)
      console.info messages
      console.info to
    for t in $scope.tabs
      if to == t.to
          t.messages = t.messages.concat messages
  ws.onMessage((data)->
    dmsg = JSON.parse(data.data)
    switch dmsg.Command
      when 'users'
        $scope.pointer = dmsg.Pointer
        $scope.users = dmsg.Users
      when 'chat' then $scope.showMessages(dmsg.Messages, dmsg.To)
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
    #console.debug $scope.tabs
    for t in $scope.tabs
      if t.active
        #console.info $sce.trustAsHtml(t.msg)
        #console.info t.msg
        if t.msg
          ws.send(
            Command: 'chat'
            To: t.to
            Messages: [
              {
                Content: t.msg
              }
            ]
          )
          t.msg = ''
  $scope.wsLogin = ->
    ### 远程用户登陆 ###
    console.info('login', $scope.user)
    ws.send(
      Command: 'login'
      Source: $scope.user
    )
  $scope.closeChat = ->
    console.info 'xxx'
  $scope.init()
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
      data:
        pointer: $scope.pointer
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
XpenCtrl.$inject = [
  '$scope'
  '$modal'
  'ngSocket'
  'localStorageService'
  '$upload'
  '$sce'
]

chatResized = ->
  ### 聊天窗口缩放 ###
  chat_height = $.getDocHeight() - 330
  $('.well').css('height',chat_height)
$ ->
  $("table").resize((e)->
    div = $(e.target).parent()[0]
    div.scrollTop = div.scrollHeight
  )
  $.getDocHeight = ->
    Math.max($(document).height(), $(window).height(), document.documentElement.clientHeight)
  chatResized()
  window.onresize = chatResized

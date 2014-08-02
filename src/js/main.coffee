###
main.coffee
Copyright (C) 2014 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
angular.module('xpen', [
  'ui.bootstrap'
  'ngSocket'
])
XpenCtrl = ($scope, $modal, ngSocket)->
  $scope.msg = ''
  ws = ngSocket("ws://#{location.origin.split('//')[1]}/ws")
  ws.onMessage((msg)->
    console.log('message received', msg)
  )
  $scope.send = ->
    ws.send(
      msg:$scope.msg
    )
XpenCtrl.$inject = ['$scope', '$modal', 'ngSocket']

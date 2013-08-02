@app.controller 'TestDataController', ($scope, $timeout) ->
  $scope.cpu = []

  $scope.updateData = ->
    $scope.cpu.push { time: new Date(), usage: Math.floor(Math.random() * 101) }
    $scope.cpu.shift() if $scope.cpu.length > 10
    $timeout $scope.updateData, 1000

  $timeout $scope.updateData, 1000

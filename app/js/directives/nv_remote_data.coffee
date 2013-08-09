@app.directive 'nvRemoteData', ($http, $timeout) ->
  restrict: 'A'

  link: (scope, element, attrs) ->
    scope[attrs.nvRemoteData] = []

    fetchData = ->
      $http.get(attrs.url).success (data) ->
        scope[attrs.nvRemoteData] = data
        $timeout fetchData, attrs.interval if attrs.interval

    fetchData()


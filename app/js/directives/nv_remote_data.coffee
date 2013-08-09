@app.directive 'nvRemoteData', ($http) ->
  restrict: 'A'

  link: (scope, element, attrs) ->
    scope[attrs.nvRemoteData] = []

    $http.get(attrs.url).success (data) ->
      scope[attrs.nvRemoteData] = data

@app.directive 'nvChart', ->
  restrict: 'E'
  replace: true
  scope: { width: '@', height: '@', data: '=model'}

  template: '''
    <svg>
      <g>
        <line class="axis"
              ng-attr-x1="{{ xMargin }}"
              ng-attr-y1="{{ height - yMargin }}"
              ng-attr-x2="{{ width }}"
              ng-attr-y2="{{ height - yMargin }}">
        </line>
        <line class="axis"
              ng-attr-x1="{{ xMargin }}"
              ng-attr-y1="0"
              ng-attr-x2="{{ xMargin }}"
              ng-attr-y2="{{ height - yMargin }}">
        </line>
        <path class="line"
              fill="none"
              ng-attr-d="{{ line(data) }}">
        </path>
        <circle class="point"
                ng-repeat="d in data"
                ng-attr-cx="{{ x(d) }}"
                ng-attr-cy="{{ y(d) }}"
                r=5>
        </circle>
        <line class="tick"
              ng-repeat="d in data"
              ng-attr-x1="{{ x(d) }}"
              ng-attr-y1="{{ height - yMargin }}"
              ng-attr-x2="{{ x(d) }}"
              ng-attr-y2="{{ height - yMargin + 4 }}">
        </line>
        <text class="label"
              ng-repeat="d in data"
              ng-attr-x="{{ x(d) }}"
              ng-attr-y="{{ height }}"
              text-anchor="middle">
          {{ xLabel(d) }}
        </text>
        <line class="tick"
              ng-repeat="val in yIntervals"
              ng-attr-x1="{{ xMargin }}"
              ng-attr-y1="{{ y(val) }}"
              ng-attr-x2="{{ xMargin - 4 }}"
              ng-attr-y2="{{ y(val) }}">
        </line>
        <text class="label"
              ng-repeat="val in yIntervals"
              ng-attr-x="{{ xMargin - 8 }}"
              ng-attr-y="{{ y(val) }}"
              dy=4
              text-anchor="end">
          {{ yLabel(val) }}
        </text>
      </g>
    </svg>
  '''

  controller: ($scope, $attrs, $filter) ->
    $scope.xMargin = 40
    $scope.yMargin = 20

    $scope.$watch(
      'data'
      (data) ->
        $scope.xScale = d3.time.scale()
          .domain(d3.extent($scope.data, (d) -> d[$attrs.axis]))
          .range([$scope.xMargin, $scope.width - $scope.xMargin])
        d3.selectAll('.point').data(data).transition('cx', (d) -> $scope.x(d))

        $scope.yScale = d3.scale.linear()
          .domain(d3.extent($scope.data, (d) -> d[$attrs.yAxis]))
          .range([$scope.height - $scope.yMargin, $scope.yMargin])

        [min, max] = d3.extent($scope.data, (d) -> d[$attrs.yAxis])
        $scope.yIntervals = d3.range(min, max, ((max - min) / 10)).map (val) ->
          obj = {}
          obj[$attrs.yAxis] = Math.floor(val)
          obj
      true
    )

    $scope.x = (d) ->
      $scope.xScale(d[$attrs.axis])

    $scope.xLabel = (d) ->
      val = d[$attrs.axis]
      if angular.isDate(val)
        $filter('date')(val, 'H:mm:ss')
      else
        val.toString()

    $scope.y = (d) ->
      $scope.yScale(d[$attrs.yAxis])

    $scope.yLabel = (d) ->
      val = d[$attrs.yAxis]
      val.toString()

    $scope.line = (data) ->
      return "M0 0" unless data.length
      line = d3.svg.line()
        .x($scope.x)
        .y($scope.y)
        .interpolate('linear')
      line(data)

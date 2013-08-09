@app.directive 'nvChart', (D3) ->
  restrict: 'E'
  replace: true
  scope: { data: '=model'}

  link: (scope, element, attrs) ->
    chart = D3.timeSeriesChart()
      .width(attrs.width)
      .height(attrs.height)
      .x((d) -> new Date(d[attrs.axis]))
      .y((d) -> +d[attrs.yAxis])

    scope.$watch(
      'data'
      (data) ->
        if data?.length > 1
          d3.select(element[0])
            .datum(data)
            .call(chart)
      true
    )

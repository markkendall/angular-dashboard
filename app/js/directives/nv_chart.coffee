@app.directive 'nvChart', ->
  restrict: 'E'
  replace: true

  template: '''
    <svg>
    </svg>
  '''

  link: (scope, element, attrs) ->
    svg = d3.select(element[0]).append('g')
    xMargin = 40
    yMargin = 20

    scope.$watch(
      attrs.model
      (data) ->
        xVals = data.map (d) -> d[attrs.axis]
        x = d3.time.scale().domain(d3.extent(xVals)).range([xMargin, attrs.width - xMargin])
        y = d3.scale.linear().domain([0, 100]).range([attrs.height - yMargin, yMargin])

        ## Data Points
        points = svg.selectAll('circle').data(data, (d) -> d[attrs.axis])
        points.enter().append('circle')
          .attr('r', '5')
          .style('opacity', 0)
        points
          .attr('cy', (d) -> y(d[attrs.yAxis]))
          .transition().attr('cx', (d) -> x(d[attrs.axis]))
          .transition().style('opacity', 1)
        points.exit().remove()

        ## X Axis
        xAxis = svg.selectAll(".xAxis").data(['x'])
        xAxis.enter().append("svg:line")
          .attr("class", "xAxis")
          .attr("y1", y(0))
          .attr("y2", y(0))
          .attr("x1", xMargin)
          .attr("x2", attrs.width)
          .attr("stroke", "black")

        ## X Axis Ticks
        xTicks = svg.selectAll(".xTick").data(data, (d) -> d[attrs.axis])
        xTicks.enter().append("svg:line")
          .attr("class", "xTick")
          .attr("y1", y(0) + 4)
          .attr("y2", y(0))
          .attr("stroke", "black")
          .style('opacity', 0)
        xTicks
          .transition().attr("x1", (d) -> x(d[attrs.axis])).attr("x2", (d) -> x(d[attrs.axis]))
          .transition().style('opacity', 1)
        xTicks.exit().remove()

        ## X Axis Labels
        xLabels = svg.selectAll(".xLabel").data(data, (d) -> d[attrs.axis])
        xLabels.enter().append("svg:text")
          .attr("class", "xLabel")
          .text((d) ->
            time = d[attrs.axis]
            "#{time.getHours()}:#{time.getMinutes()}:#{time.getSeconds()}"
          )
          .attr("y", attrs.height)
          .attr("text-anchor", "middle")
          .style('opacity', 0)
        xLabels
          .transition().attr("x", (d) -> x(d[attrs.axis]))
          .transition().style('opacity', 1)
        xLabels.exit().remove()

        ## Y Axis
        yAxis = svg.selectAll(".yAxis").data(['y'])
        yAxis.enter().append("svg:line")
          .attr("class", "yAxis")
          .attr("x1", xMargin)
          .attr("x2", xMargin)
          .attr("y1", 0)
          .attr("y2", attrs.height - yMargin)
          .attr("stroke", "black")

        ## Y Axis Ticks
        yTicks = svg.selectAll(".yTick").data(y.ticks(10))
        yTicks.enter().append("svg:line")
          .attr("class", "yTick")
          .attr("x1", xMargin - 4)
          .attr("x2", xMargin)
          .attr("stroke", "black")
        yTicks
          .attr("y1", (d) -> y(d))
          .attr("y2", (d) -> y(d))

        ## Y Axis Labels
        yLabels = svg.selectAll(".yLabel").data(y.ticks(10))
        yLabels.enter().append("svg:text")
          .attr("class", "yLabel")
          .text(String)
          .attr("x", 0)
          .attr("text-anchor", "right")
          .attr("dy", 4)
        yLabels
          .attr("y", (d) -> y(d))

      true
    )

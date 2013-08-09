@app.factory 'D3', ->
  timeSeriesChart: ->
    margin = {top: 20, right: 20, bottom: 20, left: 60}
    width = 760
    height = 120
    xValue = (d) -> d[0]
    yValue = (d) -> d[1]
    xScale = d3.time.scale()
    yScale = d3.scale.linear()
    xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(6, 0)
    yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(6, 0)

    # The x-accessor for the path generator; xScale âˆ˜ xValue.
    X = (d) ->
      xScale(d[0])

    # The y-accessor for the path generator; yScale âˆ˜ yValue.
    Y = (d) ->
      yScale(d[1])

    area = d3.svg.area().x(X).y1(Y)
    line = d3.svg.line().x(X).y(Y)

    savedPoint = null

    chart = (selection) ->
      selection.each (data) ->
        # Convert data to standard representation greedily;
        # this is needed for nondeterministic accessors.
        data = data.map (d, i) ->
          [xValue.call(data, d, i), yValue.call(data, d, i)]

        # Select the svg element, if it exists.
        svg = d3.select(@).selectAll("svg").data([data])

        # Otherwise, create the skeletal chart.
        gEnter = svg.enter().append("svg").append("g")
        gEnter.append("clipPath")
          .attr("id", "content-clip")
          .append("rect")
          .attr("width", width - margin.left - margin.right)
          .attr("height", height - margin.top - margin.bottom)
        gContent = gEnter.append("g")
          .attr("class", "content")
          .attr("clip-path", "url(#content-clip)")
        gContent.append("path").attr("class", "area")
        gContent.append("path").attr("class", "line")
        gEnter.append("g").attr("class", "x axis")
          .attr("transform", "translate(0,#{height - margin.top - margin.bottom})")
        gEnter.append("g").attr("class", "y axis")

        # Update the outer dimensions.
        svg
          .attr("width", width)
          .attr("height", height)

        # Update the inner dimensions.
        g = svg.select("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

        # Update the y-scale.
        yScale
          .domain([0, d3.max(data, (d) -> d[1])])
          .range([height - margin.top - margin.bottom, 0])

        # Determine whether to animate the line
        animate = savedPoint && data[0] != savedPoint

        if animate
          # Restore the last saved point
          data.unshift(savedPoint)

        # Draw the line, with the new point off the right edge
        g.select(".area")
          .attr("d", area.y0(yScale.range()[0]))
          .attr("transform", null)
        g.select(".line")
          .attr("d", line)
          .attr("transform", null)

        if animate
          # Remove the first point
          data.shift()

        # Update the x scale
        xScale
          .domain(d3.extent(data, (d) -> d[0]))
          .range([0, width - margin.left - margin.right])

        if animate
          # Slide the line left one point
          g.select(".area")
            .transition()
            .ease("linear")
            .attr("transform", "translate(#{xScale(savedPoint[0])})")
          g.select(".line")
            .transition()
            .ease("linear")
            .attr("transform", "translate(#{xScale(savedPoint[0])})")
        else
          # Rescale the line
          g.select(".area")
            .attr("d", area.y0(yScale.range()[0]))
          g.select(".line")
            .attr("d", line)

        savedPoint = data[0]

        # Update the x-axis.
        g.select(".x.axis")
          .transition().ease("linear").call(xAxis)

        # Update the y-axis.
        g.select(".y.axis")
          .transition().ease("linear").call(yAxis)

    chart.margin = (_) ->
      return margin unless arguments.length
      margin = _
      return chart

    chart.width = (_) ->
      return width unless arguments.length
      width = _
      return chart

    chart.height = (_) ->
      return height unless arguments.length
      height = _
      return chart

    chart.x = (_) ->
      return xValue unless arguments.length
      xValue = _
      return chart

    chart.y = (_) ->
      return yValue unless arguments.length
      yValue = _
      return chart

    chart

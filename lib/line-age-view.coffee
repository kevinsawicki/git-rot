{View} = require 'atom'
d3 = require 'd3-browserify'

module.exports =
class LineAgeView extends View
  @content: ->
    @div class: 'line-age'

  initialize: (lines) ->
    width = 75
    height = 65

    now = Date.now()

    lines = lines.filter (line, index) ->
      line.commit isnt lines[index - 1]?.commit

    ages = lines.map ({age, number}) -> {number, age: now - age}

    x = d3.scale.linear().range([0, width])
    y = d3.scale.ordinal().rangeBands([0, height])

    x.domain([0, d3.max(ages, ({age}) -> age)])
    y.domain ages.map ({number}) -> number

    svg = d3.select(@[0]).append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")

    svg.selectAll('.line').data(ages)
      .enter()
        .append("rect")
        .attr("width", ({age}) -> x(age))
        .attr("y", ({number}) -> y(number))
        .attr("height", y.rangeBand())

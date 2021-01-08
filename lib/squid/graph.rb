require 'active_support'
require 'active_support/core_ext/string/inflections' # for singularize

require 'squid/axis'
require 'squid/axis_label'
require 'squid/gridline'
require 'squid/plotter'
require 'squid/point'
require 'squid/settings'

module Squid
  # @private
  class Graph
    extend Settings
    has_settings :baseline, :border, :chart, :colors, :every, :formats, :height
    has_settings :legend, :line_widths, :steps, :ticks, :type, :labels

    def initialize(document, data = {}, settings = {})
      @data, @settings = data, settings
      @plot = Plotter.new document, bottom: bottom
      @plot.paddings = {left: left.width, right: right.width} if @data.any?
    end

    def draw
      @plot.box(h: height, border: border) { draw_graph if @data.any? }
    end

  private

    def draw_graph
      draw_legend if legend
      draw_gridlines
      draw_axis_labels
      draw_charts if chart
      draw_categories if baseline
    end

    def draw_legend
      labels = @data.keys.reverse.map{|key| key.to_s}
      right = legend.is_a?(Hash) ? legend.fetch(:right, 0) : 0
      @plot.legend labels, right: right, colors: colors, height: legend_height
    end

    def draw_gridlines
      options = {height: grid_height, count: steps, skip_baseline: baseline}
      Gridline.for(**options).each do |line|
        @plot.horizontal_line line.y, line_width: 0.5, transparency: 0.25
      end
    end

    def draw_axis_labels
      @plot.axis_labels AxisLabel.for(left, align: :right, height: grid_height)
      @plot.axis_labels AxisLabel.for(right, align: :left, height: grid_height)
    end

    def draw_categories
      labels = @data.values.first.keys.map{|key| key.to_s}
      @plot.categories labels, every: every, ticks: ticks
      @plot.horizontal_line 0.0
    end

    def draw_charts
      draw_chart right, second_axis: true
      draw_chart left
    end

    def draw_chart(axis, second_axis: false)
      args = {minmax: axis.minmax, height: grid_height, stack: stack?}
      args[:labels] = items_of labels, skip_first_if: second_axis
      args[:formats] = items_of formats, skip_first_if: second_axis
      points = Point.for axis.data, **args
      options = {colors: colors, starting_at: (second_axis ? 1: 0)}
      case (second_axis ? :column : type)
        when :point then @plot.points points, options
        when :line, :two_axis then @plot.lines points, options.merge(line_widths: line_widths)
        when :column then @plot.columns points, options
        when :stack then @plot.stacks points, options
      end
    end

    def items_of(array, skip_first_if:)
      if skip_first_if
        array.empty? ? [] : array[1..-1]
      else
        array
      end
    end

    def left
      @left ||= axis first: 0, last: (two_axis? ? 1 : @data.size)
    end

    def right
      @right ||= axis first: 1, last: (two_axis? ? @data.size : 0)
    end

    def axis(first:, last:)
      series = @data.values[first, last].map(&:values)
      options = {steps: steps, stack: stack?, format: formats[first]}
      Axis.new(series, **options) {|label| @plot.width_of label}
    end

    def bottom
      baseline ? 20 : 0
    end

    def legend_height
      legend ? 15 : 0
    end

    def legend_bottom
      legend.is_a?(Hash) ? legend.fetch(:bottom, 15) : 15
    end

    def grid_height
      height - bottom - legend_height - legend_bottom
    end

    def stack?
      type == :stack
    end

    def two_axis?
      type == :two_axis
    end
  end
end

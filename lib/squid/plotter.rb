require 'active_support'
require 'active_support/core_ext/array/wrap' # for Array#wrap

module Squid
  # A Plotter wraps a Prawn::Document object in order to provide new methods
  # like `gridline` or `ticks` used by Squid::Graph to plot graph elements.
  class Plotter
    attr_accessor :paddings
    # @param [Prawn::Document] a PDF document to wrap in a Plotter instance.
    def initialize(pdf, bottom:)
      @pdf = pdf
      @bottom = bottom
    end

    # Draws a bounding box of the given height, rendering the block inside it.
    def box(x: 0, y: @pdf.cursor, w: @pdf.bounds.width, h:, border: false)
      @pdf.bounding_box [x, y], width: w, height: h do
        @pdf.stroke_bounds if border
        yield
      end
    end

    # Draws the graph legend with the given labels.
    # @param [Array<LegendItem>] The labels to write as part of the legend.
    def legend(labels, height:, right: 0, colors: [])
      left = @pdf.bounds.width/2
      box(x: left, y: @pdf.bounds.top, w: left, h: height) do
        x = @pdf.bounds.right - right
        options = {size: 7, height: @pdf.bounds.height, valign: :center}
        labels.each.with_index do |label, i|
          index = labels.size - 1 - i
          series_color = colors.fetch index, series_colors(index)
          color = Array.wrap(series_color).first
          x = legend_item label, x, color, options
        end
      end
    end

    def series_colors(index)
      default_colors = %w(2e578c 5d9648 e7a13d bc2d30 6f3d79 7d807f)
      default_colors.fetch(index % default_colors.size)
    end

    # Draws a horizontal line.
    def horizontal_line(y, options = {})
      with options do
        at = y + @bottom
        @pdf.stroke_horizontal_line left, @pdf.bounds.right - right, at: at
      end
    end

    def width_of(label)
      @pdf.width_of(label, size: 8).ceil
    end

    def axis_labels(labels)
      labels.each do |label|
        x = (label.align == :right) ? 0 : @pdf.bounds.right - label.width
        y = label.y + @bottom + text_options[:height] / 2
        options = text_options.merge width: label.width, at: [x, y]
        @pdf.text_box label.label, options.merge(align: label.align)
      end
    end

    def categories(labels, every:, ticks:)
      labels.each.with_index do |label, index|
        w = width / labels.count.to_f
        x = left + w * (index)
        padding = 2
        options = category_options.merge(width: every*w-2*padding, at: [x+padding-w*(every/2.0-0.5), @bottom])
        @pdf.text_box label, options if (index % every).zero?
        @pdf.stroke_vertical_line @bottom, @bottom - 2, at: x + w/2 if ticks
      end
    end

    def points(series, options = {})
      items(series, **options) do |point, w, i, padding|
        x, y = (point.index + 0.5)*w + left, point.y + @bottom
        @pdf.fill_circle [x, y], 5
      end
    end

    def lines(series, options = {})
      x, y = nil, nil
      line_widths = options.delete(:line_widths) { [] }
      items(series, **options) do |point, w, i, padding|
        prev_x, prev_y = x, y
        x, y = (point.index + 0.5)*w + left, point.y + @bottom
        line_width = line_widths.fetch i, 3
        with line_width: line_width, cap_style: :round do
          @pdf.line [prev_x, prev_y], [x,y] unless point.index.zero? || prev_y.nil? || prev_x > x
        end
      end
    end

    def stacks(series, options = {})
      items(series, **options.merge(fill: true)) do |point, w, i, padding|
        x, y = point.index*w + padding + left, point.y + @bottom
        @pdf.fill_rectangle [x, y], w - 2*padding, point.height
      end
    end

    def columns(series, options = {})
      items(series, **options.merge(fill: true, count: series.size)) do |point, w, i, padding|
        item_w = (w - 2 * padding)/ series.size
        x, y = point.index*w + padding + left + i*item_w, point.y + @bottom
        @pdf.fill_rectangle [x, y], item_w, point.height
      end
    end

  private

    def left
      @paddings[:left].zero? ? 0 : @paddings[:left] + 5
    end

    def right
      @paddings[:right].zero? ? 0 : @paddings[:right] + 5
    end

    def width
      @pdf.bounds.width - left - right
    end

    def category_options
      text_options.merge align: :center, leading: -3, disable_wrap_by_char: false
    end

    def text_options
      options = {}
      options[:height] = 20
      options[:size] = 8
      options[:valign] = :center
      options[:overflow] = :shrink_to_fit
      options
    end

    def items(series, colors: [], fill: false, count: 1, starting_at: 0, &block)
      series.reverse_each.with_index do |points, reverse_index|
        index = series.size - reverse_index - 1
        color_index = index + starting_at
        w = width / points.size.to_f
        series_color = colors.fetch color_index, series_colors(color_index)
        item_color = Array.wrap(series_color).cycle
        points.select(&:y).each do |point|
          item point, item_color.next, w, fill, index, count, &block
        end
      end
    end

    def item(point, color, w, fill, index, count)
      padding = w / 8

      with transparency: 0.95, fill_color: color, stroke_color: color do
        yield point, w, index, padding
      end

      with fill_color: (point.negative && fill ? 'ffffff' : color) do
        options = [{size: 10, styles: [:bold], text: point.label}]
        position = {align: :center, valign: :bottom, height: 20}
        position[:width] = (w - 2*padding) / count
        x = left + point.index*w + padding
        x += index * position[:width] if count > 1
        position[:at] = [x, point.y + @bottom + 24]
        @pdf.formatted_text_box options, position
      end if point.label
    end

    # Draws a single item of the legend, which includes the label and the
    # symbol with the matching color. Labels are written from right to left.
    # @param
    def legend_item(label, x, color, options)
      size, symbol_padding, entry_padding = 5, 3, 12
      x -= @pdf.width_of(label, size: 7).ceil
      @pdf.text_box label, options.merge(at: [x, @pdf.bounds.height])
      x -= (symbol_padding + size)
      with fill_color: color do
        @pdf.fill_rectangle [x, @pdf.bounds.height - size], size, size
      end
      x - entry_padding
    end

    # Convenience method to wrap a block by setting and unsetting a Prawn
    # property such as line_width.
    def with(new_values = {})
      transparency = new_values.delete(:transparency) { 1.0 }
      old_values = Hash[new_values.map{|k,_| [k,@pdf.public_send(k)]}]
      new_values.each{|k, new_value| @pdf.public_send "#{k}=", new_value }
      @pdf.transparent(transparency) do
        @pdf.stroke { yield }
      end
      old_values.each{|k, old_value| @pdf.public_send "#{k}=", old_value }
    end
  end
end

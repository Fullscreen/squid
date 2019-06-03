require 'squid/format'
require 'active_support/core_ext/enumerable' # for Array#sum

module Squid
  # @private
  class Axis
    include Format
    attr_reader :data

    def initialize(data, steps:, stack:, format:, &block)
      @data, @steps, @stack, @format = data, steps, stack, format
      @width_proc = block if block_given?
    end

    def minmax
      @minmax ||= [min, max].compact.map do |number|
        approximate number
      end
    end

    def labels
      min, max = minmax
      values = if min.nil? || max.nil? || @steps.zero?
        []
      else
        max.step(by: (min - max)/@steps.to_f, to: min)
      end
      @labels ||= values.map{|value| format_for value, @format}
    end

    def width
      @width ||= labels.map{|label| label_width label}.max || 0
    end

  private

    def label_width(label)
      @width_proc.call label if @width_proc
    end

    def min
      if @data.any? && values.first && values.first.any?
        [values.first.min, 0].min
      end
    end

    def max
      if @data.any? && values.last && values.last.any?
        return 0 if min < 0 && values.last.max <= 0
        closest_step_to values.last.max
      end
    end

    def closest_step_to(value)
      if @format == :integer
        ((value - min) / @steps + 1) * @steps + min
      else
        [value, @steps].max
      end
    end

    def values
      @values ||= if @stack
        @data.transpose.map{|a| a.compact.partition{|n| n < 0}.map(&:sum)}.transpose
      else
        [@data.flatten.compact]
      end
    end

    def approximate(number)
      number_to_rounded(number, significant: true, precision: 2).to_f
    end
  end
end

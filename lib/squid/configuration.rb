require 'ostruct'

module Squid
  # Provides an object to store global configuration settings.
  #
  # This class is typically not used directly, but by calling
  # {Squid::Config#configure Squid.configure}, which creates and updates a
  # single instance of {Squid::Configuration}.
  #
  # @example Set the default height for Squid graphs:
  #   Squid.configure do |config|
  #     config.height = 150
  #     config.steps = 4
  #   end
  #
  # @see Squid::Config for more examples.
  #
  # An alternative way to set global configuration settings is by storing
  # them in the following environment variables:
  #
  # * +SQUID_HEIGHT+ to store the default graph height
  #
  # In case both methods are used together,
  # {Squid::Config#configure Squid.configure} takes precedence.
  #
  # @example Set the default graph height:
  #   ENV['SQUID_HEIGHT'] =  '150'
  #   ENV['SQUID_GRIDLINES'] =  '4'
  #
  class Configuration < OpenStruct
    def self.boolean
      -> (value) { %w(1 t T true TRUE).include? value }
    end

    def self.integer
      -> (value) { value.to_i }
    end

    def self.symbol
      -> (value) { value.to_sym }
    end

    def self.float
      -> (value) { value.to_f }
    end

    def self.array(proc = nil)
      -> (values) { values.split.map{|value| proc ? proc.call(value) : value} }
    end

    ATTRIBUTES = {
      baseline:     {as: boolean,        default: 'true'},
      border:       {as: boolean,        default: 'false'},
      chart:        {as: boolean,        default: 'true'},
      colors:       {as: array},
      every:        {as: integer,        default: '1'},
      formats:      {as: array(symbol)},
      height:       {as: float,          default: '250'},
      labels:       {as: array(boolean)},
      legend:       {as: boolean,        default: 'true'},
      line_widths:  {as: array(float)},
      col_max_width: {as: integer,       default: '0'},
      steps:        {as: integer,        default: '4'},
      ticks:        {as: boolean,        default: 'true'},
      type:         {as: symbol,         default: 'column'},
    }

    attr_accessor *ATTRIBUTES.keys

    # Initialize the global configuration settings.
    def initialize
      ATTRIBUTES.each do |key, options|
        var = "squid_#{key}".upcase
        value = ENV.fetch var, options.fetch(:default, '')
        public_send "#{key}=", options[:as].call(value)
      end
    end
  end
end

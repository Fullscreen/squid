require 'squid/settings'

module Squid
  # Abstract class that delegates unhandled calls to a +pdf+ object which
  # is convenient when working with Prawn methods
  class Base
    extend Settings

    attr_reader :pdf, :data

    def initialize(document, data = {}, settings = {})
      @pdf = document
      @data = data
      @settings = settings
    end

    # Delegates all unhandled calls to object returned by +pdf+ method.
    def method_missing(method, *args, &block)
      return super unless pdf.respond_to?(method)
      pdf.send method, *args, &block
    end

  private

    # Convenience method to wrap a block by setting and unsetting a Prawn
    # property such as line_width.
    def with(new_values = {})
      old_values = Hash[new_values.map{|k,_| [k,self.public_send(k)]}]
      new_values.each{|k, new_value| public_send "#{k}=", new_value }
      stroke { yield }
      old_values.each{|k, old_value| public_send "#{k}=", old_value }
    end
  end
end

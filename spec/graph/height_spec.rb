require 'spec_helper'

describe 'Graph height', inspect: true do
  let(:options) { {baseline: false, gridlines: 0} }

  it 'is 200 by default' do
    pdf.stroke_horizontal_rule
    pdf.chart data, options
    pdf.stroke_horizontal_rule

    expect(inspected_points.size).to be 2
    top, bottom = inspected_points.map{|x| x.first.last}
    expect(top - bottom).to eq 200
  end

  it 'can be set with the :height option' do
    pdf.stroke_horizontal_rule
    pdf.chart data, options.merge(height: 300)
    pdf.stroke_horizontal_rule

    expect(inspected_points.size).to be 2
    top, bottom = inspected_points.map{|x| x.first.last}
    expect(top - bottom).to eq 300.0
  end

  it 'can be set with Squid.config' do
    Squid.configure {|config| config.height = 400}
    pdf.stroke_horizontal_rule
    pdf.chart data, options
    pdf.stroke_horizontal_rule
    Squid.configure {|config| config.height = 200}

    expect(inspected_points.size).to be 2
    top, bottom = inspected_points.map{|x| x.first.last}
    expect(top - bottom).to eq 400.0
  end
end

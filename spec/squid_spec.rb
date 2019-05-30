require 'spec_helper'

describe 'Prawn::Document#chart' do
  let(:pdf) { Prawn::Document.new }
  let(:chart) { pdf.chart(data, settings); pdf.render }
  let(:data) { {} }
  let(:options) { {legend: false, baseline: false, steps: 0, format: :currency} }
  let(:settings) { options }
  let(:blue_rgb) { [0.1804, 0.3412, 0.549] }

  specify 'given no data, does not plot anything' do
    expect(rectangles_of chart).to be_empty
  end

  context 'given series without values' do
    let(:settings) { options.merge steps: 2 }
    let(:data) { {series_1: {}, series_2: {}} }

    it 'does not plot anything' do
      expect(rectangles_of chart).to be_empty
    end
  end

  context 'given one series' do
    let(:values) { {2013 => 50, 2014 => -30, 2015 => 20} }
    let(:data) { {series: values} }

    it 'includes one column for each value of the series' do
      expect(rectangles_of(chart).size).to be values.size
    end

    it 'has columns of the same width' do
      widths = rectangles_of(chart).map{|r| r[:width]}
      expect(widths.uniq).to be_one
    end

    it 'has all the columns aligned along the "0" value of the graph' do
      y = rectangles_of(chart).map{|r| r[:point].last}
      expect(y.uniq).to be_one
    end

    it 'has blue columns' do
      expect(colors_of(chart).fill_color).to eq blue_rgb
    end

    it 'does not include value labels on top of the chart' do
      expect(strings_of chart).to be_empty
    end

    context 'given the :label option is set to true' do
      let(:settings) { options.merge label: true }

      it 'includes the formatted value labels on top of each item' do
        expect(strings_of chart).to eq %w($50.00 -$30.00 $20.00)
      end
    end

    context 'given the :col_max_width is set to a value greater than zero' do
      let(:maximum) { 20 }
      let(:settings) { options.merge col_max_width: maximum }

      it 'creates the columns within the specified width' do
        widths = rectangles_of(chart).map{ |r| r[:width] }
        expect(widths[0]).to eq maximum
      end
    end

    context 'given the series has nil values' do
      let(:values) { {2013 => -50, 2014 => nil, 2015 => 20} }

      it 'ignores nil values' do
        expect(rectangles_of(chart).size).to be 2
      end
    end

    context 'given the :type is set to :point' do
      let(:settings) { options.merge type: :point }

      it 'prints the elements as circles of the same radius' do
        expect(rectangles_of chart).to be_empty
        expect(circles_of chart).not_to be_empty
        radii = points_of(chart).map{|x| x.map(&:first).inject(:-)}
        expect(radii.uniq).to be_one
      end
    end

    context 'given the :type is set to :line' do
      let(:settings) { options.merge type: :line }

      it 'prints the elements by connecting them with lines' do
        expect(rectangles_of chart).to be_empty
        expect(points_of(chart).size).to be values.size - 1
      end

      context 'given the :line_widths option is set to an array of values' do
        let(:line_width) { 1 + rand(10) }
        let(:settings) { options.merge type: :line, line_widths: [line_width] }

        it 'draws the line with the given width' do
          expect(lines_of(chart).widths).to include(line_width)
        end
      end
    end
  end

  context 'given many series' do
    let(:series_1) { {2013 => 110, 2014 => 30, 2015 => 13} }
    let(:series_2) { {2013 => -50, 2014 => 10, 2015 => 53} }
    let(:series_3) { {2013 => 20, 2014 => 140, 2015 => -3} }
    let(:data) { {series_1: series_1, series_2: series_2, series_3: series_3} }

    it 'includes one column for each value of each series' do
      expect(rectangles_of(chart).size).to be 9
    end

    it 'has columns of the same width' do
      widths = rectangles_of(chart).map{|r| r[:width]}
      expect(widths.uniq).to be_one
    end

    context 'given the :labels option is set for some series' do
      let(:settings) { options.merge labels: [true, false, true] }

      it 'draws a value labels for each rectangle of those series' do
        expect(strings_of(chart).size).to be 6
      end
    end

    context 'given the :type is set to :point' do
      let(:settings) { options.merge type: :point }

      it 'prints the one circle for each value of each series' do
        expect(rectangles_of chart).to be_empty
        expect(circles_of(chart).size/28).to be 9
      end
    end

    context 'given the :type is set to :line' do
      let(:settings) { options.merge type: :line }

      it 'includes one line for each series' do
        expect(rectangles_of chart).to be_empty
        expect(points_of(chart).size).to be 6
      end
    end

    context 'given the :type is set to :stack' do
      let(:settings) { options.merge type: :stack }

      it 'includes one stacked rectangle for each value of each series' do
        expect(rectangles_of(chart).size).to be 9
      end

      it 'includes as many stacks as the number of values' do
        expect(rectangles_of(chart).map{|r| r[:point].first}.uniq.size).to be 3
      end

      context 'given the :col_max_width is set to a value greater than zero' do
        let(:maximum) { 20 }
        let(:settings) { options.merge type: :stack, col_max_width: maximum }

        it 'creates the columns within the specified width' do
          widths = rectangles_of(chart).map{ |r| r[:width] }
          expect(widths[0]).to eq maximum
        end
      end
    end

    context 'given multiple options are provided' do
      let(:settings) { {type: :two_axis, colors: ['4ecdc4','c7f464','556270'], line_widths: [4, 2, 2]} }
      it 'applies all the options successfully' do
        expect(rectangles_of(chart).size).to be 9
      end
    end
  end

  context 'given non-default options' do
    let(:values) { {2013 => 50, 2014 => -30, 2015 => 20} }
    let(:data) { {'BWK p.a.' => values} }

    describe 'shows/hides the chart with the :chart option' do
      let(:settings) { options.merge chart: false }
      it { expect(rectangles_of chart).to be_empty }
    end

    describe 'shows/hides the chart with Squid.configuration.chart' do
      before { Squid.configure {|config| config.chart = false} }
      after { Squid.configure {|config| config.chart = true} }
      it { expect(rectangles_of chart).to be_empty }
    end

    describe 'shows/hides the legend with the :legend option' do
      let(:settings) { options.merge legend: true }
      it { expect(strings_of chart).not_to be_empty }
      it { expect(strings_of chart).to include 'BWK p.a.' }
    end

    describe 'shows/hides the chart with Squid.configuration.chart' do
      before { Squid.configure {|config| config.legend = false} }
      after { Squid.configure {|config| config.legend = true} }
      let(:settings) { options.except :legend }
      it { expect(strings_of chart).to be_empty }
    end

    describe 'shows/hides the gridlines with the :step option' do
      let(:settings) { options.merge steps: 8, chart: false }
      it { expect(points_of(chart).size).to be 9 }
    end

    describe 'shows/hides the chart with Squid.configuration.chart' do
      before { Squid.configure {|config| config.steps = 8} }
      after { Squid.configure {|config| config.steps = 4} }
      let(:settings) { options.merge(chart: false).except :steps }
      it { expect(points_of(chart).size).to be 9 }
    end

    describe 'shows/hides the value labels with the :label option' do
      let(:settings) { options.merge label: true }
      it { expect(strings_of chart).not_to be_empty }
    end

    describe 'shows/hides the value labels with Squid.configuration.label' do
      before { Squid.configure {|config| config.labels = [true]} }
      after { Squid.configure {|config| config.labels = [false]} }
      it { expect(strings_of chart).not_to be_empty }
    end

    describe 'shows/hides the ticks with the :ticks option' do
      let(:settings) { options.merge baseline: true, ticks: true }
      specify do
        points = points_of chart
        ticks_count = points.count{|tick| tick.first.last - tick.last.last == 2}
        expect(ticks_count).to eq values.size
      end
    end

    describe 'shows/hides the ticks with the Squid.configuration.ticks' do
      before { Squid.configure {|config| config.ticks = true} }
      after { Squid.configure {|config| config.ticks = false} }
      let(:settings) { options.merge baseline: true }
      specify do
        points = points_of chart
        ticks_count = points.count{|tick| tick.first.last - tick.last.last == 2}
        expect(ticks_count).to eq values.size
      end
    end

    describe 'uses the color provided with the :color option' do
      let(:settings) { options.merge color: 'ff0000' }
      it { expect(colors_of(chart).fill_color).to eq [1.0, 0.0, 0.0] }
    end

    describe 'uses the colors provided with the :colors option' do
      let(:settings) { options.merge colors: [ %w(ff0000) ] }
      it { expect(colors_of(chart).fill_color).to eq [1.0, 0.0, 0.0] }
    end

    describe 'uses the colors provided with Squid.configuration.colors' do
      before { Squid.configure {|config| config.colors = ['ff0000']} }
      after { Squid.configure {|config| config.colors = []} }
      it { expect(colors_of(chart).fill_color).to eq [1.0, 0.0, 0.0] }
    end

    describe 'formats value labels with the value of the :format option' do
      let(:settings) { options.merge label: true, format: :percentage }
      it { expect(strings_of chart).to eq %w(50.0% -30.0% 20.0%) }
    end

    describe 'formats value labels with the value of the :formats option' do
      let(:settings) { options.merge labels: [true], formats: [:percentage] }
      it { expect(strings_of chart).to eq %w(50.0% -30.0% 20.0%) }
    end

    describe 'formats value labels with the values from Squid.configuration' do
      before { Squid.configure {|config| config.labels = [true]; config.formats = [:percentage]} }
      after { Squid.configure {|config| config.labels = []; config.formats = []} }
      let(:settings) { options.except :format }
      it { expect(strings_of chart).to eq %w(50.0% -30.0% 20.0%) }
    end

    describe 'uses the line width provided with the :line_width option' do
      let(:settings) { options.merge type: :line, line_width: 6 }
      it { expect(lines_of(chart).widths).to include(6) }
    end

    describe 'uses the line widths provided with the :line_widths option' do
      let(:settings) { options.merge type: :line, line_widths: [ 6 ] }
      it { expect(lines_of(chart).widths).to include(6) }
    end

    describe 'uses the line widths provided with Squid.configuration.line_widths' do
      before { Squid.configure {|config| config.line_widths = [6]} }
      after { Squid.configure {|config| config.line_widths = []} }
      let(:settings) { options.merge type: :line }
      it { expect(lines_of(chart).widths).to include(6) }
    end

    describe 'uses the type provided with the :type option' do
      let(:settings) { options.merge type: :point }
      it { expect(circles_of chart).not_to be_empty }
    end

    describe 'uses the type provided with Squid.configuration.type' do
      before { Squid.configure {|config| config.type = :point} }
      after { Squid.configure {|config| config.type = :column} }
      it { expect(circles_of chart).not_to be_empty }
    end
  end

  context 'given long data keys with narrow space' do
    let(:settings) { options.merge every: 1, baseline: true }
    let(:data) { {"Views per playlist start"=>
      {"STORYTIME/MISC"=>1.2,
       "PRANKS/CHALLENGES"=>1.3,
       "SKITS"=>1.1,
       "*MUSIC*"=>1.0,
       "RELATIONSHIPS/ADVICE/TIPS"=>1.1,
       "LOVE/LIFE/FAMILY FUN"=>1.1,
       "TRAVEL VLOGS"=>1.1,
       "FITNESS/WORKOUTS"=>1.1}} }

    it 'does not raise Prawn::Errors::CannotFit error' do
      expect { chart }.not_to raise_error
    end
  end
end

def rectangles_of(output)
  PDF::Inspector::Graphics::Rectangle.analyze(output).rectangles
end

def colors_of(output)
  PDF::Inspector::Graphics::Color.analyze(output)
end

def strings_of(output)
  PDF::Inspector::Text.analyze(output).strings
end

def circles_of(output)
  PDF::Inspector::Graphics::Curve.analyze(output).coords
end

def points_of(output)
  lines_of(output).points.each_slice(2)
end

def lines_of(output)
  PDF::Inspector::Graphics::Line.analyze(output)
end

# Monkey-patch so non-black colors can be analyzed at the end
class PDF::Inspector::Graphics::Color
  def set_color_for_nonstroking_and_special(*params)
    @fill_color = params unless params.all? &:zero?
  end
end

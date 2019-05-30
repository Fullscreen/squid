# By default, <code>chart</code> maximizes the width of columns.
#
# You can use the <code>:col_max_width</code> option to limit the maximum width of columns in the chart (measured in points; 72 points per inch).
#
filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::ManualBuilder::Example.generate(filename) do
  data = {views: {2013 => 182, 2014 => 46, 2015 => 134}}
  chart data, col_max_width: 20
end

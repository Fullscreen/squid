Prawn::ManualBuilder::Example.generate 'squid.pdf' do
  package 'squid' do |p|
    p.name = 'Squid'

    p.intro do
      prose('
        Prawn is a great library to generate PDF files from Ruby, but lacks high-level components to generate graphs.
        Squid integrates Prawn by providing methods to plot charts in PDF files with few lines of code.
        This manual shows:
      ')

      list(
        'How to create graphs',
      )
    end

    p.section 'Basics' do |s|
      s.example 'basic'
      s.example 'legend'
      s.example 'col_max_width'
    end

    p.section 'Chart types' do |s|
      s.example 'point'
      s.example 'line'
    end

    p.section 'Styling' do |s|
      s.example 'height'
      s.example 'color'
      s.example 'baseline'
      s.example 'ticks'
      s.example 'every'
      s.example 'gridlines'
      s.example 'format'
      s.example 'border'
      s.example 'labels'
      s.example 'line_width'
      s.example 'legend_offset'
    end

    p.section 'Multiple series' do |s|
      s.example 'columns'
      s.example 'lines'
      s.example 'points'
      s.example 'stacks'
      s.example 'two_axis'
    end
  end
end

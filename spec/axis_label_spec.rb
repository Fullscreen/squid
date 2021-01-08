require 'spec_helper'

describe Squid::AxisLabel do
  let(:options) { {align: align, height: height} }
  let(:align) { :left }
  let(:height) { 100 }
  let(:axis) { OpenStruct.new labels: labels, width: width }
  let(:labels) { %w(110 70 30 -10 -50) }
  let(:width) { 50 }

  describe '.for' do
    subject(:axis_labels) { Squid::AxisLabel.for axis, **options }

    it 'returns an instance for each label, with vertically distributed y between 0 and height' do
      expect(axis_labels.map &:label).to eq labels
      expect(axis_labels.map &:align).to all(be align)
      expect(axis_labels.map &:width).to all(be width)
      expect(axis_labels.map &:y).to eq [100.0, 75.0, 50.0, 25.0, 0.0]
    end
  end
end

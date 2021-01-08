require 'spec_helper'

describe Squid::Axis do
  let(:options) { {steps: steps, stack: stack?, format: format} }
  let(:steps) { 4 }
  let(:stack?) { false }
  let(:format) { nil }
  let(:block) { nil }
  let(:series) { [[-1.0, 9.9, 3.0], [nil, 2.0, -50.0]] }

  describe '#labels' do
    subject(:axis) { Squid::Axis.new series, **options }
    let(:labels) { axis.labels }

    describe 'given 0 steps' do
      let(:steps) { 0 }
      it 'returns 0 strings' do
        expect(labels.size).to be_zero
      end
    end

    describe 'given N steps' do
      let(:steps) { 1 + rand(10) }
      it 'returns N+1 strings' do
        expect(labels.size).to be steps + 1
      end
    end

    describe 'given stacked series' do
      let(:stack?) { false }
      it 'ranges the labels from the min and max of all series' do
        expect(labels.first).to eq '9'
        expect(labels.last).to eq '-50'
      end
    end

    describe 'given non-stacked series' do
      let(:stack?) { true }
      it 'ranges the labels from the cumulative min and max of all series' do
        expect(labels.first).to eq '12'
        expect(labels.last).to eq '-50'
      end
    end

    describe 'given :integer format' do
      let(:format) { :integer }
      it 'returns the labels as integers, rounded to the closest step' do
        expect(labels).to eq %w(14 -2 -18 -34 -50)
      end
    end

    describe 'given :percentage format' do
      let(:format) { :percentage }
      it 'returns the labels as percentages with 1 significant digit' do
        expect(labels).to eq %w(9.9% -5.1% -20.0% -35.0% -50.0%)
      end
    end

    describe 'given :currency format' do
      let(:format) { :currency }
      it 'returns the labels as currency with 2 significant digits' do
        expect(labels).to eq %w($9.90 -$5.07 -$20.05 -$35.03 -$50.00)
      end
    end

    describe 'given :second format' do
      let(:format) { :seconds }
      it 'returns the labels as minutes:seconds' do
        expect(labels).to eq %w(0:10 -0:05 -0:20 -0:35 -0:50)
      end
    end

    describe 'given :float format' do
      let(:format) { :float }
      it 'returns the labels as floats with all significant digits' do
        expect(labels).to eq %w(9.9 -5.1 -20 -35 -50)
      end
    end
  end

  describe '#width' do
    let(:width) { axis.width }

    describe 'given no block, returns 0' do
      subject(:axis) { Squid::Axis.new series, **options }
      it { expect(width).to be_zero }
    end

    describe 'given non-integer values, returns the maximum value of the block' do
      subject(:axis) { Squid::Axis.new series, **options, &block }
      let(:block) { -> (value) { value.to_i } }
      it { expect(width).to eq 9 }
    end

    describe 'given integer values, returns the maximum value, rounded to the closest step' do
      subject(:axis) { Squid::Axis.new series, **options, &block }
      let(:format) { :integer }
      let(:block) { -> (value) { value.to_i } }
      it { expect(width).to eq 14 }
    end
  end
end

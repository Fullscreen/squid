require 'spec_helper'

describe Squid::Gridline do
  let(:options) { {height: height, count: count, skip_baseline: skip_baseline} }
  let(:height) { 100 }
  let(:count) { 4 }
  let(:skip_baseline) { false }

  describe '.for' do
    subject(:gridlines) { Squid::Gridline.for **options }

    it 'returns +count+ instances, with vertically distributed y between 0 and height' do
      expect(gridlines.map &:y).to eq [100.0, 75.0, 50.0, 25.0, 0.0]
    end

    describe 'given skip_baseline: true' do
      let(:skip_baseline) { true }
      it 'skips the last line' do
        expect(gridlines.map &:y).to eq [100.0, 75.0, 50.0, 25.0]
      end
    end
  end
end

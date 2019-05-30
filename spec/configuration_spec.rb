require 'spec_helper'

RSpec.shared_examples 'a configurable setting' do |method:, env:, default:, sample_value:|
  it "#{method} is #{default} by default" do
    ENV[env] = nil
    expect(subject.public_send method).to eq default
  end

  it "#{method} can be set with the environment variable #{env}" do
    ENV[env] = sample_value
    expect(subject.public_send method).not_to eq default
    ENV[env] = nil
  end
end

describe Squid::Configuration do
  subject { Squid::Configuration.new }
  sample_false = %w(0 f F false FALSE).sample
  sample_true =  %w(1 t T true TRUE).sample

  it_behaves_like 'a configurable setting', method: 'baseline',    env: 'SQUID_BASELINE',    default: true,       sample_value: sample_false
  it_behaves_like 'a configurable setting', method: 'border',      env: 'SQUID_BORDER',      default: false,      sample_value: sample_true
  it_behaves_like 'a configurable setting', method: 'chart',       env: 'SQUID_CHART',       default: true,       sample_value: sample_false
  it_behaves_like 'a configurable setting', method: 'colors',      env: 'SQUID_COLORS',      default: [],         sample_value: 'ff0000'
  it_behaves_like 'a configurable setting', method: 'every',       env: 'SQUID_EVERY',       default: 1,          sample_value: '2'
  it_behaves_like 'a configurable setting', method: 'formats',     env: 'SQUID_FORMATS',     default: [],         sample_value: 'percentage'
  it_behaves_like 'a configurable setting', method: 'height',      env: 'SQUID_HEIGHT',      default: 250,        sample_value: '150'
  it_behaves_like 'a configurable setting', method: 'labels',      env: 'SQUID_LABELS',      default: [],         sample_value: sample_true
  it_behaves_like 'a configurable setting', method: 'legend',      env: 'SQUID_LEGEND',      default: true,       sample_value: sample_false
  it_behaves_like 'a configurable setting', method: 'line_widths', env: 'SQUID_LINE_WIDTHS', default: []   ,      sample_value: '4'
  it_behaves_like 'a configurable setting', method: 'col_max_width', env: 'SQUID_COL_MAX_WIDTH', default: 0,      sample_value: '20'
  it_behaves_like 'a configurable setting', method: 'steps',       env: 'SQUID_STEPS',       default: 4,          sample_value: '0'
  it_behaves_like 'a configurable setting', method: 'ticks',       env: 'SQUID_TICKS',       default: true,       sample_value: sample_false
  it_behaves_like 'a configurable setting', method: 'type',        env: 'SQUID_TYPE',        default: :column,    sample_value: 'line'
end

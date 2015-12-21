require 'spec_helper'

describe CstimerAnalyserCli do
  it 'has a version number' do
    expect(CstimerAnalyserCli::VERSION).not_to be nil
  end

  it 'doesn\'t do anything useful' do
    expect(true).to eq(true)
  end
end

require 'test_helper'

describe 'Core extensions' do
  it 'adds a String#tidy method' do
    ' test '.tidy.must_equal 'test'
  end
end

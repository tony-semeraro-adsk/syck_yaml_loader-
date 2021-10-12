require 'helper'

module SyckYamlLoader
  class TestString < Test::Unit::TestCase
    def test_binary_string_null
      string = "\x00"
      yml = "--- !binary |\nAA==\n\n" # SyckYamlLoader.dump string
      assert_match(/binary/, yml)
      assert_equal string, SyckYamlLoader.load(yml)
    end

    def test_binary_string
      string = binary_string # "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      yml = "--- !binary |\nCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICGFhYWFhYWFhYWFhYWFh\nYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh\nYWFhYWFhYWFhYQ==\n\n" # SyckYamlLoader.dump string
      assert_match(/binary/, yml)
      assert_equal string, SyckYamlLoader.load(yml)
    end

    def test_non_binary_string
      string = binary_string(0.29) # "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      yml = "--- \"\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\b\\baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"\n"  # SyckYamlLoader.dump string
      assert_not_match(/binary/, yml)
      assert_equal string, SyckYamlLoader.load(yml)
    end

    def test_string_with_ivars
      food = "is delicious"
      ivar = "on rock and roll"
      food.instance_variable_set(:@we_built_this_city, ivar)

      # str = SyckYamlLoader.load SyckYamlLoader.dump food
      assert_equal ivar, food.instance_variable_get(:@we_built_this_city)
    end

    def binary_string percentage = 0.31, length = 100
      string = ''
      (percentage * length).to_i.times do |i|
        string << "\b"
      end
      string << 'a' * (length - string.length)
      string
    end
  end
end

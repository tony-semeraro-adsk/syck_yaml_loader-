require 'helper'

module SyckYamlLoader
  ###
  # Test booleans from YAML spec:
  # http://yaml.org/type/bool.html
  class TestBoolean < Test::Unit::TestCase
    %w{ yes Yes YES true True TRUE on On ON }.each do |truth|
      define_method(:"test_#{truth}") do
        assert_equal true, SyckYamlLoader.load("--- #{truth}")
      end
    end

    %w{ no No NO false False FALSE off Off OFF }.each do |truth|
      define_method(:"test_#{truth}") do
        assert_equal false, SyckYamlLoader.load("--- #{truth}")
      end
    end

    ###
    # YAML spec says "y" and "Y" may be used as true, but SyckYamlLoader treats them
    # as literal strings
    def test_y
      assert_equal "y", SyckYamlLoader.load("--- y")
      assert_equal "Y", SyckYamlLoader.load("--- Y")
    end

    ###
    # YAML spec says "n" and "N" may be used as false, but SyckYamlLoader treats them
    # as literal strings
    def test_n
      assert_equal "n", SyckYamlLoader.load("--- n")
      assert_equal "N", SyckYamlLoader.load("--- N")
    end
  end
end

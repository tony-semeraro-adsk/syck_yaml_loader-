require 'helper'

module SyckYamlLoader
  class TestSymbol < Test::Unit::TestCase
    def test_load
      assert_equal :a, SyckYamlLoader.load("--- :a\n")  # :a.to_yaml "--- :a\n"
    end

    def test_stringy
      assert_equal :"1", SyckYamlLoader.load("--- :\"1\"\n") # SyckYamlLoader.dump(:"1") "--- :\"1\"\n"
    end

    def test_load_quoted
      assert_equal :"1", SyckYamlLoader.load("--- :'1'\n")
    end
  end
end

require 'helper'

module SyckYamlLoader
  class TestArray < Test::Unit::TestCase
    def setup
      @list = [{ :a => 'b' }, 'foo']
      @dumped = "--- \n- :a: b\n- foo\n"
    end

    def test_load
      assert_equal @list, SyckYamlLoader.load(@dumped)
    end
  end
end

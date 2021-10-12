require 'helper'

module SyckYamlLoader
  class TestSet < Test::Unit::TestCase
    def setup
      @set = SyckYamlLoader::Set.new
      @set['foo'] = 'bar'
      @set['bar'] = 'baz'
    end

    ###
    # FIXME: SyckYamlLoader should also support !!set as shorthand
    def test_load_from_yaml
      loaded = SyckYamlLoader.load(<<-eoyml)
--- !set
foo: bar
bar: baz
      eoyml
      assert_equal(@set, loaded)
    end
  end
end

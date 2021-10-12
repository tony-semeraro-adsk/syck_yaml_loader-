require 'helper'

module SyckYamlLoader
  class TestHash < Test::Unit::TestCase
    def setup
      @hash = { :a => 'b' }
    end

    def test_load
      dumped =  "--- \n:a: b\n"  # YAML.dump(@hash)
      assert_equal @hash, SyckYamlLoader.load(dumped)
    end

    def test_ref_append
      hash = SyckYamlLoader.load(<<-eoyml)
---
foo: &foo
  hello: world
bar:
  <<: *foo
eoyml
      assert_equal({"foo"=>{"hello"=>"world"}, "bar"=>{"hello"=>"world"}}, hash)
    end
  end
end

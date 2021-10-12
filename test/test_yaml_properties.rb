require 'helper'

module SyckYamlLoader
  class TestYamlProperties < Test::Unit::TestCase
    class Foo
      attr_reader :a, :b, :c
      def initialize
        @a = 1
        @b = 2
        @c = 3
      end

      def syck_to_yaml_properties
        [:@a, :@b]
      end
    end

    def test_object_dump_yaml_properties
      # SyckYamlLoader.dump(SyckYamlLoader::TestYamlProperties::Foo.new)
      # => "--- !ruby/object:SyckYamlLoader::TestYamlProperties::Foo \na: 1\nb: 2\n"
      foo = SyckYamlLoader.load("--- !ruby/object:SyckYamlLoader::TestYamlProperties::Foo \na: 1\nb: 2\n")
      assert_equal 1, foo.a
      assert_equal 2, foo.b
      assert_nil foo.c
    end

    class Bar < Struct.new(:foo, :bar)
      attr_reader :baz
      def initialize *args
        super
        @baz = 'hello'
      end

      def syck_to_yaml_properties
        []
      end
    end

    def test_struct_dump_yaml_properties
      # SyckYamlLoader.dump(SyckYamlLoader::TestYamlProperties::Bar.new('a', 'b'))
      #  => "--- !ruby/struct:SyckYamlLoader::TestYamlProperties::Bar \nfoo: a\nbar: b\n"
      bar = SyckYamlLoader.load("--- !ruby/struct:SyckYamlLoader::TestYamlProperties::Bar \nfoo: a\nbar: b\n" )
      assert_equal 'a', bar.foo
      assert_equal 'b', bar.bar
      assert_nil bar.baz
    end

    def test_string_load
      str = SyckYamlLoader.load("--- !str \nstr: okonomiyaki\n:@tastes: delicious\n")
      assert_equal 'okonomiyaki', str
      assert_equal 'delicious', str.instance_variable_get(:@tastes)
    end
  end
end

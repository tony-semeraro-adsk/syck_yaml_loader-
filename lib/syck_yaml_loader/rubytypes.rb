# -*- mode: ruby; ruby-indent-level: 4; tab-width: 4 -*- vim: sw=4 ts=4
require 'date'
#
class Class
	def syck_to_yaml( opts = {} )
		raise TypeError, "can't dump anonymous class %s" % self.class
	end
end

class Object
  syck_yaml_as "tag:ruby.yaml.org,2002:object"

  def syck_to_yaml_style;
  end

  undef syck_to_yaml_properties rescue nil

  def syck_to_yaml_properties;
    instance_variables.sort;
  end

  def syck_to_yaml(opts = {})
    return super unless YAML == SyckYamlLoader
    SyckYamlLoader::quick_emit(self, opts) do |out|
      out.map(taguri, syck_to_yaml_style) do |map|
        syck_to_yaml_properties.each do |m|
          map.add(m[1..-1], instance_variable_get(m))
        end
      end
    end
  end

  # alias :syck_to_yaml :to_yaml
end

class Hash
  syck_yaml_as "tag:ruby.yaml.org,2002:hash"
  syck_yaml_as "tag:yaml.org,2002:map"

  def yaml_initialize(tag, val)
    if Array === val
      update Hash.[](*val) # Convert the map to a sequence
    elsif Hash === val
      update val
    else
      raise SyckYamlLoader::TypeError, "Invalid map explicitly tagged #{ tag }: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.map(taguri, syck_to_yaml_style) do |map|
  #       each do |k, v|
  #         map.add(k, v)
  #       end
  #     end
  #   end
  # end
end

class Struct
  syck_yaml_as "tag:ruby.yaml.org,2002:struct"

  def self.yaml_tag_class_name;
    self.name.gsub("Struct::", "");
  end

  def self.yaml_tag_read_class(name)
    ; "Struct::#{ name }";
  end

  def self.yaml_new(klass, tag, val)
    if Hash === val
      struct_type = nil

      #
      # Use existing Struct if it exists
      #
      props = {}
      val.delete_if { |k, v| props[k] = v if k =~ /^@/ }
      begin
        struct_type = SyckYamlLoader.read_type_class(tag, Struct).last
      rescue NameError
      end
      if not struct_type
        struct_def = [tag.split(':', 4).last]
        struct_type = Struct.new(*struct_def.concat(val.keys.collect { |k| k.intern }))
      end

      #
      # Set the Struct properties
      #
      st = SyckYamlLoader::object_maker(struct_type, {})
      st.members.each do |m|
        st.send("#{m}=", val[m.to_s])
      end
      props.each do |k, v|
        st.instance_variable_set(k, v)
      end
      st
    else
      raise SyckYamlLoader::TypeError, "Invalid Ruby Struct: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     #
  #     # Basic struct is passed as a YAML map
  #     #
  #     out.map(taguri, syck_to_yaml_style) do |map|
  #       self.members.each do |m|
  #         map.add(m.to_s, self[m.to_s])
  #       end
  #       self.syck_to_yaml_properties.each do |m|
  #         map.add(m, instance_variable_get(m))
  #       end
  #     end
  #   end
  # end
end

class Array
  syck_yaml_as "tag:ruby.yaml.org,2002:array"
  syck_yaml_as "tag:yaml.org,2002:seq"

  def yaml_initialize(tag, val)
    ; concat(val.to_a);
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.seq(taguri, syck_to_yaml_style) do |seq|
  #       each do |x|
  #         seq.add(x)
  #       end
  #     end
  #   end
  # end
end

class Exception
  syck_yaml_as "tag:ruby.yaml.org,2002:exception"

  def Exception.yaml_new(klass, tag, val)
    o = klass.allocate
    Exception.instance_method(:initialize).bind(o).call(val.delete('message'))
    val.each_pair do |k, v|
      o.instance_variable_set("@#{k}", v)
    end
    o
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.map(taguri, syck_to_yaml_style) do |map|
  #       map.add('message', message)
  #       syck_to_yaml_properties.each do |m|
  #         map.add(m[1..-1], instance_variable_get(m))
  #       end
  #     end
  #   end
  # end
end

class String
  syck_yaml_as "tag:ruby.yaml.org,2002:string"
  syck_yaml_as "tag:yaml.org,2002:binary"
  syck_yaml_as "tag:yaml.org,2002:str"

  def is_complex_yaml?
    syck_to_yaml_style or not syck_to_yaml_properties.empty? or self =~ /\n.+/
  end

  def is_binary_data?
    self.count("\x00-\x7F", "^ -~\t\r\n").fdiv(self.size) > 0.3 || self.index("\x00") unless self.empty?
  end

  def String.yaml_new(klass, tag, val)
    val = val.unpack("m")[0] if tag == "tag:yaml.org,2002:binary"
    val = {'str' => val} if String === val
    if Hash === val
      s = klass.allocate
      # Thank you, NaHi
      String.instance_method(:initialize).
          bind(s).
          call(val.delete('str'))
      val.each { |k, v| s.instance_variable_set(k, v) }
      s
    else
      raise SyckYamlLoader::TypeError, "Invalid String: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(is_complex_yaml? ? self : nil, opts) do |out|
  #     if is_binary_data?
  #       out.scalar("tag:yaml.org,2002:binary", [self].pack("m"), :literal)
  #     elsif syck_to_yaml_properties.empty?
  #       out.scalar(taguri, self, self =~ /^:/ ? :quote2 : syck_to_yaml_style)
  #     else
  #       out.map(taguri, syck_to_yaml_style) do |map|
  #         map.add('str', "#{self}")
  #         syck_to_yaml_properties.each do |m|
  #           map.add(m, instance_variable_get(m))
  #         end
  #       end
  #     end
  #   end
  # end
end

class Symbol
  syck_yaml_as "tag:ruby.yaml.org,2002:symbol"
  syck_yaml_as "tag:ruby.yaml.org,2002:sym"

  def Symbol.yaml_new(klass, tag, val)
    if String === val
      val = SyckYamlLoader::load(val) if val =~ /\A(["']).*\1\z/
      val.intern
    else
      raise SyckYamlLoader::TypeError, "Invalid Symbol: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     out.scalar("tag:yaml.org,2002:str", self.inspect, :plain)
  #   end
  # end
end

class Range
  syck_yaml_as "tag:ruby.yaml.org,2002:range"

  def Range.yaml_new(klass, tag, val)
    inr = %r'(\w+|[+-]?\d+(?:\.\d+)?(?:e[+-]\d+)?|"(?:[^\\"]|\\.)*")'
    opts = {}
    if String === val and val =~ /^#{inr}(\.{2,3})#{inr}$/o
      r1, rdots, r2 = $1, $2, $3
      opts = {
          'begin' => SyckYamlLoader.load("--- #{r1}"),
          'end' => SyckYamlLoader.load("--- #{r2}"),
          'excl' => rdots.length == 3
      }
      val = {}
    elsif Hash === val
      opts['begin'] = val.delete('begin')
      opts['end'] = val.delete('end')
      opts['excl'] = val.delete('excl')
    end
    if Hash === opts
      r = SyckYamlLoader::object_maker(klass, {})
      # Thank you, NaHi
      Range.instance_method(:initialize).
          bind(r).
          call(opts['begin'], opts['end'], opts['excl'])
      val.each { |k, v| r.instance_variable_set(k, v) }
      r
    else
      raise SyckYamlLoader::TypeError, "Invalid Range: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     # if self.begin.is_complex_yaml? or self.begin.respond_to? :to_str or
  #     #   self.end.is_complex_yaml? or self.end.respond_to? :to_str or
  #     #   not syck_to_yaml_properties.empty?
  #     out.map(taguri, syck_to_yaml_style) do |map|
  #       map.add('begin', self.begin)
  #       map.add('end', self.end)
  #       map.add('excl', self.exclude_end?)
  #       syck_to_yaml_properties.each do |m|
  #         map.add(m, instance_variable_get(m))
  #       end
  #     end
  #     # else
  #     #     out.scalar( taguri ) do |sc|
  #     #         sc.embed( self.begin )
  #     #         sc.concat( self.exclude_end? ? "..." : ".." )
  #     #         sc.embed( self.end )
  #     #     end
  #     # end
  #   end
  # end
end

class Regexp
  syck_yaml_as "tag:ruby.yaml.org,2002:regexp"

  def Regexp.yaml_new(klass, tag, val)
    if String === val and val =~ /^\/(.*)\/([mixn]*)$/
      val = {'regexp' => $1, 'mods' => $2}
    end
    if Hash === val
      mods = nil
      unless val['mods'].to_s.empty?
        mods = 0x00
        mods |= Regexp::EXTENDED if val['mods'].include?('x')
        mods |= Regexp::IGNORECASE if val['mods'].include?('i')
        mods |= Regexp::MULTILINE if val['mods'].include?('m')
        mods |= Regexp::NOENCODING if val['mods'].include?('n')
      end
      val.delete('mods')
      r = SyckYamlLoader::object_maker(klass, {})
      Regexp.instance_method(:initialize).
          bind(r).
          call(val.delete('regexp'), mods)
      val.each { |k, v| r.instance_variable_set(k, v) }
      r
    else
      raise SyckYamlLoader::TypeError, "Invalid Regular expression: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     if syck_to_yaml_properties.empty?
  #       out.scalar(taguri, self.inspect, :plain)
  #     else
  #       out.map(taguri, syck_to_yaml_style) do |map|
  #         src = self.inspect
  #         if src =~ /\A\/(.*)\/([a-z]*)\Z/
  #           map.add('regexp', $1)
  #           map.add('mods', $2)
  #         else
  #           raise SyckYamlLoader::TypeError, "Invalid Regular expression: " + src
  #         end
  #         syck_to_yaml_properties.each do |m|
  #           map.add(m, instance_variable_get(m))
  #         end
  #       end
  #     end
  #   end
  # end
end

class Time
  syck_yaml_as "tag:ruby.yaml.org,2002:time"
  syck_yaml_as "tag:yaml.org,2002:timestamp"

  def Time.yaml_new(klass, tag, val)
    if Hash === val
      t = val.delete('at')
      val.each { |k, v| t.instance_variable_set(k, v) }
      t
    else
      raise SyckYamlLoader::TypeError, "Invalid Time: " + val.inspect
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     tz = "Z"
  #     # from the tidy Tobias Peters <t-peters@gmx.de> Thanks!
  #     unless self.utc?
  #       utc_same_instant = self.dup.utc
  #       utc_same_writing = Time.utc(year, month, day, hour, min, sec, usec)
  #       difference_to_utc = utc_same_writing - utc_same_instant
  #       if (difference_to_utc < 0)
  #         difference_sign = '-'
  #         absolute_difference = -difference_to_utc
  #       else
  #         difference_sign = '+'
  #         absolute_difference = difference_to_utc
  #       end
  #       difference_minutes = (absolute_difference / 60).round
  #       tz = "%s%02d:%02d" % [difference_sign, difference_minutes / 60, difference_minutes % 60]
  #     end
  #     standard = self.strftime("%Y-%m-%d %H:%M:%S")
  #     standard += ".%06d" % [usec] if usec.nonzero?
  #     standard += " %s" % [tz]
  #     if syck_to_yaml_properties.empty?
  #       out.scalar(taguri, standard, :plain)
  #     else
  #       out.map(taguri, syck_to_yaml_style) do |map|
  #         map.add('at', standard)
  #         syck_to_yaml_properties.each do |m|
  #           map.add(m, instance_variable_get(m))
  #         end
  #       end
  #     end
  #   end
  # end
end

class Date
  syck_yaml_as "tag:yaml.org,2002:timestamp#ymd"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.scalar("tag:yaml.org,2002:timestamp", self.to_s, :plain)
  #   end
  # end
end

class Integer
  syck_yaml_as "tag:yaml.org,2002:int"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     out.scalar("tag:yaml.org,2002:int", self.to_s, :plain)
  #   end
  # end
end

class Float
  syck_yaml_as "tag:yaml.org,2002:float"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     str = self.to_s
  #     if str == "Infinity"
  #       str = ".Inf"
  #     elsif str == "-Infinity"
  #       str = "-.Inf"
  #     elsif str == "NaN"
  #       str = ".NaN"
  #     end
  #     out.scalar("tag:yaml.org,2002:float", str, :plain)
  #   end
  # end
end

class Rational
  syck_yaml_as "tag:ruby.yaml.org,2002:object:Rational"

  def Rational.yaml_new(klass, tag, val)
    if val.is_a? String
      Rational(val)
    else
      Rational(val['numerator'], val['denominator'])
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.map(taguri, nil) do |map|
  #       map.add('denominator', denominator)
  #       map.add('numerator', numerator)
  #     end
  #   end
  # end
end

class Complex
  syck_yaml_as "tag:ruby.yaml.org,2002:object:Complex"

  def Complex.yaml_new(klass, tag, val)
    if val.is_a? String
      Complex(val)
    else
      Complex(val['real'], val['image'])
    end
  end

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(self, opts) do |out|
  #     out.map(taguri, nil) do |map|
  #       map.add('image', imaginary)
  #       map.add('real', real)
  #     end
  #   end
  # end
end

class TrueClass
  syck_yaml_as "tag:yaml.org,2002:bool#yes"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     out.scalar(taguri, "true", :plain)
  #   end
  # end
end

class FalseClass
  syck_yaml_as "tag:yaml.org,2002:bool#no"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     out.scalar(taguri, "false", :plain)
  #   end
  # end
end

class NilClass
  syck_yaml_as "tag:yaml.org,2002:null"

  # def syck_to_yaml(opts = {})
  #   return super unless YAML == SyckYamlLoader
  #   SyckYamlLoader::quick_emit(nil, opts) do |out|
  #     out.scalar(taguri, "", :plain)
  #   end
  # end
end

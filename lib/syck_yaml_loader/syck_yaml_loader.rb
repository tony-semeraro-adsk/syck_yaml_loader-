#
# YAML::SyckYamlLoader module
# .. glues syck and yaml.rb together ..
#
require 'syck_yaml_loader/basenode'

module SyckYamlLoader

  #
  # Mixin BaseNode functionality
  #
  class Node
    include SyckYamlLoader::BaseNode
  end

end

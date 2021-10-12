require 'rake'
require "bundler"
# task :default => :spec

#
# # require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'
# require 'rake-compiler'
# #
CLEAN << "lib/syck_yaml_loader.bundle" << "tmp"
# #
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
end
Rake::ExtensionTask.new('syck_yaml_loader')
# #
task :default => [:compile, :test]

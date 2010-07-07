require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "wirp"
    gem.summary = %Q{Create captive networks with transparent proxying on OS X}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "quigley@emerose.com"
    gem.homepage = "http://github.com/emerose/wirp"
    gem.authors = ["Sam Quigley"]
    gem.add_development_dependency "rspec"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ["--format", "specdoc", "--colour"]
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.spec_opts = ["--format", "specdoc", "--colour"]
end

task :spec => :check_dependencies

task :default => :spec


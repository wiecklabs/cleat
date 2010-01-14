require "rubygems"
require "pathname"
require "rake"
require "rake/testtask"

# tests
task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# Gem
require "rake/gempackagetask"
require "lib/cleat/version"

NAME = "cleat"
SUMMARY = "Cleat Port"
GEM_VERSION = Cleat::VERSION

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.summary = s.description = SUMMARY
  s.homepage = "http://wiecklabs.com"
  s.author = "Wieck Media"
  s.email = "dev@wieck.com"
  s.homepage = "http://www.wieck.com"
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.files = %w(Rakefile) + Dir.glob("{lib,spec,test,public,assets}/**/*")

  s.add_dependency "port_authority"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

spec_file = ".gemspec"
desc "Create #{spec_file}"
task :gemspec do
  File.open(spec_file, "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Install #{NAME} as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end

task :version do
  puts GEM_VERSION
end
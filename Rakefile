require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rake/clean'
begin
  require 'jeweler'
rescue LoadError
  raise LoadError, "!!! Please install the gem: jeweler !!!"
end

Jeweler::Tasks.new do |gem|
  gem.name = "green_shoes"
  gem.summary = %Q{Green Shoes}
  gem.description = %Q{Green Shoes is one of colorful Shoes, written in pure Ruby with Ruby/GTK2.}
  gem.email = "ashbbb@gmail.com"
  gem.executables = ["gshoes"]
  gem.homepage = "http://github.com/ashbb/green_shoes"
  gem.authors = ["ashbb"]
  gem.add_dependency 'gtk2'
  gem.files = %w[bin lib static samples snapshots].map{|dir| FileList[dir + '/**/*']}.flatten << 'VERSION'
end

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'doc'
  t.title    = 'Green Shoes'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.md')
  t.rdoc_files.include('lib/green_shoes.rb')
  t.rdoc_files.include('lib/shoes/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', 'doc' ]

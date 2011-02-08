require 'rubygems'
require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "green_shoes"
  gem.summary = %Q{Green Shoes}
  gem.description = %Q{Green Shoes is one of colorful Shoes, written in pure Ruby with Ruby/GTK2.}
  gem.email = "ashbbb@gmail.com"
  gem.homepage = "http://github.com/ashbb/green_shoes"
  gem.authors = ["ashbb"]
  gem.add_dependency 'gtk2'
  gem.files = %w[lib static samples snapshots].map{|dir| FileList[dir + '/**/*']}.flatten << 'VERSION'
end

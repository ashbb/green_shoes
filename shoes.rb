require 'tmpdir'
require 'pathname'

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
  TMP_PNG_FILE = File.join(Dir.tmpdir, '__green_shoes_temporary_file__')
end

class Object
  remove_const :Shoes
end

require 'cairo'
require 'pango'
require 'gtk2'
require_relative 'shoes/ruby'
require_relative 'shoes/helper_methods'
require_relative 'shoes/colors'
require_relative 'shoes/basic'
require_relative 'shoes/app'
require_relative 'shoes/anim'
require_relative 'shoes/slot'

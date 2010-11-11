require 'tmpdir'
require 'pathname'
require 'cairo'
require 'pango'
require 'gtk2'

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
  TMP_PNG_FILE = File.join(Dir.tmpdir, '__green_shoes_temporary_file__')
  HAND = Gdk::Cursor.new(Gdk::Cursor::HAND1)
  ARROW = Gdk::Cursor.new(Gdk::Cursor::ARROW)
  FONTS = Gtk::Invisible.new.pango_context.families.map(&:name).sort
  LINK_DEFAULT = "<span underline='single' underline_color='#06E' foreground='#06E'>"
  LINKHOVER_DEFAULT = "<span underline='single' underline_color='#039' foreground='#039'>"
end

class Object
  remove_const :Shoes
end

require_relative 'shoes/ruby'
require_relative 'shoes/helper_methods'
require_relative 'shoes/colors'
require_relative 'shoes/basic'
require_relative 'shoes/main'
require_relative 'shoes/app'
require_relative 'shoes/anim'
require_relative 'shoes/slot'
require_relative 'shoes/text'

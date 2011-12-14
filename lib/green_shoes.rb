require 'tmpdir'
require 'pathname'
require 'cairo'
require 'pango'
require 'gdk_pixbuf2'
require 'gtk2'

STDOUT.sync = true

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
  TMP_PNG_FILE = File.join(Dir.tmpdir, '__green_shoes_temporary_file__')
  HAND = Gdk::Cursor.new(Gdk::Cursor::HAND1)
  ARROW = Gdk::Cursor.new(Gdk::Cursor::ARROW)
  FONTS = Gtk::Invisible.new.pango_context.families.map(&:name).sort
  LINK_DEFAULT = "<span underline='single' underline_color='#06E' foreground='#06E' weight='normal'>"
  LINKHOVER_DEFAULT = "<span underline='single' underline_color='#039' foreground='#039' weight='normal'>"
  BANNER_DEFAULT, TITLE_DEFAULT, SUBTITLE_DEFAULT, TAGLINE_DEFAULT, CAPTION_DEFAULT, PARA_DEFAULT, INSCRIPTION_DEFAULT, IMAGE_DEFAULT = 
    {}, {}, {}, {}, {}, {}, {}, {}
  ROTATE = [Gdk::Pixbuf::ROTATE_NONE, Gdk::Pixbuf::ROTATE_CLOCKWISE, Gdk::Pixbuf::ROTATE_UPSIDEDOWN, Gdk::Pixbuf::ROTATE_COUNTERCLOCKWISE]
  VERSION = IO.read(File.join(DIR, '../VERSION')).chomp
  BASIC_ATTRIBUTES_DEFAULT = {left: 0, top: 0, width: 0, height: 0, angle: 0, curve: 0}
  SLOT_ATTRIBUTES_DEFAULT = {left: nil, top: nil, width: 1.0, height: 0}
  KEY_NAMES = %w[exclam quotedbl numbersign dollar percent ampersand apostrophe 
    parenleft parenright minus asciicircum backslash equal asciitilde bar grave at braceleft 
    bracketleft braceright bracketright plus asterisk semicolon colon less greater question 
    comma period slash backslash space]
  LINECAP = {curve: Cairo::LineCap::ROUND, rect: Cairo::LineCap::BUTT, project: Cairo::LineCap::SQUARE}
  SPAN_FORM = {emphasis: :style, family: :font_family, weight: :weight, rise: :rise, 
    strikethrough: :strikethrough, strikecolor: :strikethrough_color, underline: :underline, undercolor: :underline_color}
  WRAP = {word: Pango::WRAP_WORD, char: Pango::WRAP_CHAR, trim: Pango::ELLIPSIZE_END}
  FONT_SIZE = {"xx-small" => 0.57, "x-small" => 0.64, "small" => 0.83, "medium" => 1.0, "large" => 1.2, "x-large" => 1.43, "xx-large" => 1.73}
  COLORS = {}
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
require_relative 'shoes/mask'
require_relative 'shoes/widget'
require_relative 'shoes/url'
require_relative 'shoes/style'
require_relative 'shoes/projector'
require_relative 'shoes/download'
require_relative 'shoes/manual'
require_relative 'shoes/minitar'
require_relative 'shoes/shy'

require_relative 'plugins/systray'
require_relative 'plugins/thread'
require_relative 'plugins/httpd'
require_relative 'plugins/treeview'
require_relative 'plugins/code_box'
require_relative 'plugins/video'

autoload :ChipMunk, File.join(Shoes::DIR, 'ext/chipmunk')
autoload :Bloops, File.join(Shoes::DIR, 'ext/bloops')
autoload :Projector, File.join(Shoes::DIR, 'ext/projector')
autoload :HH, File.join(Shoes::DIR, 'ext/highlighter')

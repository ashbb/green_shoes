module Shoes
  class << self
    attr_accessor :canvas, :cslot
    attr_reader :contents
  end

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    @cslot = self
    @contents = []
    Flow.new basic_attributes

    win = Gtk::Window.new

    class << self; self end.class_eval do
      define_method(:width){win.size[0]}
      define_method(:height){win.size[1]}
    end

    win.icon = Gdk::Pixbuf.new File.join(DIR, 'static/gshoes-icon.png')
    win.title = args[:title]
    win.set_default_size args[:width], args[:height]
    win.signal_connect "destroy" do
      Gtk.main_quit
      File.delete TMP_PNG_FILE
    end

    @canvas = Gtk::Layout.new
    win.add @canvas

    background white

    instance_eval &blk
    contents_alignment @contents
    
    win.show_all
    Gtk.main
  end

  def self.stack args={}, &blk
    Stack.new basic_attributes(args), &blk
  end

  def self.flow args={}, &blk
    Flow.new basic_attributes(args), &blk
  end
  
  def self.para *msg
    args = msg.last.class == Hash ? msg.pop : {}
    args = basic_attributes args
    msg = msg.join
    da = Gtk::DrawingArea.new
    da.set_size_request 8*msg.length, 18
    da.signal_connect "expose-event" do |widget, event|
      context = widget.window.create_cairo_context
      layout = context.create_pango_layout
      layout.text = msg
      context.show_pango_layout layout
      context.show_page
    end
    @canvas.put da, args[:left], args[:top]
    da.show_now
    args[:real] = da
    Para.new args
  end

  def self.image name, args={}
    args = basic_attributes args
    img = Gtk::Image.new name
    @canvas.put img, args[:left], args[:top]
    img.show_now
    args[:real] = img
    Image.new args
  end

  def self.button name, args={}, &blk
    args = basic_attributes args
    b = Gtk::Button.new name
    b.signal_connect "clicked", &blk if blk
    @canvas.put b, args[:left], args[:top]
    b.show_now
    args[:real], args[:text] = b, name
    Button.new args
  end

  def self.animate n=10, &blk
    n, i = 1000 / n, 0
    a = Anim.new
    GLib::Timeout.add(n){blk[i = a.pause? ? i : i+1]; a.continue?}
    a
  end

  def self.oval *attrs
    args = attrs.last.class == Hash ? attrs.pop : {}
    case attrs.length
      when 0, 1
      when 2; args[:left], args[:top] = attrs
      when 3; args[:left], args[:top], args[:radius] = attrs
      else args[:left], args[:top], args[:width], args[:height] = attrs
    end
    args = basic_attributes args
    args[:width].zero? ? (args[:width] = args[:radius] * 2) : (args[:radius] = args[:width]/2.0)
    args[:height] = args[:width] if args[:height].zero? 
    surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, args[:width], args[:height]
    context = Cairo::Context.new surface
    context.scale(1,  args[:height]/args[:width].to_f)
    context.arc args[:radius], args[:radius], args[:radius], 0, 2*Math::PI
    context.set_source_rgba *(args[:fill] or fill or black)
    context.fill

    context.set_source_rgba *(args[:stroke] or stroke or black)
    context.set_line_width args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
    context.arc args[:radius], args[:radius], args[:radius]-args[:strokewidth]/2.0, 0, 2*Math::PI
    context.stroke

    img = create_tmp_png surface
    @canvas.put img, args[:left], args[:top]
    img.show_now
    args[:real] = img
    Shape.new args
  end

  def self.rgb r, g, b, l=1.0
    (r < 1 and g < 1 and b < 1) ? [r, g, b, l] : [r/255.0, g/255.0, b/255.0, l]
  end

  %w[fill stroke strokewidth].each do |name|
    eval "def self.#{name} #{name}=nil; #{name} ? @#{name}=#{name} : @#{name} end"
  end

  def self.background pat
    surface = Cairo::ImageSurface.new Cairo::FORMAT_ARGB32, width, height
    context = Cairo::Context.new surface
    context.rectangle 0, 0, width, height
    context.set_source_rgba *(pat)
    context.fill
    img = create_tmp_png surface
    @canvas.put img, 0, 0
    img.show_now
  end
end

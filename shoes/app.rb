module Shoes
  class << self
    attr_accessor :canvas
  end

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    win = Gtk::Window.new
    win.icon = Gdk::Pixbuf.new 'static/gshoes-icon.png'
    win.title = args[:title]
    win.set_default_size args[:width], args[:height]
    win.signal_connect("destroy"){Gtk.main_quit}

    @canvas = Gtk::Fixed.new
    win.add @canvas

    instance_eval &blk

    win.show_all
    Gtk.main
  end

  def self.para *msg
    args = msg.pop if msg.last.class == Hash
    args[:left] ||= 0
    args[:top] ||= 0
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
    Para.new da
  end

  def self.image name, args={}
    args[:left] ||= 0
    args[:top] ||= 0
    da = Gtk::DrawingArea.new
    da.set_size_request 150, 150
    da.signal_connect "expose-event" do |widget, event|
      context = widget.window.create_cairo_context
      pixbuf = Gdk::Pixbuf.new name
      context.set_source_pixbuf pixbuf, 0, 0
      context.paint
    end
    @canvas.put da, args[:left], args[:top]
    da.show_now
    Image.new da
  end

  def self.button name, args={}, &blk
    args[:left] ||= 0
    args[:top] ||= 0
    b = Gtk::Button.new name
    b.signal_connect "clicked", &blk
    @canvas.put b, args[:left], args[:top]
    b.show_now
    Button.new b
  end

  def self.animate n=10, &blk
    n, i = 1000 / n, 0
    a = Anim.new
    GLib::Timeout.add(n){blk[i = a.pause? ? i : i+1]; a.continue?}
    a
  end
end

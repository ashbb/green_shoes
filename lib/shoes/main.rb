class Shoes
  include Types
  @apps = []

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    args[:left] ||= 0
    args[:top] ||= 0

    app = App.new args
    @apps.push app

    app.top_slot = Flow.new app.slot_attributes(app: app, left: 0, top: 0)

    win = Gtk::Window.new
    win.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
    win.title = args[:title]
    win.set_default_size args[:width], args[:height]

    style = win.style
    style.set_bg Gtk::STATE_NORMAL, 65535, 65535, 65535

    class << app; self end.class_eval do
      define_method(:width){win.size[0]}
      define_method(:height){win.size[1]}
    end

    win.set_events Gdk::Event::BUTTON_PRESS_MASK | Gdk::Event::BUTTON_RELEASE_MASK | Gdk::Event::POINTER_MOTION_MASK

    win.signal_connect("delete-event") do
      false
    end

    win.signal_connect "destroy" do
      Gtk.main_quit
      File.delete TMP_PNG_FILE if File.exist? TMP_PNG_FILE
    end if @apps.size == 1

    win.signal_connect("button_press_event") do |w, e|
      app.mouse_button = e.button
      app.mouse_pos = app.win.pointer
      mouse_click_control app
      mouse_link_control app
    end
    
    win.signal_connect("button_release_event") do
      app.mouse_button = 0
      app.mouse_pos = app.win.pointer
      mouse_release_control app
    end

    win.signal_connect("motion_notify_event") do
      app.mouse_pos = app.win.pointer
      mouse_motion_control app
    end

    app.canvas = Gtk::Layout.new
    win.add app.canvas
    app.canvas.style = style
    app.win = win

    app.instance_eval &blk if blk

    Gtk.timeout_add 100 do
      if size_allocated? app
        call_back_procs app
        app.width_pre, app.height_pre = app.width, app.height
      end
      show_hide_control app
      set_cursor_type app
      true
    end

    call_back_procs app
    
    win.show_all
    @apps.pop
    Gtk.main if @apps.empty?
    app
  end
end

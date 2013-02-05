class Range 
  def rand 
    conv = (Integer === self.end && Integer === self.begin ? :to_i : :to_f)
    ((Kernel.rand * (self.end - self.begin)) + self.begin).send(conv) 
  end 
end

# GLib produces stack trace for all exceptions.
# Don't spit this out if system exit is called - just exit.
module GLib
  module_function
  def exit_application(exception, status)
    raise exception if exception.class.name == "SystemExit"
    super(exception, status)
  end
end

class Object
  include Types
  def alert msg, options={:block => true}
    $dde = true
    dialog = Gtk::MessageDialog.new(
      get_win,
      Gtk::Dialog::MODAL,
      Gtk::MessageDialog::INFO,
      Gtk::MessageDialog::BUTTONS_OK,
      msg.to_s
    )
    dialog.title = options.has_key?(:title) ? options[:title] : "Green Shoes says:"
    if options[:block]
      dialog.run
      dialog.destroy
    else
      dialog.signal_connect("response"){ dialog.destroy }
      dialog.show
    end
  end

  def confirm msg
    $dde = true
    dialog = Gtk::Dialog.new(
      "Green Shoes asks:", 
      get_win,
      Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT],
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT]
    )
    dialog.vbox.add Gtk::Label.new msg
    dialog.set_size_request 300, 100
    dialog.show_all
    ret = dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? true : false
    dialog.destroy
    ret
  end

  def ask msg, args={}
    $dde = true
    dialog = Gtk::Dialog.new(
      "Green Shoes asks:", 
      get_win,
      Gtk::Dialog::MODAL | Gtk::Dialog::DESTROY_WITH_PARENT,
      [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT],
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT]
    )
    dialog.vbox.add Gtk::Label.new msg
    dialog.vbox.add(el = Gtk::Entry.new)
    el.visibility = false if args[:secret]
    dialog.set_size_request 300, 100
    dialog.show_all
    ret = dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? el.text : nil
    dialog.destroy
    ret
  end
  
  def ask_open_file path = nil
    dialog_chooser "Open File...", Gtk::FileChooser::ACTION_OPEN, Gtk::Stock::OPEN, path
  end

  def ask_save_file path = nil
    dialog_chooser "Save File...", Gtk::FileChooser::ACTION_SAVE, Gtk::Stock::SAVE, path
  end

  def ask_open_folder path = nil
    dialog_chooser "Open Folder...", Gtk::FileChooser::ACTION_SELECT_FOLDER, Gtk::Stock::OPEN, path
  end

  def ask_save_folder path = nil
    dialog_chooser "Save Folder...", Gtk::FileChooser::ACTION_CREATE_FOLDER, Gtk::Stock::SAVE, path
  end

  def dialog_chooser title, action, button, path
    $dde = true
    dialog = Gtk::FileChooserDialog.new(
      title,
      get_win,
      action,
      nil,
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
      [button, Gtk::Dialog::RESPONSE_ACCEPT]
    )
    dialog.current_folder = path if path
    ret = dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? dialog.filename : nil
    dialog.destroy
    ret
  end

  def ask_color title = 'Pick a color...'
    $dde = true
    dialog = Gtk::ColorSelectionDialog.new title
    dialog.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
    dialog.run
    ret = dialog.colorsel.current_color.to_a.map{|c| c / 65535.0}
    dialog.destroy
    ret
  end

  def to_s
    super.gsub '<', '&lt;'
  end

  def get_win
    Gtk::Window.new.tap do |s|
      s.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
    end
  end
end

# Define exit handler, close Gtk win and delete temporary Shoes image
at_exit do
  Gtk.main_quit
  File.delete Shoes::TMP_PNG_FILE if File.exist? Shoes::TMP_PNG_FILE
end

class String
  def mindex str
    n, links = 0, []
    loop do
      break unless n= self.index(str, n)
      links << n
      n += 1
    end
    links
  end
end

class Array
  def / len
    a = []
    each_with_index do |x, i|
      a << [] if i % len == 0
      a.last << x
    end
    a
  end

  def dark?
    r, g, b = self
    r + g + b < 0x55 * 3
  end

  def light?
    r, g, b = self
    r + g + b > 0xAA * 3
  end

  alias :_clear :clear
  def clear
    self.each{|e| e.clear if e.class.method_defined? :clear}
    _clear
  end

  def clear_all
    self.each &:clear_all
  end

  alias :_to_s :to_s
  def to_s
    self.map(&:to_s)._to_s
  end
end

class NilClass
  def clear; end
end

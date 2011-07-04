class Range 
  def rand 
    conv = (Integer === self.end && Integer === self.begin ? :to_i : :to_f)
    ((Kernel.rand * (self.end - self.begin)) + self.begin).send(conv) 
  end 
end

class Object
  include Types
  def alert msg
    dialog = Gtk::MessageDialog.new(
      get_win,
      Gtk::Dialog::MODAL,
      Gtk::MessageDialog::INFO,
      Gtk::MessageDialog::BUTTONS_OK,
      msg
    )
    dialog.title = "Green Shoes says:"
    dialog.run
    dialog.destroy
  end

  def confirm msg
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
  
  def ask_open_file
    dialog_chooser "Open File...", Gtk::FileChooser::ACTION_OPEN, Gtk::Stock::OPEN
  end

  def ask_save_file
    dialog_chooser "Save File...", Gtk::FileChooser::ACTION_SAVE, Gtk::Stock::SAVE
  end

  def ask_open_folder
    dialog_chooser "Open Folder...", Gtk::FileChooser::ACTION_SELECT_FOLDER, Gtk::Stock::OPEN
  end

  def ask_save_folder
    dialog_chooser "Save Folder...", Gtk::FileChooser::ACTION_CREATE_FOLDER, Gtk::Stock::SAVE
  end

  def dialog_chooser title, action, button
    dialog = Gtk::FileChooserDialog.new(
      title,
      get_win,
      action,
      nil,
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
      [button, Gtk::Dialog::RESPONSE_ACCEPT]
    )
    ret = dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? dialog.filename : nil
    dialog.destroy
    ret
  end

  def ask_color title = 'Pick a color...'
    dialog = Gtk::ColorSelectionDialog.new title
    dialog.icon = Gdk::Pixbuf.new File.join(DIR, '../static/gshoes-icon.png')
    dialog.run
    ret = dialog.colorsel.current_color.to_a.map{|c| c / 65535.0}
    dialog.destroy
    ret
  end

  def exit
    Shoes.APPS.length.times {|i| timer(0.01*i){Gtk.main_quit}}
    File.delete Shoes::TMP_PNG_FILE if File.exist? Shoes::TMP_PNG_FILE
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

  def clear
    self.each &:clear
  end

  def clear_all
    self.each &:clear_all
  end
end

class NilClass
  def clear; end
end

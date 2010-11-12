class Range 
  def rand 
    conv = (Integer === self.end && Integer === self.begin ? :to_i : :to_f)
    ((Kernel.rand * (self.end - self.begin)) + self.begin).send(conv) 
  end 
end

class Object
  def alert msg
    dialog = Gtk::MessageDialog.new(
      app.win,
      Gtk::Dialog::MODAL,
      Gtk::MessageDialog::INFO,
      Gtk::MessageDialog::BUTTONS_OK,
      msg
    )
    dialog.title = "Shoes says:"
    dialog.run
    dialog.destroy
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

class Shoes
  class App
    def code_box args={}
      require 'gtksourceview2'
      args = basic_attributes args

      args[:width]  = 400 if args[:width].zero?
      args[:height] = 300 if args[:height].zero?

      (change_proc = args[:change]; args.delete :change) if args[:change]
      sv = Gtk::SourceView.new
      sv.show_line_numbers = true
      sv.insert_spaces_instead_of_tabs = true
      sv.smart_home_end = Gtk::SourceView::SMART_HOME_END_ALWAYS
      sv.tab_width = 2
      sv.buffer.text = args[:text].to_s
      sv.buffer.language = Gtk::SourceLanguageManager.new.get_language('ruby')
      sv.buffer.highlight_syntax = true
      sv.modify_font(Pango::FontDescription.new(args[:font])) if args[:font]

      cb = Gtk::ScrolledWindow.new
      cb.set_size_request args[:width], args[:height]
      cb.set_policy Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC
      cb.set_shadow_type Gtk::SHADOW_IN
      cb.add sv

      @canvas.put cb, args[:left], args[:top]

      cb.show_all
      args[:real], args[:app], args[:textview] = cb, self, sv
      CodeBox.new(args).tap do |s|
        s.change &change_proc
        sv.buffer.signal_connect "changed" do
          yield s
        end if block_given?
      end
    end
  end

  class CodeBox < EditBox; end
end

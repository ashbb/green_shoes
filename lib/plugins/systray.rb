require 'gtk2'



############################ SysTray ###############################


module Gtk
	class SysTray < StatusIcon 
	  def initialize(window,title="title?",config)
		$statusIcon=self
		@popup_tray=Menu.new
		@checkMenu={}
		file= (config[:icon] && File.exist?(config[:icon])) ? config[:icon] : nil
		alert("No icon defined for systray (or unknown file)") if ! file 
		config.each do |label,proc|
			if Proc === proc 
			  case label
			  when  /^\+/
			    bshow = CheckMenuItem.new(label[1..-1])
				@checkMenu[bshow]=bshow
			    bshow.signal_connect("toggled") { |w|	
				   proc.call(! w.active?) 
				}  
				#TODO : get checkButton state to application closure, set state with closure return value
			  when  /^-+/
   			    bshow = SeparatorMenuItem.new
			  else
   			    bshow = MenuItem.new(label)
			    bshow.signal_connect("activate") { proc.call(window.visible?) }  
				#TODO : icon in face of button
			  end
			  @popup_tray.append(bshow) 
			end
		end
		if config[:quit]
			@bquit_tray=ImageMenuItem.new(Stock::QUIT)
			@bquit_tray.signal_connect("activate"){window.main_quit}
			@popup_tray.append(SeparatorMenuItem.new)
			@popup_tray.append(@bquit_tray)
		end
		@popup_tray.show_all
		
		super()
		self.pixbuf=if file then  Gdk::Pixbuf.new(file) ;else nil ; end
		self.tooltip=title||""
		self.signal_connect('activate'){ window.visible? ? window.hide : window.show }
		self.signal_connect('popup-menu'){|tray, button, time|
		  @popup_tray.popup(nil, nil, button, time)
		}
	  end
	end
end
=begin
    syst_icon  HAPPY_ICON,
    syst_add_button "Edit configuration"  {|state| edit_conf() } ,
	syst_add_button "Execute Test"        {|state| $win.show; update(true) },
	syst_add_sepratator
	syst_add_check "Option"               {|state|  },
	syst_quit_button true
=end
class Shoes
	class App
		def systray 
		    @systray_config={}
			yield
			@systray=::Gtk::SysTray.new(self.win,@owner.instance_variable_get('@title'),@systray_config)
		end 
		def syst_icon(file)		         @systray_config[:icon]=file     ; end
		def syst_add_button(label,&prc)  @systray_config[label]=prc     ; end
		def syst_add_sepratator()        @systray_config["--#{@systray_config.size}"]= proc {} ; end
		def syst_add_check(label,&prc)   @systray_config["+"+label]=prc ; end
		def syst_quit_button(yes)       @systray_config[:quit]=yes       ; end
		def systray_setup(config)
			@systray=::Gtk::SysTray.new(self.win,@owner.instance_variable_get('@title'),config)
		end 
		def show_app()
			win.deiconify	
			win.show 
		end
		def hide_app
			win.iconify
			win.hide
		end

		def close_dialog
			win.destroy
			Shoes.APPS.delete app
		end 
	end
end

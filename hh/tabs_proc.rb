module HH
  module TabsProc
    def mk_tabs_proc tabs
      @new_proc_eles = []
      @new_proc_eles << eb = edit_box(width: 400, height: 440).hide.move(58, 20)
      @new_proc_eles << button('load'){
	file = ask_open_file
        file = File.read(file) if file
        eb.text = file
      }.hide.move(337, 460)
      @new_proc_eles << button('run'){instance_eval eb.text}.hide.move(381, 460)
      @new_proc_eles << button('close'){@new_proc_eles.each &:hide}.hide.move(420, 460)
    end
    
    def new_proc
      @new_proc_eles.each &:show
    end

    def quit_proc
      exit
    end

    def method_missing m
      alert 'Not implemented yet'
    end
  end
end

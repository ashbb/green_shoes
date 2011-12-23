#####################################################################################
#          S U R V E I L L A N C E / ruby-shoes tools for watching home servers
#####################################################################################

$PERIODE=10
$config=[
 ["Serveur Search","geturl","http://localhost:8080"],
 ["Shares"        ,"dir"   ,"D:/"],
 ["Codeur"        ,"tcpping","10.177.235.202:80"],
 ["Proxy"         ,"geturl","http://10.153.32.75:80"],
]
ENV.delete('proxy_http')

##__EEND__##################################################################################
require 'green_shoes'
#require 'green_shoes' 

require 'tmpdir'
require 'open-uri' 


dsrc=File.dirname(__FILE__)
HAPPY_ICON   ="#{dsrc}/face-smile-big.png"
UNHAPPY_ICON ="#{dsrc}/face-crying.png"
 

$CONFIG_FILE="#{Dir.tmpdir}/surv_config.rb"
$toBeFirstEdit=false
unless File.exist?($CONFIG_FILE) 
 content=File.read(__FILE__).split(/##__EEND__/).first
 File.open($CONFIG_FILE,"w") { |f| f.write(content)}
 puts "configuration file #{$CONFIG_FILE} created !"
 $toBeFirstEdit=true
end




$errorDetected=true

################## Dialog for edit configuration ####################
class ::Shoes
	class App
		def edit_conf()
		 ::Shoes.app({:title=> "Config",:width=>600,:height=>650}) do
			t= File.read($CONFIG_FILE)
			stack do
				flow :width=>1.0 do
				    background "#C0C0C0".."#A0A0A0"
					para "This application do periodique request on LAN. You can: "
					para "<b>*</b> specifies in $config the list of request : name,method, parameters."
					para "<b>*</b> define periode in $periode (warning of memory leaks)"
					para "This data are saved in file \n '#{$CONFIG_FILE}'."
					para
				end
				@edit_box=edit_box( {:width=>1.0,:height=>370, :scroll=> true, :text=>t, :font => "Courier"} )
				flow :width=> 400 do
					button "Save",:width => 200 do
					begin
					  eval @edit_box.text 
					  $app.update(true)
					  File.open($CONFIG_FILE,"w") { |f| f.write(@edit_box.text)}			
					  alert("Tested and saved!")
					rescue Exception=> e
					 alert  "Syntaxe Error : #{$!}"
					end
					end
					button "Quit",:width => 200 do
					  self.close_dialog
					end
				end
			end
		 end
		end
		p 2
		#-----------------  Surveillances  actions --------------------------------
		# do_<ACTIONNAME>() >> raise Exception if NOK

		def do_geturl(param)
			open(param).close
		end
		def do_dir(param)
			raise "not found" if ! File.directory?(param)
		end
		def do_snmp(param)
			  raise("not implemnted!")
		end
		def do_tcpping(param)
			  ip,port=param.split(/:/)
			  raise("ping") unless tping(ip,port.to_i,0.5)
		end

		def tping(host,port, timeout=5)
		   s=nil
		   begin
				s = TCPSocket.new(host, port.to_s)
				return(true)
		   rescue Exception => e
			   return false
		   ensure
				(s.close if s ) rescue nil
		   end
		end
		#--------------------------- Surveillance Engine ---------------------------
		# actions runs in paralleles, result is sorted by config order
		# a queue is used for collect actions results (array are not thread-safe)
		p 3
		def do_surveillance(expand)
			no0=0
			lth=[]
			queue=Queue.new
			$config.each do |text0,comm0,param0|
			  lth<<Thread.new(text0,comm0,param0,no0) do |text,comm,param,no|
				begin
					send("do_#{comm}",param)
					queue.push([no,false,text])
				rescue				
					queue.push([no,true,text])
					puts $!.to_s + " " + $!.backtrace.join("\n    ")
				end
			  end
			  no0+=1
			end
			lth.map(&:join)
			r=[]
			while queue.size>0 && (m=queue.pop)
				r << m 
			end
			return ( r.sort { |a,b| a[0]<=>b[0] } )
		end



		def update(expand) 
			Thread.new {
			  now=Time.now.to_f
			  r=do_surveillance(expand) rescue p($!) ;
			  invoke_in_shoes_mainloop { do_raffraichissement(r,expand,now) }
			 }
		end
		def do_raffraichissement(r,expand,now)
			nbError=0
		    app.clear do 
				border "#000000"
				r.each do |mess|
				    no,err=*mess
					flow {
						background( !err ?  ("#40A0A0".."#70C0C0") : ("#F0A0A0".."#F0C0C0") )
						para"  "+$config[no][0] + (err ? " : NOK" : " : ok")
						nbError+=1 if err
					} if err or expand
				end
				flow {
					background  "#B0F0F0".."#A0F0F0" 
					para  "  "+Time.now.to_s.split(/ /)[1] + "  ("+((Time.now.to_f-now)*1000).round.to_s+" ms)"
				}
			end
			# mettre en avant-plan la fenetre si detection d'apparition d'erreur(s)
			if nbError>0	
				if ! $errorDetected
					$statusIcon.blinking=true
					$statusIcon.visible=true
					$statusIcon.file=UNHAPPY_ICON
					$win.show
					$win.iconify
					$win.deiconify
					$errorDetected=true
				end
			else
				if  $errorDetected
					$statusIcon.blinking=false
					$errorDetected=false
					$statusIcon.file=HAPPY_ICON
				end
				$win.hide if ! expand
			end
			h=24*(1+(expand ? $config.size : nbError))
		    $win.default_height=h
		    #$win.move(1080,960-h) : TODO: get screen-size...
		    $win.move(20,20)
		end   		
	end
end

$statusIcon=nil
$win=nil 
$p={}
$h=(($config.size+1)*24)
::Shoes.app :title=>"Surveillance", :left=>-1, :top=>-1, :width => 200, :height => $h  do
  $app=self
  define_async_thread_invoker()

  font "Arial"
  $win=win
  background  "#40A0A0".."#A0F0F0" 
  border black
  @st=stack(:width=> 1.0 , :height => 1.0) { border black }
  every($PERIODE) { update(false)  }
  click    { @st.clear ;  timer(0.01) { update(true) } }  
  win.set_decorated(false)
  #win.move(1080,960-$h)
  win.move(20,20)

  systray do
    syst_icon  HAPPY_ICON
    syst_add_button "Edit configuration"  do |state| edit_conf() end
	syst_add_button "Execute Test"        do |state| $win.show; update(true) end
	syst_add_sepratator
	syst_add_check "Option"               do |state| alert("Test checkButon: " +state.to_s)  end
	syst_quit_button true
  end

  web_server(9990,{
       "/"        => proc {|app| 	
					   ret=do_surveillance(true).map { |mess| no,err,text=*mess ; text.split(/\b*:\b*/) }
					   @ws.to_tableb(ret) { |a| [a[0]," : ",a[1]] }
       },
       "/config"  => proc {|app| @ws.to_tableb($config) { |a| a  }},
       "/stop"    => proc {|app| Thread.new { sleep(1) ; exit!} ; "..."},
       "/show"   => proc {|app| Thread.new { break ; $win.show ; $win.deiconify ; } ; "ok"},# break!!! :  don't gtk/shoes stuff in none main thread...
	   :template  => proc { |body| "<html><head></head><body><h2><center>Surveillance @ "+Time.now.to_s+"</center></h2><hr>"+@html_menu+"<hr>"+body + "<hr></body></html>" },
	   :menu      => { "Status"=> "/" , "Config" => "/config" , "Exit" => "/stop", "Home" => "http://localhost"}
  })

  edit_conf if $toBeFirstEdit
  update(true)
end

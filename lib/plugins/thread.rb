require 'thread'

class Object
  def invoke_in_shoes_mainloop(&blk)
    return unless defined?($__shoes_app__)
    return unless Shoes::App===$__shoes_app__
	$__shoes_app__.get_queue().push( blk )
  end
end

class Shoes
 class App
	def get_queue()
	   @queue=Queue.new if ! defined?(@queue)
	   @queue
	end
	def define_async_thread_invoker(period=0.1)
	   $__shoes_app__=self
	   @queue=Queue.new if ! defined?(@queue)
	   every(period) do
	      while @queue.size>0
		    instance_eval  &@queue.pop
		  end
	   end
	end 
  end
end


if defined?(WebserverRoot)
	class Shoes
	 class App
		def web_server(port=9908,config={}) 
			@ws=WebserverRoot.new(port,"/","green-shoes",10,300, {})
			@html_menu="<div>"+config.map {|label,proc| "<a href='%s'>%s</a>" % [label,label.size>1 ? label[1..-1].capitalize : "Home"] }.join(" ")+"</div>"
			lm=[]
			config.each { |key,proc| 
				case key
					when String
					lm << [key,key.gsub(/\//,"")]
					@ws.serve(key) {
					   [200,".html",@template_proc.call(proc.call(self))]
					}
					when :template
					   @template_proc=proc
					when :menu
					   @html_menu="<div>"+proc.map {|label,href| "[<a href='%s'>%s</a>]" % [href,label] }.join(" ")+"</div>"
					else
					  raise("option web serveur unknown : <#{key}>")
				end
			}
			if ! config[:menu]
				@html_menu="<hr><div>"+lm.map {|href,label| "<a href='%s'>%s</a>" % [href,label.size>1 ? label[1..-1].capitalize : "Home"] }.join(" ")+"</div>"
			end
			if ! config[:template]
				@template_proc= proc {|body| "<html><body><center><h2> #{Time.now}</h2></center>"+@html_menu+"<hr>"+body+"<hr></body></html>"}
			end
			puts "  WebServer ready on http://host:#{port}/"
			@ws
		end
	 end
	end
end
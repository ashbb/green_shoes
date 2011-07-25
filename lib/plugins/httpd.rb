require 'socket'
require 'thread'
require 'timeout' 


#################### Tiny embeded webserver
class WebserverAbstract
  def logg(*args)  @cb_log && @cb_log.call(@name,*args) end
  def info(txt) ; logg("nw>i>",txt) ;  end
  def error(txt) ; logg("nw>e>",txt) ; end
  def unescape(string) ; string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2}))/n) { [$1.delete('%')].pack('H*') } ;  end
  def escape(string) ; string.gsub(/([^ \/a-zA-Z0-9_.-]+)/) { '%' + $1.unpack('H2' * $1.size).join('%').upcase }.tr(' ', '+');  end
  def hescape(string) ;  escape(string.gsub("/./","/").gsub("//","/")) ; end
  def observe(sleeping,delta)
	@tho=Thread.new do loop do
	  sleep(sleeping) 
	  nowDelta=Time.now-delta
	  l=@th.select { |th,tm| (tm[0]<nowDelta) }
	  l.each { |th,tm| info("killing thread") ; th.kill; @th.delete(th)  ; tm[1].close rescue nil }
	end ; end
  end
  def initialize(port,root,name,cadence,timeout,options)
    @cb_log= options["logg"] 
    @last_mtime=File.mtime(__FILE__)
	@port=port
	@root=root
	@name=name
	@rootd=root[-1,1]=="/" ? root : root+"/" 
	@timeout=timeout
	@th={}
	@cb={}
	@redirect={}
	@server = TCPServer.new('0.0.0.0', @port)
	@server.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
	info(" serveur http #{port} on #{@rootd} ready!")
	observe(cadence,timeout*2)
	@thm=Thread.new {
		loop { begin
		  while (session = @server.accept)
		     run(session)
		  end
		rescue
		  error($!.to_s)
		  session.close raise nil
		end
		sleep(10); info("restart accept")
		}
	}
  end
  def run(session)
	if ! File.exists?(@root)
	  sendError(session,500,txt="root directory unknown: #{@root}") 
	else
		Thread.new(session) do |sess|
		   @th[Thread.current]=[Time.now,sess]
		   request(sess) 
		   @th.delete(Thread.current) 
		end
	end
  end
  def serve(uri,&blk)
	@cb[uri] = blk
  end  
  def request(session)
	  request = session.gets
	  uri = (request.split(/\s+/)+['','',''])[1] 
	  #info uri
	  service,param,*bidon=(uri+"?").split(/\?/)
	  params=Hash[*(param.split(/#/)[0].split(/[=&]/))] rescue {}
	  params.each { |k,v| params[k]=unescape(v) }
	  uri=unescape(service)[1..-1].gsub(/\.\./,"")
	  userpass=nil
	  if (buri=uri.split(/@/)).size>1
		uri=buri[1..-1].join("@")
		userpass=buri[0].split(/:/)
	  end
	  do_service(session,request,uri,userpass,params)
  rescue
	error("Error Web get on #{request}: \n #{$!.to_s} \n #{$!.backtrace.join("\n     ")}" ) rescue nil
	session.write "HTTP/1.1 501 NOK\r\nContent-type: text/html\r\n\r\n<html><head><title>WS</title></head><body>Error : #{$!}" rescue nil
  ensure
	session.close rescue nil
  end  
  def redirect(o,d)
   @redirect[o]=d
  end  
  def do_service(session,request,service,user_passwd,params)
    logg(session.peeraddr.last,request) 
	redir=@redirect["/"+service]
	service=redir.gsub(/^\//,"") if @redirect[redir]
	aservice=to_absolute(service)
	if redir &&  ! @redirect[redir] 
	  do_service(session,request,redir.gsub(/^\//,""),user_passwd,params)
	elsif @cb["/"+service]
	  begin
	   code,type,data= @cb["/"+service].call(params)
	   if code==0 && data != '/'+service
		  do_service(session,request,data[1..-1],user_passwd,params)
	   else
		 code==200 ?  sendData(session,type,data) : sendError(session,code,data)
	   end
	  rescue
	   logg session.peeraddr.last,"Error in get /#{service} : #{$!}"
	   sendError(session,501,$!.to_s)
	  end
	elsif service =~ /^stop/ 
	  sendData(session,".html","Stopping...");	   
	  Thread.new() { sleep(0.1); stop_browser()  }
	elsif File.directory?(aservice)
	  sendData(session,".html",makeIndex(aservice))
	elsif File.exists?(aservice)
	  sendFile(session,aservice)
	else
	  info("unknown request serv=#{service} params=#{params.inspect} #{File.exists?(service)}")
	  sendError(session,500);
	end
  end
  def stop_browser
	info "exit on web demand !"
	@serveur.close rescue nil
	[@tho,@thm].each { |th| th.kill }
  end
  def makeIndex(adir)
    dir=to_relative(adir)
	dirs,files=Dir.glob(adir==@rootd ? "#{@rootd}*" : "#{adir}/*").sort.partition { |f| File.directory?(f)}
	updir = hescape(  dir.split(/\//)[0..-2].join("/")) 
	updir="/" if updir.length==0
	up=(dir!="/") ? "<input type='button' onclick='location.href=\"#{updir}\"' value='Parent'>" : ""
	"<html><head><title>#{dir}</title></head>\n<body><h3><center>#{@name} : #{dir[0..-1]}</center></h3>\n<hr>#{up}<br>#{to_table(dirs.map {|s| " <a href='#{hescape(to_relative(s))}'>"+File.basename(s)+"/"+"</a>\n"})}<hr>#{to_tableb(files) {|f| [" <a href='#{hescape(to_relative(f))}'>"+File.basename(f)+"</a>",n3(File.size(f)),File.mtime(f).strftime("%d/%m/%Y %H:%M:%S")]}}</body></html>"
  end  
  def to_relative(f)  f.gsub(/^#{@rootd}/,"/") end
  def to_absolute(f)  "#{@rootd}#{f.gsub(/^\//,'')}" end
  def n3(n)
     u=" B"
     if n> 10000000
	    n=n/(1024*1024)
		u=" MB"
     elsif n> 100000
	    n=n/1024
		u=" KB"
	 end
    "<div style='width:100px;text-align:right;'>#{(n.round.to_i.to_s.reverse.gsub(/(\d\d\d)(?=\d)/,'\1 ' ).reverse) +u} | </div>"
  end
  def to_table(l)
	 "<table><tr>#{l.map {|s| "<td>#{s}</td>"}.join("</tr><tr>")}</tr></table>"
  end 
  def to_tableb(l,&bl)
	 "<table><tr>#{l.map {|s| "<td>#{bl.call(s).join("</td><td>")}</td>"}.join("</tr><tr>")}</tr></table>"
  end 
  def sendError(sock,no,txt=nil) 
	 if txt
	   txt="<html><body><code><pre></pre>#{txt}</code></body></html>"
	 end
	sock.write "HTTP/1.0 #{no} NOK\r\nContent-type: #{mime(".html")}\r\n\r\n <html><p>Error #{no} : #{txt}</p></html>"
  end
  def sendData(sock,type,content)
	sock.write "HTTP/1.0 200 OK\r\nContent-type: #{mime(type)}\r\nContent-size: #{content.size}\r\n\r\n"
	sock.write(content)
  end
  def sendFile(sock,filename)
  	s=File.size(filename)
  	if s < 0 || File.extname(filename).downcase==".lnk"
  		sendError(sock,500,"Error reading file #{filename} : (size=#{s})" )
  		return
  	end
	sock.write "HTTP/1.0 200 OK\r\nContent-type: #{mime(filename)}\r\nContent-size: #{File.size(filename)}\r\nLast-Modified: #{httpdate(File.mtime(filename))}\r\nDate: #{httpdate(Time.now)}\r\n\r\n"
	File.open(filename,"rb") do |f| 
	  f.binmode; sock.binmode; 
	  ( sock.write(f.read(32000)) while (! f.eof? && ! sock.closed?) ) rescue nil
	end
  end
  def httpdate( aTime ); (aTime||Time.now).gmtime.strftime( "%a, %d %b %Y %H:%M:%S GMT" ); end
  def mime(string)
	 MIME[string.split(/\./).last] || "application/octet-stream"
  end
  LICON="&#9728;&#9731;&#9742;&#9745;&#9745;&#9760;&#9763;&#9774;&#9786;&#9730;".split(/;/).map {|c| c+";"}
  MIME={"png" => "image/png", "gif" => "image/gif", "html" => "text/html","htm" => "text/html",
	"js" => "text/javascript" ,"css" => "text/css","jpeg" => "image/jpeg" ,"jpg" => "image/jpeg" ,
	"pdf"=> "application/pdf"   , "svg" => "image/svg+xml","svgz" => "image/svg+xml",
	"xml" => "text/xml"   ,"xsl" => "text/xml"   ,"bmp" => "image/bmp"  ,"txt" => "text/plain" ,
	"rb"  => "text/plain" ,"pas" => "text/plain" ,"tcl" => "text/plain" ,"java" => "text/plain" ,
	"c" => "text/plain" ,"h" => "text/plain" ,"cpp" => "text/plain", "xul" => "application/vnd.mozilla.xul+xml",
	"doc" => "application/msword", "docx" => "application/msword","dot"=> "application/msword",
	"xls" => "application/vnd.ms-excel","xla" => "application/vnd.ms-excel","xlt" => "application/vnd.ms-excel","xlsx" => "application/vnd.ms-excel",
	"ppt" => "application/vnd.ms-powerpoint",	"pptx" => "application/vnd.ms-powerpoint"
  } 
end # 161 loc webserver :)

class Webserver < WebserverAbstract
  def initialize(port=7080,cadence=10,timeout=120)
    super(port,Dir.getwd(),"",cadence,timeout)
  end
end 
class WebserverRoot < WebserverAbstract
  def initialize(port=7080,root=".",name="wwww",cadence=10,timeout=120,options={})
    super(port,root,name,cadence,timeout,options)
  end
end 


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

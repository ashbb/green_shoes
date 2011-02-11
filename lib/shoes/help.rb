class Manual < Shoes
  url '/', :index
  url '/manual/(\d+)', :index

  def index pnum = 0
    font LANG == 'ja' ? 'MS UI Gothic' : 'Arial'
    style Link, underline: false, weight: 'bold'
    style LinkHover, stroke: '#06E'
    self.scroll_top = 0
    table_of_contents.each{|toc| TOC << toc} if TOC.empty?
    manual *get_title_and_desc(pnum.to_i)
  end
  
  def get_title_and_desc pnum
    chapter, section = PNUMS[pnum]
    if section
      [pnum, DOCS[chapter][1][:sections][section][1][:title], 
      DOCS[chapter][1][:sections][section][1][:description], 
      DOCS[chapter][1][:sections][section][1][:methods]]
    else
      [pnum, DOCS[chapter][0], DOCS[chapter][1][:description], []]
    end
  end
  
  def table_of_contents
    PNUMS.map.with_index do |e, pnum|
      chapter, section = e
      title = section ? DOCS[chapter][1][:sections][section][1][:title] : DOCS[chapter][0]
      title = title.sub('The', '').split(' ').first
      TOC_LIST << [title, section]
      section ? ['   ', link(title){visit "/manual/#{pnum}"}, "\n"] : [link(fg(title, darkgreen)){visit "/manual/#{pnum}"}, "\n"]
    end.flatten
  end

  def manual pnum, docs_title, docs_description, docs_methods
    flow do
      background tr_color("#ddd")..white, angle: 90
      background black..green, height: 90
      para fg("The Green Shoes Manual #{VERSION}", gray), left: 120, top: 10
      title fg(docs_title, white), left: 120, top: 30, font: 'Coolvetica'
      image File.join(DIR, '../static/gshoes-icon.png'), left: 5, top: -12, width: 110, height: 110, nocontrol: true

      paras = mk_paras docs_description

      stack{para NL * 4}
      flow width: 0.2, margin_left: 10 do
        para *TOC
      end
        
      flow width: 0.8, margin: [10, 0, 20, 0] do
        show_page paras, true
        docs_methods.each do |m, d|
          flow do
            background rgb(60, 60, 60), curve: 5
            n = m.index("\u00BB")
            if n
              para '  ', fg(strong(m[0...n]), white), fg(strong(m[n..-1]), rgb(160, 160, 160))
            else
              para '  ', fg(strong(m), white)
            end
          end
          para
          show_page mk_paras(d.gsub('&', '\u0026'))
        end
        para link('top'){visit "/manual/0"}, "  ",
          link('prev'){visit "/manual/#{(pnum-1)%PEND}"}, "  ", 
          link('next'){visit "/manual/#{(pnum+1)%PEND}"}, "  ", 
          link('end'){visit "/manual/#{PEND-1}"}
      end
    end
  end

  def show_page paras, intro = false
    paras.each_with_index do |text, i|
      if text.index CODE_RE
        text.gsub CODE_RE do |lines|
          lines = lines.split NL
          n = lines[1] =~ /\#\!ruby/ ? 2 : 1
          code = lines[n...-1].join(NL+'  ')
          flow do
            background rgb(190, 190, 190), curve: 5
            inscription link(fg('Run this', green)){eval mk_executable(code), TOPLEVEL_BINDING}, margin_left: 480
            para '  ', fg(code, maroon), NL
          end
          para
        end
        next
      end
      
      if text =~ /\A \* (.+)/m
        $1.split(/^ \* /).each do |txt|
          image File.join(DIR, '../static/gshoes-icon.png'), width: 20, height: 20
          flow(width: 510){show_paragraph txt, intro, i}
        end
      else
        show_paragraph text, intro, i
      end
    end
  end
  
  def show_paragraph txt, intro, i, dot = nil
    txt = txt.gsub("\n", ' ').gsub(/`(.+?)`/m){fg code($1), rgb(255, 30, 0)}.
      gsub(/\^(.+?)\^/m, '\1').gsub(/'''(.+?)'''/m){strong($1)}.gsub(/''(.+?)''/m){em($1)}.
      gsub(/\[\[BR\]\]/i, "\n")
    txts = txt.split(/(\[\[\S+?\]\])/m).map{|s| s.split(/(\[\[\S+? .+?\]\])/m)}.flatten
    case txts[0]
    when /\A==== (.+) ====/; caption $1, size: 24
    when /\A=== (.+) ===/; tagline $1, size: 12, weight: 'bold'
    when /\A== (.+) ==/; subtitle $1
    when /\A= (.+) =/; title $1
    when /\A\{COLORS\}/; flow{color_page}
    when /\A\{SAMPLES\}/; flow{sample_page}
    else
      para *mk_links(txts), NL, (intro and i.zero?) ? {size: 16} : ''
      txt.gsub IMAGE_RE do
        image File.join(DIR, "../static/#{$3}"), eval("{#{$2 or "margin_left: 50"}}")
        para
      end
    end
  end

  def mk_links txts
    txts.map{|txt| txt.gsub(IMAGE_RE, '')}.
      map{|txt| txt =~ /\[\[(\S+?)\]\]/m ? (t = $1.split('.'); link(ins t.last){visit "/manual/#{find_pnum t.first}"}) : txt}.
      map{|txt| txt =~ /\[\[(\S+?) (.+?)\]\]/m ? (url = $1; link(ins $2){visit url =~ /^http/ ? url : "/manual/#{find_pnum url}"}) : txt}
  end

  def mk_paras str
    str.split("\n\n") - ['']
  end

  def mk_executable code
    if code =~ /\# Not yet available/
      "Shoes.app{para 'Sorry, not yet available...'}"
    else
      code
    end
  end

  def color_page
    Shoes::App::COLORS.each do |color, v|
      r, g, b = v
      c = v.dark? ? white : black
      flow width: 0.33 do
        background send(color)
        para fg(strong(color), c), align: 'center'
        para fg("rgb(#{r}, #{g}, #{b})", c), align: 'center'
      end
    end
    para
  end
  
  def sample_page
    names = Dir[File.join(DIR, '../samples/sample*.rb')].map do |file|
      orig_name = File.basename file
      dummy_name = orig_name.sub(/sample(.*)\.rb/){
        first, second = $1.split('-')
        "%02d%s%s" % [first.to_i, ('-' if second), second]
      }
      [dummy_name, orig_name]
    end
    names.sort.map(&:last).each do |file|
      stack width: 80 do
        inscription file[0...-3]
        img = image File.join(DIR, "../snapshots/#{file[0..-3]}png"), width: 50, height: 50
        img.click{Dir.chdir(File.join DIR, '../samples'){instance_eval IO.read(file)}}
        para
      end
    end
  end
  
  def find_pnum page
    TOC_LIST.each_with_index do |e, i|
      title, section = e
      return i if title == page
    end
  end

  def self.load_docs path
    str = IO.read(path).force_encoding("UTF-8")
    (str.split(/^= (.+?) =/)[1..-1]/2).map do |k, v|
      sparts = v.split(/^== (.+?) ==/)
      sections = (sparts[1..-1]/2).map do |k2, v2|
        meth = v2.split(/^=== (.+?) ===/)
        k2t = k2[/^(?:The )?([\-\w]+)/, 1]
        meth_plain = meth[0].gsub(IMAGE_RE, '')
        h = {title: k2, section: k, description: meth[0], methods: (meth[1..-1]/2)}
        [k2t, h]
      end
      h = {description: sparts[0], sections: sections, class: "toc" + k.downcase.gsub(/\W+/, '')}
      [k, h]
    end
  end
  
  def self.mk_page_numbers docs
    pnum = []
    docs.length.times do |i|
      pnum << [i, nil]
      docs[i][1][:sections].length.times do |j|
        pnum << [i, j]
      end
    end
    pnum
  end

  IMAGE_RE = /\!(\{([^}\n]+)\})?([^!\n]+\.\w+)\!/
  CODE_RE = /\{{3}(?:\s*\#![^\n]+)?(.+?)\}{3}/m
  NL = "\n"
  LANG = $lang.downcase[0, 2]
  DOCS = load_docs File.join(DIR, "../static/manual-#{LANG}.txt")
  PNUMS = mk_page_numbers DOCS
  PEND = PNUMS.length
  TOC, TOC_LIST = [], []
  COLORS = Shoes::App::COLORS
end

Shoes.app title: 'The Green Shoes Manual', width: 720, height: 640

class Manual < Shoes
  url '/', :index
  url '/manual/(\d+)', :index

  def index pnum = 0
    font LANG == 'ja' ? 'MS UI Gothic' : 'Arial'
    style Link, underline: false, weight: 'bold'
    style LinkHover, stroke: '#06E'
    manual *get_title_and_desc(pnum.to_i)
  end
  
  def get_title_and_desc pnum
    chapter, section = PNUMS[pnum]
    if section
      [pnum, DOCS[chapter][1][:sections][section][1][:title], DOCS[chapter][1][:sections][section][1][:description]]
    else
      [pnum, DOCS[chapter][0], DOCS[chapter][1][:description]]
    end
  end
  
  def table_of_contents
    PNUMS.map.with_index do |e, pnum|
      chapter, section = e
      title = section ? DOCS[chapter][1][:sections][section][1][:title] : DOCS[chapter][0]
      title = title.sub('The', '').split(' ').first
      section ? ['   ', link(title){visit "/manual/#{pnum}"}, "\n"] : [link(fg(title, darkgreen)){visit "/manual/#{pnum}"}, "\n"]
    end.flatten
  end

  def manual pnum, docs_title, docs_description
    flow do
      background tr_color("#ddd")..white, angle: 90
      background black..green, height: 90
      para fg("The Green Shoes Manual", gray), left: 120, top: 10
      title fg(docs_title, white), left: 120, top: 30, font: 'Coolvetica'
      image File.join(DIR, '../static/gshoes-icon.png'), left: 5, top: -12, width: 110, height: 110, nocontrol: true

      paras = mk_paras docs_description

      stack{para NL * 4}
      flow width: 0.2, margin_left: 10 do
        para *table_of_contents
      end
        
      flow width: 0.8, margin: [10, 0, 20, 0] do
        paras.each_with_index do |text, i|
          if text.index CODE_RE
            text.gsub CODE_RE do |lines|
	      code = lines.split(NL)[2...-1].join(NL)
              flow do
                background lightsteelblue, curve: 5
		para link(fg('Run this', green)){instance_eval(REQ+code)}, margin_left: 480
                para fg(code, maroon)
	      end
              para
            end
            next
	  end
          txt = text.gsub "\n", ' '
          para txt.gsub(IMAGE_RE, ''), NL, i.zero? ? {size: 16} : ''
          txt.gsub IMAGE_RE do
            image File.join(DIR, "../static/#{$3}"), eval("{#{$2}}")
            para 
          end
        end
        para link('top'){visit "/manual/0"}, "  ",
          link('prev'){visit "/manual/#{(pnum-1)%PEND}"}, "  ", 
          link('next'){visit "/manual/#{(pnum+1)%PEND}"}, "  ", 
          link('end'){visit "/manual/#{PEND-1}"}
      end
    end
  end

  def mk_paras str
    str.split("\n\n") - ['']
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
  REQ = "require File.join(DIR, 'green_shoes')\n"
  LANG = $lang.downcase[0, 2]
  DOCS = load_docs File.join(DIR, "../static/manual-#{LANG}.txt")
  PNUMS = mk_page_numbers DOCS
  PEND = PNUMS.length
end

Shoes.app title: 'The Green Shoes Manual', width: 720, height: 640

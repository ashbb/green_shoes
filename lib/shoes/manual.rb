class Shoes
  NL = "\n"

  def self.show_manual lang
    lang = lang.downcase[0, 2]

    app title: 'The Green Shoes Manual', width: 720, height: 640 do
      extend Manual
      docs = load_docs File.join(DIR, "../static/manual-#{lang}.txt")
      font lang == 'ja' ? 'MS UI Gothic' : 'Arial'

      flow do
        background tr_color("#ddd")..white, angle: 90
        background black..green, height: 90
        para fg("The Green Shoes Manual", gray), left: 120, top: 10
        title fg(docs[0][0], white), left: 120, top: 30, font: 'Coolvetica'
        image File.join(DIR, '../static/gshoes-icon.png'), left: 5, top: -12, width: 110, height: 110, nocontrol: true

        paras = mk_paras docs[0][1][:description]

        stack{para NL * 4}
        flow margin: [130, 0, 20, 0] do
          para paras[0], NL, size: 16
          paras[1..-1].each do |text|
            para text.gsub(Manual::IMAGE_RE, ''), NL
            text.gsub(Manual::IMAGE_RE){image File.join(DIR, "../static/#{$3}"), eval("{#{$2}}")}
          end
        end
      end
    end
  end
end

require '../lib/green_shoes'

# The same as gallery2 : http://shoes-tutorial-note.heroku.com/html/01110_Fancy_Gallery_1-5.html
# But revised for Green Shoes

Shoes.app width: 200, height: 200 do
  background mintcream
  flow margin: 5 do
    flow height: 190 do
      background './shell.png', curve: 5
      @line = para ' '
      @line.cursor = -1
    end
  end

  keypress do |k|
    #p k
    msg = case k
      when 'BackSpace'; @line.text[0..-2]
      when 'Return'; @line.text + "\n"
      when 'space'; @line.text + ' '
      when 'exclam'; @line.text + '!'
      when 'period'; @line.text + '.'
      else
        k.length == 1 ? @line.text + k : nil
    end
    (@line.text = strong fg msg, white) if msg
    flush
  end
end

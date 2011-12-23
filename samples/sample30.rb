# Almost same code as sample22.rb : http://shoes-tutorial-note.heroku.com/html/00508_The_Widget_class.html

require 'green_shoes'

class Answer < Shoes::Widget
  attr_reader :mark
  def initialize word
    flow do
      para word, width: 70
      @mark = image(File.join(DIR, '../samples/loogink.png'), width: 20, height: 20).hide
    end
  end
end

Shoes.app width: 200, height: 100 do
  stack width: 0.5 do
    background palegreen
    para '1. apple'
    ans = answer '2. tomato'
    para '3. orange'
    button('Ans.'){ans.mark.toggle}
  end
  stack width: 0.5 do
    background lightsteelblue
    para '1. cat'
    para '2. dog'
    ans = answer '3. bird'
    button('Ans.'){ans.mark.toggle}
  end
end

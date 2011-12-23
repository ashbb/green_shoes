# original code is http://shoes-tutorial-note.heroku.com/html/00409_No.9_Shoes.url.html

require 'green_shoes'

class PhotoFrame < Shoes
  url '/', :index
  url '/loogink', :loogink
  url '/cy', :cy

  def index
    eval(['loogink', 'cy'][rand 2])
  end

  def loogink
    background tomato
    image File.join(DIR, '../samples/loogink.png'), margin: [70, 10, 0, 0]
    para fg(strong('She is Loogink.'), white),
      '->', link(strong('Cy')){visit '/cy'},
      margin: 10
    p app.location
  end

  def cy
    background paleturquoise
    image File.join(DIR, '../samples/cy.png'), margin: [70, 10, 0, 0]
    para fg(strong('He is Cy.'), gray), '  ->', 
      link(strong('loogink')){visit '/loogink'},
      margin: 10
    p app.location
  end
end

Shoes.app width: 200, height: 120, title: 'Photo Frame'

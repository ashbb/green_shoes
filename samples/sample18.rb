require "../lib/green_shoes"

Shoes.app do
  title "Shoes is a ", link("tiny"){alert "Cool!"}, " graphics toolkit. "

  flow width: 0.4 do
    img = image '../static/gshoes-icon.png'
    img.click{alert "You're soooo quick!"}
  end

  flow width: 0.6 do
    tagline "It's simple and straightforward. ", 
      link("Shoes was born to be easy! "){alert "Yay!"}, 
      "Really, it was made for absolute beginners. "
  end

  subtitle link("There's really nothing to it. "){alert "Have fun!"}
end

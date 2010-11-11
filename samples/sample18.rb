require "../lib/green_shoes"

Shoes.app do
  title "Shoes is a ", link("tiny"){alert "Cool!"}, " graphics toolkit. "
  tagline "It's simple and straightforward. ", 
    link("Shoes was born to be easy! "){alert "Yay!"}, 
    "Really, it was made for absolute beginners. "
  subtitle link("There's really nothing to it. "){alert "Have fun!"}
end

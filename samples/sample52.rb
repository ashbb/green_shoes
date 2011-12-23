require 'green_shoes'

Shoes.app do
 extend HH::Markup
 colors = {
    :comment => {:stroke => "#bba"},
    :keyword => {:stroke => "#FCF91F"},
    :method => {:stroke => "#C09"},
    :symbol => {:stroke => "#9DF3C6"},
    :string => {:stroke => "#C9F5A5"},
    :number => {:stroke => "#C9F5A5"},
    :regex => {:stroke => "#000", :fill => "#FFC" },
    :attribute => {:stroke => "#C9F5A5"},
    :expr => {:stroke => "#f33" },
    :ident => {:stroke => "#6e7"},
    :any => {:stroke => "#FFF"},
    :constant => {:stroke => "#55f"},
    :class => {:stroke => "#55f"},
    :matching => {:stroke => "#f00"},
  }
  code = IO.read(ask_open_file)
  button 'change color' do
    @slot.clear do
      background gray 0.1
      para highlight code, nil, colors
    end
  end
  @slot = stack do
    background gainsboro
    para highlight code, nil
  end
end

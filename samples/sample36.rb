# original code is Red Shoes class-book.rb by _why
require 'green_shoes'
require 'yaml'

class Book < Shoes
  url '/', :index
  url '/incidents/(\d+)', :incident

  def index
    incident 0
  end

  INCIDENTS = YAML.load_file File.join(DIR, '../samples/class-book.yaml')

  def table_of_contents
    toc = []
    INCIDENTS.each_with_index do |(title, story), i|
      toc.push "(#{i + 1}) ",
        link(title){visit "/incidents/#{i}"},
        " / "
    end
    toc[0...-1] << "\n"*5
  end

  def incident num
    self.scroll_top = 0
    self.scrolled = 0
    num = num.to_i
    stack  margin_left: 190 do
      banner "Incident"
      para strong("No. #{num + 1}: #{INCIDENTS[num][0]}")
    end

    flow do
      flow width: 180, margin_left: 10 do
        pinning para( *table_of_contents, size: 8 )
      end

      stack width: -180, margin_left: 10 do
        INCIDENTS[num][1].split(/\n\n+/).each do |p|
          para p
        end
      end
    end
  end
end

Shoes.app width: 640, height: 700, title: "Incidents, a Book"

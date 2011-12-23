require 'green_shoes'

Shoes.app do
  stack margin_left: 10 do
    title "Downloading Astronomy Picture of the Day",  size: 16
    status = para "One moment..."
    msg = para '0%'
    dl = download "http://antwrp.gsfc.nasa.gov/apod/image/1009/venusmoon_pascual_big.jpg",
      save: "venusmoon_pascual_big.jpg" do
      status.text = strong(fg("Okay, is downloaded.", orangered))
      image("venusmoon_pascual_big.jpg", width: 580, height: 380).move 10, 100
    end

    pg = progress left: 10, top: 100, width: width - 20
    a = animate do
      if dl.started?
        pg.fraction = dl.progress.to_f / dl.content_length
        msg.text = "%2d%" % (pg.fraction * 100)
      end
      if dl.finished?
        pg.hide
        a.stop
      end
    end
  end
end

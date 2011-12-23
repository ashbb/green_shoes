require 'green_shoes'

Shoes.app width: 300, height: 100, title: 'Teeny-weeny MP3 player' do
  space = ' '
  background gold..cyan, angle: 30
  song = para 'song.mp3', stroke: firebrick, left: 0, top: 70
  file = 'https://github.com/ashbb/teeny-weeny_mp3_player/raw/master/samples/song.mp3'
  v = video file

  para link('select'){
    unless v.playing?
      f = ask_open_file
      file = f if f
      v = video file
      song.text = fg(file.gsub("\\", '/').split('/').last, firebrick)
    end
  }, space, link('play'){v.play}, space, link('pause'){v.pause}, space, link('stop'){v.stop}
  
  img = image File.join(DIR, '../samples/loogink.png')
  n = 0
  animate 5 do
    img.move (n+=1) % 300 , 40 - rand(10) if file && v.playing?
  end
end

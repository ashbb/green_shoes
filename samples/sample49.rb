require 'green_shoes'

Shoes.app do
  popup = proc{alert 'Testing style method...'}

  s1 = stack width: 0.5, height: 1.0 do
    background cornflowerblue
    @star = star 20, 20, 10, 100, 50
    @star.click &popup
    @msg = para fg('Wait 5 seconds...', yellow), left: 10, top: 450
  end

  s2 = stack width: 0.5, height: 1.0 do
    background coral
    para 'Green Shoes is one of colorful Shoes. It is written in pure Ruby with Ruby/GTK2.'
    @para = para 'Testing, ', link('test', &popup), ', test. ',
      strong('Breadsticks. '),
      em('Breadsticks. '),
      code('Breadsticks. '),
      bg(fg(strong(ins('EVEN BETTER.')), white), rgb(255, 0, 192)),
      sub('fine!')
    para 'Yah! Yah! Yah!'
  end

  timer 5 do
    @star.style width: 30, fill: gold..deeppink, outer: 70, inner: 50
    @para.style align: 'center', size: 24, markup: fg(em(@para.markup), green)
    s1.style width: 0.3
    s2.style width: 0.7
    @msg.text = fg('Looks good to me!', yellow)
    flush
  end
end

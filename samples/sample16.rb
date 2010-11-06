# Same snippet as http://shoes-tutorial-note.heroku.com/html/00402_No.1_para.html

require '../lib/green_shoes'

Shoes.app :width => 240, :height => 95 do
  para 'Testing, test, test. ',
    strong('Breadsticks. '),
    em('Breadsticks. '),
    code('Breadsticks. '),
    strong(ins('EVEN BETTER.')),
    sub('fine!')
end

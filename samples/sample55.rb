# Almost same snippet as 
# http://shoes-tutorial-note.heroku.com/html/00526_The__state_style.html
require 'green_shoes'

Shoes.app width: 570, height: 600 do
  src = IO.read File.join(DIR, '../samples/sample55.rb')
  background deepskyblue

  stack do
    caption strong ":state >> string"
    para '# sample55.rb'
  end

  eb = edit_box text: src, width: width, height: height*0.85, state: 'readonly'

  button('edit'){eb.state = eb.state ? nil : 'readonly'}

  b1 = button 'save', state: 'disabled' do
    file = ask_save_file
    open(file, 'wb'){|f| f.puts eb.text}  if file
  end

  b2 = button 'password' do
    pw = ask 'Enter your password: ', secret: true
    (b1.state = nil; b2.state = 'disabled')  if pw == 'Ruby&Shoes'
  end
end

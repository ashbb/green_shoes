Green Shoes
===========

![logo icon1](https://github.com/ashbb/green_shoes/raw/master/static/gshoes-heading-icon.png)
![logo icon2](https://github.com/ashbb/green_shoes/raw/master/static/gshoes-icon.png)

This is **Green Shoes** written in Ruby. One of the colorful [Shoes](http://shoes.heroku.com/).  ;-)

Fantastic logo icon was created by [Zachary Scott](https://github.com/zacharyscott). Thanks!

Now, there are 51 [samples](https://github.com/ashbb/green_shoes/tree/master/samples). Each has a [snapshot](https://github.com/ashbb/green_shoes/tree/master/snapshots).


Tiny Streaming Flash videos
---------------------------

- [sample01](http://www.rin-shun.com/shoes/green-shoes-sample1.swf.html) : Bouncing logo
- [sample04](http://www.rin-shun.com/shoes/green-shoes-sample4.swf.html) : Text in edit_line moving at random
- [sample07](http://www.rin-shun.com/shoes/green-shoes-sample7.swf.html) : 20 buttons in flow
- [sample09](http://www.rin-shun.com/shoes/green-shoes-sample9.swf.html) : Complicated stacks and flows
- [sample11](http://www.rin-shun.com/shoes/green-shoes-sample11.swf.html) : A circle moving with mouse motion
- [sample12](http://www.rin-shun.com/shoes/green-shoes-sample12.swf.html) : Random color change
- [sample13](http://www.rin-shun.com/shoes/green-shoes-sample13.swf.html) : Mouse click and release
- [sample14-1](http://www.rin-shun.com/shoes/green-shoes-sample14-1.swf.html) : Flowers
- [sample15](http://www.rin-shun.com/shoes/green-shoes-sample15.swf.html) : Text reallocation
- [sample18](http://www.rin-shun.com/shoes/green-shoes-sample18.swf.html) : Text markup and link
- [sample19](http://www.rin-shun.com/shoes/green-shoes-sample19.swf.html) : Pong Game
- [sample20](http://www.rin-shun.com/shoes/green-shoes-sample20.swf.html) : Potacho
- [sample26](http://www.rin-shun.com/shoes/green-shoes-sample26.swf.html) : Mask
- [sample28](http://www.rin-shun.com/shoes/green-shoes-sample28.swf.html) : Snake Game
- [sample32](http://www.rin-shun.com/shoes/green-shoes-sample32.swf.html) : Chipmunk Physics
- [sample38](http://www.rin-shun.com/shoes/green-shoes-sample38.swf.html) : Rotating rect, oval and star
- [sample39](http://www.rin-shun.com/shoes/green-shoes-sample39.swf.html) : Hackety Hack opening demo
- [sample41](http://www.rin-shun.com/shoes/green-shoes-sample41.swf.html) : 3D Texture Mapping
- [sample43](http://www.rin-shun.com/shoes/green-shoes-sample43.swf.html) : Download and progress bar
- [sample44](http://www.rin-shun.com/shoes/green-shoes-sample44.swf.html) : Good clock

- [simple boids](http://www.rin-shun.com/shoes/green-shoes-a-very-simple-boids.swf.html) : A very simple boids
- [parallax scrolling](http://www.rin-shun.com/shoes/green-shoes-parallax-scrolling.swf.html) : Parallax scrolling
- [search sample](http://www.rin-shun.com/shoes/search_sample_with_green_shoes.swf.html) : Search sample

recorded with [CamStudio](http://camstudio.org/).

Install and run
--------------

For Windows:

1. download and install [rubyinstaller-1.9.2-p136.exe](http://rubyinstaller.org/downloads/)   
2. gem install green_shoes --no-ri --no-rdoc   

That's it!

Now open your text editor and write your first Green Shoes app like this:

	#my_first_green_shoes_app.rb
	require 'green_shoes'
	Shoes.app{ title 'hello world' }

Then run your app on the console window:

	ruby my_first_green_shoes_app.rb

You can see this snapshot:

![snapshot](https://github.com/ashbb/green_shoes/raw/master/snapshots/helloworld.png)

**NOTE: Use Ruby-GNOME2 0.90.7 or later.**

If you are using Ruby-GNOME2 0.90.6, have to do the following.

- make this file: %{your path of gtk2 gem}\vendor\local\etc\gtk-2.0\gtkrc    
- store just one line: gtk-theme-name = "MS-Windows"    

Then you can look at good-looking button on Green Shoes.
(left button of [this snapshot](http://www.rin-shun.com/tmp/ruby-gtk2-buttons.png))

Ruby-GNOME2 developer Kou (Kouhei Sutou) included gtkrc in the [0.90.7](http://ruby-gnome2.sourceforge.jp/?News_20110202_1) distribution. 
Thanks, Kou. Awesome!


Mini Hackety Hack
------------------

![snapshot](https://github.com/ashbb/green_shoes/raw/master/snapshots/mini-hh.png)

[This](http://www.rin-shun.com/shoes/green-shoes-mini-hh.swf.html) is a first try with Green Shoes. ;-)

[Hackety Hack](http://hacketyhack.heroku.com/): the little coder's starter kit


LICENSE
--------

Copyright (c) 2010-2011 ashbb

Except:

- hh/static/(all).png (c) 2008 why the lucky stiff
- lib/ext/hpricot/(all) (c) 2008 why the lucky stiff
- lib/ext/projector/(all).rb (c) 2010 MIZUTANI Tociyuki
- samples/akatsukiface.png (c) 2010 MIZUTANI Tociyuki
- samples/class-book.yaml (c) 2008 why the lucky stiff
- samples/splash-hand.png (c) 2008 why the lucky stiff
- samples/loogink.png (c) 2008 Anita Kuno
- samples/cy.png (c) 2008 Anita Kuno
- static/Coolvetica.ttf (c) 1999 Ray Larabie
- static/Lacuna.ttf (c) 2003 Glashaus, designed by Peter Hoffman
- static/gshoes-icon.png (c) 2010 Zachary Scott
- static/gshoes-heading-icon.png (c) 2010 Zachary Scott
- static/code_highlighter.js (c) 2005 Dan Webb
- static/code_highlighter_ruby.js (c) 2008 why the lucky stiff
- static/manual.css (c) 2008 why the lucky stiff

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
  
The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software.
   
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


Note (old piece of information)
-----------------------------

- [Install Ruby/GTK2 and rcairo for Linux](https://github.com/ashbb/shoes_hack_note/tree/master/md/hack030.md).
- [Install Ruby/GTK2 and rcairo for Windows](https://github.com/ashbb/shoes_hack_note/tree/master/md/hack031.md).

Let's have fun with Ruby and Shoes! :-D

ashbb

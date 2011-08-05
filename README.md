Green Shoes
===========

> Let's have fun with Ruby and Shoes! :-D
> 
> [ashbb](#)

Green Shoes is a Ruby domain specific language for beautiful Desktop Applications.
The Green Shoes dsl is so simple, even your pointy haired boss can understand it.
The Green Shoes project is based on _why-the-lucky-stiff's Shoes, except for the following:

* Green Shoes source code is all Ruby, so even you can contribute.
* Green Shoes takes the Ruby DSL block-style approach, so all you have to do is write what you know: Ruby.


Examples
========

Here is a quick example to get the juices flowing:

    require 'green_shoes'
	
    Shoes.app( :width => 250, :height => 250 ) do
      para 'Hello, world!'
      image 'images/shoes.png'
    end

There are a lot of samples [here in the sample box](https://github.com/ashbb/green_shoes/tree/master/samples).


Installation
============

Since Green Shoes is a Ruby Gem, all you need to install are:

1. [Ruby](http://ruby-lang.org) 1.9 or above
2. [Gems](http://rubygems.org) 1.5 or above
3. [ruby-gtk2 package](http://ruby-gnome2.sourceforge.jp/) 0.90.7 or above

Once you have all three requirements, you can simply install with this command:

    gem install green_shoes


Documentation
=============

Read the [Manual](http://ashbb.github.com/green_shoes/) for all sorts of shoe-like good-ness

Check the [Wiki](http://github.com/ashbb/green_shoes/wiki) for extra documentation and details.

Please contribute to documentation whenever you can.


Bugs & Requests
===============

See [Issues](http://github.com/ashbb/green_shoes/issues) for any bugs or feature requests.

Note on Patches/Pull Requests
------------------------------

* (create your github account)
* Fork the project green_shoes to your github account
* Clone the fork to your home machine : git clone http://youraccount@github.com/youraccount/green_shoes
* Make your features additions or bug fix ( additions to lib/plugins or lib/ext, bug fix directly in sources) 
* Add a  sampleXX.rb in sample dir  (if feature addition) for a demo of your feature(s)
* Commit your fork :  git commit -a -m "..." ;  git push origin master
* Send me a pull request : on GitHub on your green_shoe fork, click 'pull request' on the head of the page


License
=========

Copyright (c) 2010-2011 ashbb

Except:

- hh/static/(all).png (c) 2008 why the lucky stiff
- lib/ext/hpricot/(all) (c) 2008 why the lucky stiff
- lib/ext/projector/(all).rb (c) 2010 MIZUTANI Tociyuki
- lib/ext/highlighter/(all) (c) 2008 why the lucky stiff and 2011 Steve Klabnik
- lib/plugins/(httpd.rb, systray.rb, thread.rb) (c) 2011 Regis d'Aubarede
- samples/akatsukiface.png (c) 2010 MIZUTANI Tociyuki
- samples/class-book.yaml (c) 2008 why the lucky stiff
- samples/splash-hand.png (c) 2008 why the lucky stiff
- samples/loogink.png (c) 2008 Anita Kuno
- samples/cy.png (c) 2008 Anita Kuno
- samples/sample54.rb (c) 2011 Regis d'Aubarede
- samples/face-crying.png (c) 2011 Regis d'Aubarede
- samples/face-smile-big.png (c) 2011 Regis d'Aubarede
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


Credits
=======

* [_why-the-lucky-stiff](https://github.com/shoes/shoes), for coming up with the idea and the original shoes.
* [ashbb](https://github.com/ashbb), for developing Green Shoes.
* [zzak](https://github.com/zacharyscott), for creating fantastic logo and [web site](http://gshoes.heroku.com/).
* [krainboltgreene](https://github.com/krainboltgreene), for being terribly handsome.
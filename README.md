Green Shoes
===========

Green Shoes is a Ruby DSL for beautiful Desktop Applicatons with a simple syntax.
The Green Shoes project is based on _why-the-lucky-stiff's Shoes, except for the following:

* Green Shoes's source is in Ruby.
* Green Shoes's DSL is all Ruby, so you can write Ruby.
* Green Shoes is green.

> Let's have fun with Ruby and Shoes! :-D
> - *ashbb*

Examples
========

Here is a quick example to get the juices flowing:

	require 'green_shoes'
	
	Shoes.app width: 250, height: 250 do
	  para "Hello, world!"
	  image 'images/shoes.png'
	end

There are a lot of samples [here in the sample box](https://github.com/ashbb/green_shoes/tree/master/samples).


Installation
============

Installing Green Shoes works like any other Ruby Gem.
This requires three working dependencies:

1. [Ruby](http://ruby-lang.org) 1.9 or above
2. [Gems](http://rubygems.org) 1.5 or above
3. [Ruby-GNOME2](http://ruby-gnome2.sourceforge.jp/) 0.90.7 or above

Once you have all three requirements, you can simply install the gem via Gems:

    gem install green_shoes


Documentation
=============

Check the [Github Wiki](http://github.com/ashbb/green_shoes/wiki) for extra documentation and details.


Bugs & Requests
===============

See [Github Issues](http://github.com/ashbb/green_shoes/issues) for any bugs or feature requests.


License
=========

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


Credits
=======

_why-the-lucky-stiff, for coming up with the idea and the original shoes.
ashbb, for the ... and ...
zzack, for ... and ...
krainboltgreen, for being a visionary and glorious leader. Terribly handsome.
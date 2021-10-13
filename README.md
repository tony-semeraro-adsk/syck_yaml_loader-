= syck_yaml_loader, the loader portion of the syck gem

* https://github.com/ruby/syck

== DESCRIPTION:

A gemified version of Syck from Ruby's stdlib with the monkeypatches and to_yaml functions removed.  Syck has been removed from
Ruby's stdlib, and this gem is meant to bridge the gap for people that haven't
updated their YAML yet.

== FEATURES/PROBLEMS:

* ~~Monkeypatches the crap out of everything~~ Fixed!

== SYNOPSIS:

  require 'syck_yaml_loader'
  SyckYamlLoader.load("--- YOUR YAML STRING HERE")

== REQUIREMENTS:

* Ruby

== INSTALL:

* gem install syck_yaml_loader

== LICENSE:

(The MIT License)

Copyright (c) 2012 Aaron Patterson, why the lucky stiff, Autodesk

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

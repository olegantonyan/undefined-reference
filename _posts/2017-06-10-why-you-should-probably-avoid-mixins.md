---
layout: post
title:  "Why you should probably avoid mixins"
date:   2017-06-10 07:35:28 +0200
description: Mixins can be dangerous in many cases, avoid them if you can
keywords: ruby
tags:
  - ruby
---

As you might have heard [inheritance is evil](https://softwareengineering.stackexchange.com/questions/260343/why-is-inheritance-generally-viewed-as-a-bad-thing-by-oop-proponents). I won't argue, but indeed often inheritance is used improperly. The only legitimate usage of inheritance is creating more specific entity, not sharing the code. In this blog post I'll assume that inheritance is evil when used for code sharing.

### Mixins are another syntax for inheritance

TL;TD And they are used for code sharing, thus mixins are evil.
Indeed, in Ruby included module becomes an implicit superclass with all perks of inheritance. And this can be abused.

#### 1) super and method overriding

```ruby
module One
  def func
    puts "in module"
  end  
end  

class Two
  include One
  def func
    puts "in class"
    super
  end  
end

# take a look at object hierarchy
Two.ancestors
[
    [0] Two < Object,
    [1] One,                  # implicit superclass
    [2] Object < BasicObject,
    [3] PP::ObjectMixin,
    [4] Kernel,
    [5] BasicObject
]

# call a function
Two.new.func
in class
in module    # <- yes, you can call `super`
```

You can also include many modules with the same methods:

```ruby
module One
  def func
    puts "in one"
  end  
end  

module Two
  def func
    puts "in two"
  end  
end

class Three
  include One
  include Two
  def func
    puts "in class"
    super
  end
end

Three.ancestors
[
    [0] Three < Object,
    [1] Two,
    [2] One,
    [3] Object < BasicObject,
    [4] PP::ObjectMixin,
    [5] Kernel,
    [6] BasicObject
]

Three.new.func #=> what do you expect here?
```

The last example can be an interview question. It requires knowledge of how modules and inheritance actually work.

#### 2) they have access to instance variables of a class

Being just a superclass, included module can access private instance variables of a child:

```ruby
module One
  def func
    puts @var
  end  
end  

class Two
  include One
  def initialize
    @var = 'hello'
  end  
end  

Two.new.func #=> hello
```

Same is true for private methods.

### Evil begins

Now a developer can abuse mixins and make his code an unreadable mess. With good intentions, of course. For example, why not include 10 modules in 1 class? Now I have a "small" class and everything else spread across 10 entangled modules. Did I mention that you can call methods of another module from withing a module? Multiply this possibility by method overriding and instance variables and here comes a mess.

Is this really bad? [Yes! You should keep you classes and method small](https://www.youtube.com/watch?v=8bZh5LMaSmE), but when you split a big class into modules you make things worse. Now you have not only a big class, but a big class scattered across multiple files making it harder to read.

### Conclusion

Mixins are just cheaty syntax for inheritance intended for code sharing. Avoid them if you can. Prefer composition instead. This is true for any kind of inheritance, and especially for mixins.

In my opinion, the only legit case for mixins is when your module has no dependency on a class where it's included. But even if it's true for now doesn't mean other developers cannot add dependency later. There is no barrier.

### Links
- [The Pragmatic Programmer's Guide - Modules](http://ruby-doc.com/docs/ProgrammingRuby/html/tut_modules.html)

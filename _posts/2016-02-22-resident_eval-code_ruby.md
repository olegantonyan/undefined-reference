---
layout: post
title:  "Resident eval - code: Ruby. Survival guide"
date:   2016-02-22 12:16:28 +0200
description: Different methods to eval ruby code
keywords: ruby, eval, instance_eval, instance_exec, module_eval, module_exec, class_exec, class_eval
tags:
  - ruby
  - metaprogramming
---

There are many many ways to evaluate any ruby code at runtime. Let's look at them.

#### eval

The most basic and well-known in other dynamic languages method. Receives a string and run it as a Ruby code.
{% highlight ruby %}
txt = 'hello'
eval "puts '#{txt}'"  #=> hello
{% endhighlight %}

Optionally you can pass a context which `eval` operates on with `binding`.

{% highlight ruby %}
def get_binding
  binding
end

class Klass
  def initialize
    @var = 42
  end

  def self.class_func
    11
  end

  def get_binding
    binding
  end
end

puts self                                 #=> main
puts eval('self', get_binding)            #=> main
puts eval('self', Klass.new.get_binding)  #=> #<Klass:0x007f77d1161728>
puts eval('@var', Klass.new.get_binding)  #=> 42
{% endhighlight %}

Binding allows you to capture current execution context. For example, it's used by closures.

#### instance_eval

Allows you to operate on object with `self` set to this object. It also can accept block instead of string to evaluate it. Somewhat similar to `eval` with `binding`.

{% highlight ruby %}
# self is also passed as a block argument
Klass.new.instance_eval do |obj|
  puts @var             #=> 42
  puts self             #=> #<Klass:0x007f0c71f4d7e0>
  puts obj == self      #=> true
end

# Class itself in an instance of class `Class`
Klass.instance_eval do |obj|
  puts class_func       #=> 11
  puts self             #=> Klass
  puts obj == self      #=> true
end

# works with string too
Klass.new.instance_eval "puts @var" #=> 42
{% endhighlight %}

#### instance_exec

Similar to `instance_eval`, but also allows you to pass an argument to a block.

{% highlight ruby %}
# instance_exec can pass an argument(s)
Klass.new.instance_exec(1, 2) do |obj1, obj2|
  puts @var             #=> 42
  puts self             #=> #<Klass:0x007f1136e57060>
  puts obj1             #=> 1
  puts obj2             #=> 2
end

# for example, you can define methods dynamically with instance_exec
instance = Klass.new
instance.instance_exec(3) do |obj|
  @_obj = obj
  def new_func
    @_obj
  end
end
puts instance.new_func  #=> 3 (or nil if no arguments passed to instance_exec)

# works only with block
Klass.new.instance_exec "puts 'hello'" #=> no block given (LocalJumpError)
{% endhighlight %}

#### class_eval

Similar to `instance_eval`, but operates on object itself. Available only on `Module` (`Class`).

{% highlight ruby %}
Klass.class_eval do |obj|
  puts obj                  #=> Klass
  def another_func
    14
  end
end
puts Klass.new.another_func #=> 14
{% endhighlight %}

#### class_exec

Like `instance_exec` but for `class_eval`. Allows you to pass an argument to a block.
{% highlight ruby %}
Klass.class_exec(1) do |obj|
  puts obj                  #=> 1 (or nil if no arguments passed to class_exec)
  def yet_another_func
    18
  end
end
puts Klass.new.yet_another_func #=> 18

# because class_{exec,eval} opens `Klass` itlelf any @variables are class instance variables (like instance_exec on a class)
# but any methods defined are instance methods
Klass.class_exec(1) do |obj|
  @_obj = obj
  puts @_obj                    #=> 1
  def yet_another_func1
    @_obj
  end
end
puts Klass.new.yet_another_func1 #=> nil
puts Klass.instance_variables    #=> @_obj
{% endhighlight %}

#### module_eval

Same as `class_eval`.

#### module_exec

Same as `class_exec`.

### Conclusion

`eval` is the most basic and well-known method. You can evaluate any Ruby code with it. But if you're using `rubocop` it will yell at `eval` as a security issue. True, if you run `eval` against user-provided string it can be exploited like SQL-injection.

Other methods are a little bit safer since they accept block, not a string (don't use strings with {instance,class,module}_eval).

`obj.instance_{eval,exec}` operate on singleton class of an `obj`.

`obj.{class,module}_{exec,eval}` operate on `obj` itself and available only on `Module` (`Class`).

`{instance,module,class}_exec` allows you to pass an argument to eval'd block while `{instance,module,class}_eval` don't.

`{instance,module,class}_eval` can also accept string (just like regular `eval`).

### Links

- [Eval, module_eval, and instance_eval](https://4loc.wordpress.com/2009/05/29/eval-module_eval-and-instance_eval/)
- [Kernel#eval at ruby-doc.org](http://ruby-doc.org/core-2.3.0/Kernel.html#method-i-eval)
- [BasicObject#instance_eval](http://ruby-doc.org/core-2.3.0/BasicObject.html#method-i-instance_eval)
- [BasicObject#instance_exec](http://ruby-doc.org/core-2.3.0/BasicObject.html#method-i-instance_exec)
- [Module#module_eval](http://ruby-doc.org/core-2.3.0/Module.html#method-i-module_eval)
- [Module#module_exec](http://ruby-doc.org/core-2.3.0/Module.html#method-i-module_exec)
- [RubyMonk: Class eval](https://rubymonk.com/learning/books/5-metaprogramming-ruby-ascent/chapters/24-eval/lessons/68-class-eval)
- [Module#class_eval](http://ruby-doc.org/core-2.3.0/Module.html#method-i-class_eval)
- [Module#class_exec](http://ruby-doc.org/core-2.3.0/Module.html#method-i-class_exec)
- [Stanford CS 142: Understanding class_eval and instance_eval](http://web.stanford.edu/~ouster/cgi-bin/cs142-winter15/classEval.php)
- [Understanding class_eval, module_eval and instance_eval](http://mauricio.github.io/2009/06/04/understanding-class_eval-module_eval-and-instance_eval.html)
- [StackOverflow: What is the difference between class_eval, class_exec, module_eval and module_exec?](http://stackoverflow.com/questions/9057711/what-is-the-difference-between-class-eval-class-exec-module-eval-and-module-ex)
- [RubyMonk: Eval](https://rubymonk.com/learning/books/5-metaprogramming-ruby-ascent/chapters/24-eval/lessons/63-eval)

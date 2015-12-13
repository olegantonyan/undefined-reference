---
layout: post
title:  Ensure you understand ensure
date:   2015-12-13 08:06:55 +0200
description: Ruby's ensure sometimes may lead to not obvious behavior
keywords: ruby, begin, ensure, rescue, fail, raise
tags:
  - ruby
---

Let's look at this code:

{% highlight ruby %}
def func1
  puts "one"
  return
  puts "two"
ensure
  puts "ensure"
end
{% endhighlight %}

How the result will look? Of course you'll never see `"two"`, but what about `"ensure"`?

{% highlight text %}
[13] pry(main)> func1
one
ensure
nil
[14] pry(main)>
{% endhighlight %}

Even you return from a function without exceptions, `ensure` gets executed.

Another example:

{% highlight ruby %}
def func2
  10.times do |num|
    begin
      puts "iteration #{num}"
      next if num.even?
      puts "after iteration #{num}"
    ensure
      puts "ensure"
    end
  end
end
{% endhighlight %}

And let's look at result:

{% highlight text %}
[18] pry(main)> func2
iteration 0
ensure 0
iteration 1
after iteration 1
ensure 1
iteration 2
ensure 2
iteration 3
after iteration 3
ensure 3
iteration 4
ensure 4
iteration 5
after iteration 5
ensure 5
iteration 6
ensure 6
iteration 7
after iteration 7
ensure 7
iteration 8
ensure 8
iteration 9
after iteration 9
ensure 9
10
[19] pry(main)>
{% endhighlight %}

It was very surprising for me in a contrast with Ruby's "least surprise principle". But [this is how it works](ruby-doc.org/docs/keywords/1.9/Object.html):

> Marks the final, optional clause of a begin/end block, generally in cases where the block also contains a rescue clause. The code in the ensure clause is guaranteed to be executed, whether control flows to the rescue block or not.

### Conclusion

Every time execution leaves `begin` block, `ensure` gets executed no matter what: exception, return, next, break, etc.

### Links

- [Reference on ruby-doc.org](ruby-doc.org/docs/keywords/1.9/Object.html)
- [Weird Ruby Part 2: Exceptional Ensurance](https://blog.newrelic.com/2014/12/10/weird-ruby-2-rescue-interrupt-ensure/)

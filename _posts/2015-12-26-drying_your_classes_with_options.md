---
layout: post
title:  DRY with_options
date:   2015-12-26 12:35:55 +0200
description: ActiveSupport's with_options helps you keep classes DRY
keywords: ruby, activesupport, with_options, rails
tags:
  - ruby
  - activesupport
  - rails
---
One of the cool features in `ActiveSupport` is [`with_options`](http://apidock.com/rails/v4.2.1/Object/with_options).

It helps you remove duplication:

{% highlight ruby %}
belongs_to :playlist, touch: true,  inverse_of: :devices
belongs_to :company,  inverse_of: :devices
{% endhighlight %}

Will become:

{% highlight ruby %}
with_options inverse_of: :devices do |a|
  a.belongs_to :playlist, touch: true
  a.belongs_to :company
end
{% endhighlight %}

However, there is one gotcha which was unclear for me after reading apidock.

When using ActiveRecord associations you have to use block variable to define associations like in example above. So this:

{% highlight ruby %}
with_options inverse_of: :devices do
  belongs_to :playlist, touch: true
  belongs_to :company
end
{% endhighlight %}

Will not work! However, when using validations, delegations, attr_* it's not required and you can write this:

{% highlight ruby %}
class User < ActiveRecord::Base
  with_options to: :profile, allow_nil: true do
    delegate :locale, :email, :gender, :time_zone, :first_name, :last_name
  end

  with_options presence: true do
    validates :login, length: { maximum: 256 }
    validates :password
  end
end
{% endhighlight %}

### Conclusion

Use `with_options`, but remember to add block variable when using it for ActiveRecord associations.

### Links

- [Reference on apidock.com](ruby-doc.org/docs/keywords/1.9/Object.html)
- [RailsCasts#with_options](http://railscasts.com/episodes/42-with-options)

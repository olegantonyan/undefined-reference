---
layout: post
title:  "I18n for data in your models"
date:   2016-04-01 13:52:28 +0200
description: How to store data in multiple languages
keywords: ruby, rails, i18n, jsonb
tags:
  - ruby
  - rails
---

Recently I needed to store text data in multiple languages at the same time. After a quick googling I found a [globalize gem](https://github.com/globalize/globalize) which does exactly what I need.

But there are couple issues with it:

1. doesn't support rails 5 [yet](https://github.com/globalize/globalize/issues/473);
2. creates additional tables to store translated data;
3. requires you to reference models in migration, which is [anti-pattern](http://www.pervasivecode.com/blog/2010/03/18/rails-migration-antipatterns-and-how-to-fix-them).

It's somewhat OK to live with 2 and 3, but not with 1 if you are on rails 5.

That's why I've created another solution and extracted it into a [gem](https://github.com/olegantonyan/translateable).

The idea is very simple: save all translation data in one field. It's possible to do so even with serializable attribute, but much better is to use `jsonb` type in PostgreSQL 9.4. It's indexed and you can query it just like any data.

ActiveRecord supports jsonb since 4.2 so you can work with those fields just like with hashes.

So, let's save translatable text data under a key, representing locale:
{% highlight json %}
{ "en": "hello", "ru": "привет", "it": "ciao" }
{% endhighlight %}

Now, with a very little abstraction you can do this:
{% highlight ruby %}
I18n.locale = :en
post = Post.create(title: 'hello')
post.title #=> hello
I18n.locale = :ru
post.update(title: 'привет')
post.title #=> привет
{% endhighlight %}

Also, it's very easy to manage multiple languages in a single form if you treat them as nested attributes:

{% highlight ruby %}
class Post < ActiveRecord::Base
  def title_translateable_attributes=(arg)
    self[:title] = arg.each_with_object({}) do |i, obj|
      hash = i.second
      next if hash[:_destroy]
      obj[hash[:locale]] = hash[:data]
    end
  end
end
{% endhighlight %}

Together with [nested_form_fields](https://github.com/ncri/nested_form_fields) you can add/delete translations dynamically in a single form.

### Conclusion

This very simple idea illustrates yet another use case for `jsonb` type. Don't be afraid of it.

However, it requires you to write raw SQL queries, like this:
{% highlight ruby %}
Post.where("title->>'en' = ?", 'hello'))
# more examples in gem's readme
{% endhighlight %}
But, imo this is better than joins with additional tables.

### Links
- [translateable gem](https://github.com/olegantonyan/translateable)
- [Using PostgreSQL and jsonb with Ruby on Rails](http://nandovieira.com/using-postgresql-and-jsonb-with-ruby-on-rails)
- [Querying JSON in Postgres](http://schinckel.net/2014/05/25/querying-json-in-postgres/)
- [Query postgres jsonb by value regardless of keys](http://stackoverflow.com/questions/36250331/query-postgres-jsonb-by-value-regardless-of-keys/36251296#36251296)

---
layout: post
title:  Improve console print debugging experience
date:   2016-01-31 14:46:12 +0200
description: Improving console print debugging
keywords: ruby, super_awesome_print, debugging, awesome_print, printf, debugger
tags:
  - ruby
  - debugging
---
There are 2 kinds of people: those how always use debugger, and those who use console print.
If you belong to the second group, then you probably have a problem with a lot of printing along with other (rails') stuff. Your console output become messy pretty quickly and it's hard to find required information.

There is nice [awesome_print gem](https://github.com/michaeldv/awesome_print) which helps a lot with coloring and formatting output. It's much nicer then `pp` and simple `puts`. But I like to do one little thing to make it even better:

{% highlight ruby %}
def sap msg
  ap "*** #{Time.now} ***", color: {string: :green}
  ap msg.class if msg.respond_to?(:class)
  src = caller.first.gsub(Rails.root.to_s + '/', '')
  ap src, color: {string: :purpleish}
  ap msg
  ap '*** END ***', color: {string: :green}
end
{% endhighlight %}

As you can see, now every output will be wrapped inside `***` along with file/line and type of printed value. It helps a lot.

{% highlight text %}

Started GET "/news/8" for 127.0.0.1 at 2016-01-31 15:21:00 +0200
Processing by NewsItemsController#show as HTML
  Parameters: {"id"=>"8"}
  User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = $1  ORDER BY "users"."id" ASC LIMIT 1  [["id", 1]]
  NewsItem Load (0.3ms)  SELECT  "news_items".* FROM "news_items" WHERE "news_items"."id" = $1 LIMIT 1  [["id", 8]]
"*** 2016-01-31 15:21:00 +0200 ***"
"app/controllers/news_items_controller.rb:16:in `show'"
#<NewsItem:0x007f4b63f3c0e0> {
            :id => 8,
          :body => "123234234",
    :created_at => Sun, 08 Nov 2015 16:24:49 UTC +00:00,
    :updated_at => Sun, 08 Nov 2015 16:24:49 UTC +00:00,
         :title => "4567"
}
"*** END ***"
  Rendered news_items/_single.html.haml (0.6ms)
  Rendered news_items/show.html.haml within layouts/application (2.1ms)
  Rendered layouts/_navbar.html.haml (2.9ms)
  Rendered layouts/_messages.html.haml (0.1ms)
  Rendered layouts/_footer.html.haml (3.8ms)
Completed 200 OK in 1362ms (Views: 1358.3ms | ActiveRecord: 0.6ms)
{% endhighlight %}

I use it in all my projects, so I created a [gem](https://github.com/olegantonyan/super_awesome_print) to avoid copy-pasting.

### Conclusion

I almost never use debugger because console print is just enough in 99% cases. Not only with Ruby/Rails development, but with any technology I ever worked. If you use console print a lot, then you probably have your favorite set of tools. I'll be glad to know your preference.

### Links

- [super_awesome_print gem on github](https://github.com/olegantonyan/super_awesome_print)

---
layout: post
title:  Custom templates path for controller
date:   2016-01-23 10:41:12 +0200
description: Using ActionController::Base.controller_path or prepend_view_path to specify path for all templates
keywords: rails, actioncontroller, controller_path, prepend_view_path, custom template path
tags:
  - rails
---
Sometimes you need to break rails' conventions a little bit and set custom path for all templates per controller. Especially for the purpose of namespacing.

For example, you have a controller:

{% highlight ruby %}
class UserGroupsController < ApplicationController
  def index
  end

  def show
  end
end
{% endhighlight %}

By default, rails will search for templates in `app/views/user_groups`.
But what if you want to put those templates in `app/views/users/groups`?
Instead of this:

{% highlight ruby %}
class UserGroupsController < ApplicationController
  def index
    render 'users/groups/index'
  end

  def show
    render 'users/groups/show'
  end
end
{% endhighlight %}

You can do this:

{% highlight ruby %}
class UserGroupsController < ApplicationController
  def self.controller_path
    'users/groups'
  end

  def index
  end

  def show
  end
end
{% endhighlight %}

However, this will break controller's spec.

There is another way to do this, however, with another limitation:

{% highlight ruby %}
class UserGroupsController < ApplicationController
  prepend_view_path 'app/views/users'

  def index
  end

  def show
  end
end
{% endhighlight %}

Now rails will search for templates in `app/views/users/user_groups`. The limitation is that you must name a folder for your templates like a controller. For example, you cannot use `app/views/users/groups` as a folder for templates for `UserGroupsController`. You must name this folder `app/views/users/user_groups` because of the controller's name.

### Conclusion

There are couple ways to set custom templates path per controller. Both have their downsides as a price for breaking conventions.

### Links

- [StackOverflow question](http://stackoverflow.com/questions/4301249/how-to-change-the-default-path-of-view-files-in-a-rails-3-controller/25194710#25194710)
- [controller_path reference on apidock.com](http://apidock.com/rails/AbstractController/Base/controller_path/class)
- [prepend_view_path reference](http://edgeapi.rubyonrails.org/classes/AbstractController/ViewPaths/ClassMethods.html#method-i-prepend_view_path)

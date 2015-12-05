---
layout: post
title:  Using service objects with CRUD interface, the smart way
date:   2015-12-05 11:27:09 +0200
description: User CRUD interface with your domain objects with crud_responder gem
keywords: ruby, rails, ruby on rails, services, service objects rails, crud_responder, activemodel
tags:
  - ruby
  - rails
  - crud_responder
---
[In a previous post]({% post_url 2015-11-28-crud_interface_for_service_objects %}) we saw how to create service objects with CRUD interface. Now let's see why <s>you should care</s> it is useful.

REST architecture is about CRUD over http. Rails uses RESTful routes. And in every RESTful controller action you may find something like this:
{% highlight ruby %}
def create
  @post = Post.new(post_params)

  if @post.save
    redirect_to @post, notice: 'Post was successfully updated.' }
  else
    flash[:alert] = "Error updating post: #{@post.errors.full_messages.to_sentence}"
    render :edit
  end
end

def update
  @post = Post.find(params[:id])

  if @post.update(post_params)
    redirect_to @post, notice: 'Post was successfully created.'
  else
    flash[:alert] = "Error creating post: #{@post.errors.full_messages.to_sentence}"
    render :new
  end
end
{% endhighlight %}

Not very DRY, isn't it? The only differences between these actions are:

* Method called on a model
* Action on success
* Action on error
* Text in flash message on success
* Text in flash message on error

What if we can extract them? We can decide which method to call on a model, where to redirect/render after, which flash messages to show by inspecting the model itself and a controller's action.

But this is fine when you are dealing with `ActiveRecord` (`ActiveModel` to be precise) models. What if we are using service objects? One of the "canonical" way to use service objects is by calling `call` method, like this:

{% highlight ruby %}
# app/services/create_membership_service.rb
class CreateMembershipService
  def call(options)
    # creating associations, sending notifications, etc
  end
end

# app/services/destroy_membership_service.rb
class DestroyMembershipService
  def call(options)
    # destroing associations, sending notifications, etc
  end
end

# app/controllers/memberships_controller.rb
class MembershipsController < ApplicationController
  def create
    if CreateMembershipService.new.call
      redirect_to :back, notice: "Membership has been created"
    else
      flash[:alert] = "Error creating membership"
      render :edit
    end
  end

  def destroy
    if DestroyMembershipService.new.call
      redirect_to :back, notice: "Membership has been destroyed"
    else
      flash[:alert] = "Error destroying membership"
      render :edit
    end
  end
end
{% endhighlight %}
Again, not very DRY. And here comes services which behave like `ActiveModel` and use CRUD interface.

Also, let's add some `magic` method which will call appopriate method on an object, redirect and show flashes:
{% highlight ruby %}
# app/services/membership_service.rb
class MembershipService
  include ActiveModel::Model

  def save
    # creating associations, sending notifications, etc
    # return true if ok, false otherwise and add messages to `errors`
  end

  def destroy
    # destroing associations, sending notifications, etc
    # return true if ok, false otherwise and add messages to `errors`
  end
end

# app/controllers/memberships_controller.rb
class MembershipsController < ApplicationController
  def create
    magic MembershipService.new
  end

  def destroy
    magic MembershipService.new
  end
end
{% endhighlight %}

What inside `magic` function?

- Check which actions it is called from by inspecting `caller`
- Call `save` or `destroy` according to the action
- Redirect to appropriate url or render a template according to result of calling `save` or `destroy`
- Show appropriate flash messages. In case of error - extract messages from `errors` object

Not so magic, isn't it? Luckily you don't have to implement all this logic because I've already done this in [crud_responder](https://github.com/olegantonyan/crud_responder){:target="_blank"} gem.

Now it's very handy to have all domain objects (models and services) with CRUD interface so you can use them in controllers without worrying whether it's ActiveRecord model or a service object.

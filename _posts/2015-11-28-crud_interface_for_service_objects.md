---
layout: post
title:  CRUD interface for service objects
date:   2015-11-28 06:25:55 +0200
---
Everybody knows about "service objects" concept. It's an efficient way to DRY you models and follow single responsibility principle.

Here is my vision on how to do them right: use standard CRUD interface to them (`save`, `destroy`, etc).
{% highlight ruby %}
# app/services/base_service.rb
class BaseService
  include ActiveModel::Model
  include ActiveModel::Validations

  def self.create!(attrs)
    new(attrs).save!
  end

  def save!
    raise ActiveRecord::RecordInvalid, self unless save
  end

  def destroy!
    raise ActiveRecord::RecordInvalid, self unless destroy
  end
end

# app/services/user/trial_service.rb
class User::TrialService < BaseService
  attr_accessor :user

  validates :user, presence: true

  def save
    return false unless valid?
    ActiveRecord::Base.transaction do
      # whatever logic to start a free trial for user
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add :base, e.to_s
    false
  end

  def destroy
    # end the trial for this user
  end
end
{% endhighlight %}

Now you have uniform interface to all of your domain logic objects (models and services) and it's much easier to use them in controllers. Also, it forces to to think about your domain logic in terms of CRUD interface, like REST and.

In the next post I'll show why this is very useful.

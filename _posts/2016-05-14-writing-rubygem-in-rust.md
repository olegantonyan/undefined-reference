---
layout: post
title:  "Writing Ruby gem in Rust"
date:   2016-05-14 07:12:28 +0200
description: How to integrate Rust with Ruby
keywords: ruby, rust, gem, rubygem, native
tags:
  - ruby
  - rust
---

TL;DR: here is an [example of a gem written in Rust](https://github.com/olegantonyan/rustygem).

#### Why?

Ruby is slow, right? Most of the time we don't care, but sometimes we do. And when we do, there are not so many options: C, C++, microservices/rpc/jruby, ... . C is good enough to shot yourself in the foot. C++, well, just C++. Other options are to comprehensive for a simple task, like CPU intensive algorithm. You can probably use Go, but it has its own runtime with garbage collector which adds more overhead.

Rust is another option because of:

- safety
- speed
- no runtime

There are couple of challenges with Ruby-Rust integration (actually, for Ruby-whatever integration). This post is about them.

#### Passing data between Ruby and Rust

This is relatively easy when you are passing simple integers, but if you need to pass complex objects there is a lot of headache. You can avoid it by using JSON and passing it as string. If you need to call a function in Rust and get result of its CPU intensive calculation, then it's OK to have JSON overhead.

One gotcha is that you have to deallocate memory allocated for `char *` inside Rust after it has been returned to Ruby. That's why we have `rust_free` function in Rust, which is a wrapper for libc's `free`:

```ruby
require 'rustygem/version'
require 'fiddle'
require 'json'

module Rustygem
  @lib = Fiddle.dlopen("#{File.dirname(__FILE__)}/../rust/target/release/librustygem.so")
  @rust_perform = Fiddle::Function.new(@lib['rust_perform'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP)
  @rust_free = Fiddle::Function.new(@lib['rust_free'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)

  def self.perform(arg)
    ptr = @rust_perform.call(arg.to_json) # do the actual work
    result = ptr.to_s
    @rust_free.call(ptr) # char* was allocated in Rust, so don't forget to free it
    JSON.parse(result)
  end
end
```

```rust
#[no_mangle]
pub extern "C" fn rust_free(c_ptr: *mut libc::c_void) {
    unsafe {
        libc::free(c_ptr);
    }
}
```

Check out [rustygem](https://github.com/olegantonyan/rustygem) for more details.

#### Building dynamic library when installing the gem

Ruby gems have builtin mechanism for building native extensions in C. But what about Rust? Actually, we don't need any external tools to build Rust library because in Rust we have Cargo which is very similar to bundler. So, the only thing we need to do is call `cargo build` inside Rust project. But how to do this when installing the gem? Turns out this is very simple. Just put `Makefile` along with empty `extconf.rb` and add `extconf.rb` to gemspec.

```makefile
# rust/Makefile:
all:
	cargo build --release

clean:
	rm -rf target

install: ;
```

```ruby
# gemspec
spec.extensions = Dir['rust/extconf.rb']
```

Optionally, you can put some checks into `extconf.rb`:

```ruby
# rust/extconf.rb
raise 'You have to install Rust with Cargo (https://www.rust-lang.org/)' if !system('cargo --version') || !system('rustc --version')
```

### Conclusion

There is an alternative to C. And it's not so hard to use Rust in Ruby project.

This post illustrates very basic approach to integration Rust with Ruby. There is [Helix project](https://github.com/rustbridge/helix) which is much more comprehensive. Check it out if you want less boilerplate and more nice API.

### Links
- [rustygem - an example gem written in Rust](https://github.com/olegantonyan/rustygem)
- [Bending the Curve: Writing Safe & Fast Native Gems With Rust](http://blog.skylight.io/bending-the-curve-writing-safe-fast-native-gems-with-rust/)
- [Helix project](https://github.com/rustbridge/helix)
- [SO: How can I build a Rust library when installing a gem?](http://stackoverflow.com/questions/37102967/how-can-i-build-a-rust-library-when-installing-a-gem)
- [Turbo Rails with Rust by Godfrey Chan](http://confreaks.tv/videos/railsconf2016-turbo-rails-with-rust)

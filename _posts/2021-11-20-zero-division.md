---
layout: post
title:  "Float division by 0 in not always Infinity"
date:   2021-11-20 09:16:28 +0200
description: "1.0 / 0.0 #=> Infinity, but 0.0 / 0.0 #=> NaN"
keywords: ruby
tags:
  - ruby
---

Turns out this is expected behavior:

```ruby
1.0 / 0.0
=> Infinity
0.0 / 0.0
=> NaN
```

Because Ruby follows IEEE 754:

```
- Invalid operation: mathematically undefined, e.g., the square root of a negative number. By default, returns qNaN.
- Division by zero: an operation on finite operands gives an exact infinite result, e.g., 1/0 or log(0). By default, returns ±infinity.
```

### Links
- [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754)

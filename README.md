# Inline Tests

This library defines a method of storing your method tests as part of the method.

## Syntax

To add inline tests to a method, simply prefix the method's `def` with `tested` and then add a `tests` block. Each
`assert` call should take an expression for its first argument, and an optional description may be used as the second argument.

```ruby
tested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end,
tests do |integer_division|
  assert integer_division(6, 3) == 2, "divides correctly"
  assert integer_division(5, 3) == 1, "uses integer division"
  assert integer_division(0, 3) == 0,  "0 / anything = 0"
  assert integer_division(3, 0) == Float::INFINITY
end
```

The ideal syntax probably looks something like this, but I'm not sure how to get there yet..
```ruby
def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
tests
  assert integer_division(6, 3) == 2, "divides correctly"
  assert integer_division(5, 3) == 1, "uses integer division"
  assert integer_division(0, 3) == 0,  "0 / anything = 0"
  assert integer_division(3, 0) == Float::INFINITY
end
```
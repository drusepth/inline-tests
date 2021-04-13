# Inline Tests

This library defines a method of storing your method tests as part of the method.

## Syntax

To add inline tests to a method, simply prefix the method's `def` with `tested` and then add a `tests` block.

```ruby
tested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end,
tests do
  assert call(6, 3) == 2
  assert call(5, 3) == 1
  assert call(0, 3) == 0
  assert call(3, 0) == Float::INFINITY
end
```
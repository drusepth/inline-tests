# Inline Tests

This library defines a method of storing your method tests as part of the method.

## Syntax

To add inline tests to a method, simply prefix the method's `def` with `tested` and then add a `tests` block. Each
`assert` call should take an expression for its first argument, and an optional description may be used as the second argument.

For example, say you have the following method:
```ruby
def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end
```

This is what that method might look like with inline tests:
```ruby
tested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end,
tests do |integer_division|
  assert integer_division(6, 3) == 2, "divides correctly"
  assert integer_division(5, 3) == 1, "uses integer division"
  assert integer_division(0, 3) == 0, "0 / anything = 0"
  assert integer_division(3, 0) == Float::INFINITY
end
```

## Fuzzy testing

This library also supports fuzzy testing. To use them, define a local tester variable (`this`) below and pass a _range_ as
a parameter using square brackets (`[` `]`) instead of parentheses. Square brackets can also be used as if they were parentheses,
even if you don't use fuzzy testing.

For example,
```ruby
tested def add x, y
  x + y
end,
tests do |this|
  assert_greater_than this[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  assert_equal        this[0, 0],          0, '0 + 0 = 0'
end
```

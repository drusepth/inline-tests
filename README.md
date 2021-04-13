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
tests do
  assert integer_division(6, 3) == 2, "divides correctly"
  assert integer_division(5, 3) == 1, "uses integer division"
  assert integer_division(0, 3) == 0, "0 / anything = 0"
  assert integer_division(3, 0) == Float::INFINITY
end
```

You can also flag methods that need tests but don't have them yet with the `untested` prefix. For example:
```ruby
untested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end
```

## Fuzzy testing

This library also supports fuzzy testing. To use it, define a variable (e.g. `this` below) on your tests block and pass a _range_ for
any parameter using square brackets (`[` `]`) instead of parentheses. Square brackets can also be used with non-range values.

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

## Example output

In order to run the test suite, all you need to do is call `InlineTests.run!` from anywhere.

```bash
$ ruby 07_lib_usage.rb 
Starting inline test suite:
  main::add - PASSED (0.000000271 seconds)
  main::integer_division - PASSED (0.000000239 seconds)
  main::multiply - PASSED (0.000000292 seconds)
  main::divide - PASSED (0.000000196 seconds)
4 inline tests ran in 0.000049601 seconds.
  4 PASSED
  0 FAILS
```
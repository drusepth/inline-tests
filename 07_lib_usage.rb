require_relative './lib/loader'

tested def add x, y
  x + y
end,
tests do |f|
  assert_greater_than f[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  assert_greater_than f[(1..1_000), 0], 0, 'addition should be commutative'
  assert_equal        f[0, 0], 0,          '0 + 0 = 0'
  assert_equal        f[1, 1], 2,          '1 + 1 = 2'
  assert_not_equal    f[1, 2], 2,          '1 + 2 != 2'
end

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

InlineTests.run!
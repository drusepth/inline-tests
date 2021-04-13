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

puts InlineTests.run!
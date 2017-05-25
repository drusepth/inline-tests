# Include the framework that allows inline testing syntax
require_relative '../04_global_reflection'

tested def add x, y
  x + y
end,
tests do |f|
  assert_greater_than f[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  assert_greater_than f[(1..1_000), 0], 0, 'addition should be commutative'
  assert_equal f[0, 0], 0,                 '0 + 0 = 0'
  assert_equal f[1, 1], 2,                 '1 + 1 = 2'
end

tested def subtract x, y
  x - y
end,
tests do |f|
  assert_equal f[555, 0], 555,                                   '555 - 0 = 555'
  assert_greater_than f[10_000, (0..9_999)], 0,                  'subtracting n from m where n < m should be greater than 0',
  assert_equal f[Float::INFINITY, (0..10_000)], Float::INFINITY, 'subtracting anything from infinity should still be infinity'
end

tested def multiply x, y
  x * y
end,
tests do |f|
  assert_divisible_by f[3, 5], 5,                                '3 * 5 should be divisible by 5'
  assert_divisible_by f[3, 5], 3,                                '3 * 5 should be divisible by 3'
  assert_divisible_by f[(1..10_000), 5], 5,                      'multiplying anything by 5 should be divisible by 5'
  assert_equal f[(1..10_000), Float::INFINITY], Float::INFINITY, 'multiplying anything by infinity should be infinity'
  assert_equal f[0, Float::INFINITY], 0 * Float::INFINITY,       'multiplying 0 by infinity should be NaN'
end

tested def divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end,
tests do |f|
  assert_equal f[0, 3],  0,               'can use f[x, y] to call function shorthand'
  assert_equal f.(0, 3), 0,               '0 / 3 = 0'
  assert_equal f.(6, 3), 2,               '6 / 3 = 2'
  assert_equal f.(3, 0), Float::INFINITY, 'dividing by zero results in infinity'

  # Range tests
  assert_equal f[(0..10_000), 0], Float::INFINITY,  'anything / 0 == infinity'
  assert_equal f[0, (1..10_000)], 0,                '0 / anything == 0'
end

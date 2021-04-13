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

class SomeClassWithTestedMethods
  tested def divide x, y
    return Float::INFINITY if y.zero?
    x.to_f / y
  end,
  tests do |f|
    assert_equal f[0, 3],  0,                         'can use f[x, y] to call function shorthand'
    assert_equal f.(0, 3), 0,                         '0 / 3 = 0'
    assert_equal f.(6, 3), 2,                         '6 / 3 = 2'
    assert_equal f.(3, 0), Float::INFINITY,           'dividing by zero results in infinity'
    assert_equal f[(0..10_000), 0], Float::INFINITY,  'anything / 0 == infinity'
    assert_equal f[0, (1..10_000)], 0,                '0 / anything == 0'
  end
end

class SomeClassWithTestedClassMethods
  tested def self.divide x, y
    return Float::INFINITY if y.zero?
    x.to_f / y
  end,
  tests do |f|
    assert_equal f[0, 3],  0,                         'can use f[x, y] to call function shorthand'
    assert_equal f.(0, 3), 0,                         '0 / 3 = 0'
    assert_equal f.(6, 3), 2,                         '6 / 3 = 2'
    assert_equal f.(3, 0), Float::INFINITY,           'dividing by zero results in infinity'
    assert_equal f[(0..10_000), 0], Float::INFINITY,  'anything / 0 == infinity'
    assert_equal f[0, (1..10_000)], 0,                '0 / anything == 0'
  end
end

InlineTests.run!
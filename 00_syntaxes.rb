require 'pry'

def tests; 123456+67890; puts "STARTING TESTS"; end
def assert x; puts "assert: #{x}"; end
def call x, y; divide x, y; end
def tested name, tests
  method = method(name)

  binding.pry
  # etc
end

# Standard function
def divide param_x, param_y
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f
end

# Doable block-in-body implementation
def divide_with_tests_block param_x, param_y
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f

  tests do
    assert call(0, 3) == 0
    assert call(6, 3) == 2
    assert call(3, 0) == Float::INFINITY
  end
end

# Also doable as a decorator
tested def divide_with_tests_decorator param_x, param_y
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f
end,
-> {
  assert call(0, 3) == 0
  assert call(6, 3) == 2
  assert call(3, 0) == Float::INFINITY
}

# Alternate Proc syntax
tested def divide_with_tests_decorator param_x, param_y
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f
end,
tests do
  assert call(0, 3) == 0
  assert call(6, 3) == 2
  assert call(3, 0) == Float::INFINITY
end

# define_method override
tdef :divide_with_definition_overload, :param_x, :param_y do
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f
end,
do
  assert call(0, 3) == 0
  assert call(6, 3) == 2
  assert call(3, 0) == Float::INFINITY
end

# Ideal implementation (IMO)
def divide_with_tests param_x, param_y
  return Float::INFINITY if param_y.zero?
  param_x / param_y.to_f
tests
  assert call(0, 3) == 0
  assert call(6, 3) == 2
  assert call(3, 0) == Float::INFINITY
end



puts divide 6, 3

# debug
method = method(:divide_with_tests)

binding.pry
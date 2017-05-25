require 'pry'

RUN_TESTS_IN_THIS_ENVIRONMENT = true # use RAILS_ENV==development or something instead

def tested method_name, tests_block
  method = method(method_name)

  # call tests
  yield method if RUN_TESTS_IN_THIS_ENVIRONMENT
end

def tests
end

def assert some_statement, description = ''
  # todo some callstack reflection to grab method name/line/source
  unless some_statement
    puts "#{description} FAILED"
    exit
  end
end

# Extend Method class so we can use a shorthand for .call
class Method
  def [] *parameters
    call(*parameters)
  end

  # wishlist
  # def () (*parameters)
  #   call(*parameters)
  # end

  # also doesn't work
  # define_method :'()' do |*parameters|
  #   call(*parameters)
  # end
end





# Original method
def classic_divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end


# With inline tests
tested def divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end,
tests do |f|
  assert f[0, 3]  == 0,               'can use f[x, y] to call function shorthand'
  assert f.(0, 3) == 0,               '0 / 3 = 0'
  assert f.(6, 3) == 2,               '6 / 3 = 2'
  assert f.(3, 0) == Float::INFINITY, 'dividing by zero results in infinity'
end


puts divide 3, 6
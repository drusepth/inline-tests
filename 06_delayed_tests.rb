require 'pry'

# This is a stripped-down version of 04_global_reflection's implementation
module Kernel
  METHODS_WITH_INLINE_TESTS = []
  RUN_TESTS_IN_THIS_ENVIRONMENT = true

  def tested(method_name, _ignored, &inline_test_block)
    return unless RUN_TESTS_IN_THIS_ENVIRONMENT

    puts "IN tested"

    method = method(method_name)
    method.inline_tests = inline_test_block
    METHODS_WITH_INLINE_TESTS << method

    method
  end
  def tests
    puts "IN tests block"
  end

  def assert_equal(lhs, rhs, description = '')
    passed = !!(lhs == rhs)
    raise InlineTestFailure.new(@@method_being_tested, 'assert_equal', lhs, rhs, description) unless passed

    passed
  end
end

# This is a stripped-down version of 04_global_reflection's implementation
class Method
  attr_accessor :inline_tests

  def run_inline_tests
    inline_tests.call self if inline_tests && inline_tests.respond_to?(:call)
  end
end

tested def add x, y
  x + y
end,
tests do |f|
  puts "RUNNING TESTS at runtime (by calling InlineTests.run!) instead of script startup"

  # assert_greater_than f[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  # assert_greater_than f[(1..1_000), 0], 0, 'addition should be commutative'
  # assert_equal        f[0, 0], 0,          '0 + 0 = 0'
  # assert_equal        f[1, 1], 2,          '1 + 1 = 2'
  # assert_not_equal    f[1, 2], 3,          '1 + 2 != 2'
end

# Copied from 05_test_runner
class InlineTests
  def self.tested_methods
    METHODS_WITH_INLINE_TESTS
  end

  def self.run!
    method_passing = Hash.new(false)
    method_errors  = {}

    puts "Starting test run..."
    tested_methods.select do |method|
      Kernel.class_variable_set(:@@method_being_tested, method)
      method_signature = "#{method.receiver}::#{method.name}"
      puts "Testing method #{method_signature}"
      begin
        method_passing[method_signature] = method.run_inline_tests
      rescue InlineTestFailure => failure_information
        method_passing[method_signature] = false
        method_errors[method_signature] = failure_information
      end
    end

    print_results method_passing, method_errors
  end

  private

  def self.print_results method_passings, method_errors
    puts "#{tested_methods.count} inline tests ran:"
    method_passings.each do |method_signature, result|
      puts "  #{result ? 'PASSED' : 'FAILED'} - #{method_signature}"
      if result == false && method_errors.key?(method_signature)
        puts "    #{method_errors[method_signature]}"
      end
    end

    nil
  end
end

puts InlineTests.run!
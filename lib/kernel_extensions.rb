module Kernel
  METHODS_WITH_INLINE_TESTS     = []
  RUN_TESTS_IN_THIS_ENVIRONMENT = true

  def tested(method_name, _ignored, &inline_test_block)
    return unless RUN_TESTS_IN_THIS_ENVIRONMENT

    method = method(method_name)
    method.inline_tests = inline_test_block
    METHODS_WITH_INLINE_TESTS << method

    method
  end
  def tests; end

  def assert(some_statement, description = '')
    passed = !!some_statement
    raise InlineTestFailure.new(@@method_being_tested, 'assert', some_statement, nil, description) unless passed

    passed
  end

  def assert_equal(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] == [rhs]")
    raise InlineTestFailure.new(@@method_being_tested, 'assert_equal', lhs, rhs, description) unless passed

    passed
  end

  def assert_not_equal(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] != [rhs]")
    raise InlineTestFailure.new(@@method_being_tested, 'assert_not_equal', lhs, rhs, description) unless passed

    passed
  end

  def assert_less_than(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] < [rhs]")
    raise InlineTestFailure.new(@@method_being_tested, 'assert_less_than', lhs, rhs, description) unless passed
    
    passed
  end

  def assert_greater_than(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] > [rhs]")
    raise InlineTestFailure.new(@@method_being_tested, 'assert_greater_than', lhs, rhs, description) unless passed
    
    passed
  end

  def assert_divisible_by(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] % [rhs] == 0")
    raise InlineTestFailure.new(@@method_being_tested, 'assert_divisible_by', lhs, rhs, description) unless passed
    
    passed
  end

  # dirty hacks for global constants :(
  module Infinity; def to_s; Float::INFINITY;     end; end
  module NaN;      def to_s; 0 * Float::INFINITY; end; end

  private

  def flexible_assert(lhs, rhs, assert_logic)
    lhs_values = lhs
    # todo: probably want a custom testresults class instead of hash
    lhs_values = lhs.values if lhs.is_a? Hash
    lhs_values = Array(lhs_values) unless lhs_values.is_a? Array

    rhs_values = rhs
    rhs_values = rhs.values if rhs.is_a? Hash
    rhs_values = Array(rhs_values) unless rhs_values.is_a? Array

    lhs_values.all? do |lhs|
      rhs_values.all? do |rhs|
        generated_source = assert_logic.gsub('[lhs]', lhs.to_s).gsub('[rhs]', rhs.to_s)
        # puts "Debug: Evaluating #{generated_source}"
        eval generated_source
      end
    end
  end
end
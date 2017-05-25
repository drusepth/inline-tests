RUN_TESTS_IN_THIS_ENVIRONMENT = false # can be set to true for tests running alongside code in dev mode

class InlineTestFailure < StandardError
  attr_accessor :method, :test_type, :lhs, :rhs, :description

  def initialize method, test_type=nil, lhs=nil, rhs=nil, description=nil
    super [
      "#{description} FAILED:",
      "      test_type: #{test_type}",
      "      lhs: #{lhs}",
      "      rhs: #{rhs}"
    ].join "\n"
    self.method = method
    self.test_type = test_type
    self.lhs = lhs
    self.rhs = rhs
    self.description = description
  end
end

module Kernel
  METHODS_WITH_INLINE_TESTS = []

  def tested method_name, _, &inline_test_block
    method = method(method_name)
    method.inline_tests = inline_test_block
    METHODS_WITH_INLINE_TESTS << method

    yield method if RUN_TESTS_IN_THIS_ENVIRONMENT
  end
  def tests; end

  def assert some_statement, description = ''
    passed = some_statement
    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert', some_statement, nil, description) unless passed
    end
  end

  def assert_equal lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] == [rhs]"

    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert_equal', lhs, rhs, description) unless passed
    end
  end

  def assert_not_equal lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] != [rhs]"
    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert_not_equal', lhs, rhs, description) unless passed
    end
  end

  def assert_less_than lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] < [rhs]"
    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert_less_than', lhs, rhs, description) unless passed
    end
  end

  def assert_greater_than lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] > [rhs]"
    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert_greater_than', lhs, rhs, description) unless passed
    end
  end

  def assert_divisible_by lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] % [rhs] == 0"
    if passed
      true
    else
      raise InlineTestFailure.new(@@method_being_tested, 'assert_divisible_by', lhs, rhs, description) unless passed
    end
  end

  # dirty hacks for global constants :(
  module Infinity; def to_s; Float::INFINITY;     end; end
  module NaN;      def to_s; 0 * Float::INFINITY; end; end

  private

  def flexible_assert lhs, rhs, assert_logic
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
        #puts generated_source
        eval generated_source
      end
    end
  end
end

# Extend Method class so we can use a shorthand for .call
class Method
  attr_accessor :inline_tests

  def [] *parameters
    homogenized_parameters = homogenized_list_of_arrays parameters

    permutation_lookup = {}

    all_range_permutations = permutations_of_list_of_ranges homogenized_parameters
    all_range_permutations.each do |parameter_permutation|
      permutation_lookup[parameter_permutation] = call(*parameter_permutation)
    end

    should_reduce_results = permutation_lookup.values.uniq.count == 1
    if should_reduce_results
      permutation_lookup.values.first
    else
      permutation_lookup
    end
  end

  def run_inline_tests
    inline_tests.call self if inline_tests && inline_tests.respond_to?(:call)
  end

  private

  def homogenized_list_of_arrays heterogenous_list
    heterogenous_list.map { |param| Array(param) }
  end

  def permutations_of_list_of_ranges list_of_ranges
    receiver, *method_arguments = list_of_ranges
    receiver.product(*method_arguments)
  end
end

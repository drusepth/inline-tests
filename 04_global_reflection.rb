RUN_TESTS_IN_THIS_ENVIRONMENT = true # set true with test suite running tool

module Kernel
  def tested method_name, tests_block
    method = method(method_name)
    @@method_being_tested = method
    if RUN_TESTS_IN_THIS_ENVIRONMENT
      puts "Testing method #{method.receiver.to_s}::#{method_name}"
      yield method
    end
  end
  def tests; end

  def assert some_statement, description = ''
    passed = some_statement

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description}"
    postassert terminal: !passed
  end

  def assert_equal lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] == [rhs]"

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} == #{rhs})"
    postassert terminal: !passed
  end

  def assert_not_equal lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] != [rhs]"

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} != #{rhs})"
    postassert terminal: !passed
  end

  def assert_less_than lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] < [rhs]"

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} < #{rhs})"
    postassert terminal: !passed
  end

  def assert_greater_than lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] > [rhs]"

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} > #{rhs})"
    postassert terminal: !passed
  end

  def assert_divisible_by lhs, rhs, description = ''
    passed = flexible_assert lhs, rhs, "[lhs] % [rhs] == 0"

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} % #{rhs}) == 0"
    postassert terminal: !passed
  end

  # dirty hacks for global constants :(
  module Infinity; def to_s; Float::INFINITY;     end; end
  module NaN;      def to_s; 0 * Float::INFINITY; end; end

  private

  def preassert message
    puts message
  end

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

  def postassert terminal: false
    if terminal
      method = @@method_being_tested # probably not threadsafe

      puts [
        "Method #{method.receiver.to_s}::#{method.name} ",
        "[#{method.source_location.first} line #{method.source_location.last}]",
        "(parameters #{method.parameters}) ",
        "FAILED assertion"
      ].join
      puts caller
      puts method.comment
      puts method.source
      exit
    end
  end
end

# Extend Method class so we can use a shorthand for .call
class Method
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

  private

  def homogenized_list_of_arrays heterogenous_list
    heterogenous_list.map { |param| Array(param) }
  end

  def permutations_of_list_of_ranges list_of_ranges
    receiver, *method_arguments = list_of_ranges
    receiver.product(*method_arguments)
  end
end

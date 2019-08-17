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
    passed = (lhs == rhs)

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} == #{rhs})"
    postassert terminal: !passed
  end

  def assert_not_equal lhs, rhs, description = ''
    passed = (lhs != rhs)

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} != #{rhs})"
    postassert terminal: !passed
  end

  def assert_less_than lhs, rhs, description = ''
    passed = (lhs < rhs)

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} < #{rhs})"
    postassert terminal: !passed
  end

  def assert_greater_than lhs, rhs, description = ''
    passed = (lhs > rhs)

    preassert "   #{passed ? 'PASSED' : 'FAILED'} #{description} (#{lhs} > #{rhs})"
    postassert terminal: !passed
  end

  private

  def preassert message
    puts message
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
      puts "Permutations: #{permutation_lookup.inspect}"
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

# Original method
def classic_divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end


# With inline ranged tests
tested def divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end,
tests do |this|
  assert_equal this(0, 3), 0,               '0 / 3 = 0'
  assert_equal this(6, 3), 2,               '6 / 3 = 2'
  assert_equal this(3, 0), Float::INFINITY, 'dividing by zero results in infinity'

  # Range/fuzzing tests (to be implemented)
  # assert_equal this((0..10_000), 0),  Float::INFINITY,  'anything / 0 == infinity'
  # assert_equal this(0, (1..10_000)),  0,                '0 / anything == 0'
end

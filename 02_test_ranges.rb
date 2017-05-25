RUN_TESTS_IN_THIS_ENVIRONMENT = true # use RAILS_ENV==development or something instead

def tested method_name, tests_block
  method = method(method_name)
  yield method if RUN_TESTS_IN_THIS_ENVIRONMENT
end

def tests
end

def assert some_statement, description = ''
  # todo some callstack reflection to grab method name/line/source
  puts "#{some_statement ? 'PASSED' : 'FAILED'} #{description}"
  exit unless some_statement
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
tests do |f|
  assert f[0, 3]  == 0,               'can use f[x, y] to call function shorthand'
  assert f.(0, 3) == 0,               '0 / 3 = 0'
  assert f.(6, 3) == 2,               '6 / 3 = 2'
  assert f.(3, 0) == Float::INFINITY, 'dividing by zero results in infinity'

  # Range tests
  assert f[(0..10_000), 0] == Float::INFINITY,  'anything / 0 == infinity'
end


puts divide 3, 6

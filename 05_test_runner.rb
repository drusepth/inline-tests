require_relative 'examples/04_operators'

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

puts "List of methods with inline tests:"
puts InlineTests.tested_methods
puts InlineTests.run!

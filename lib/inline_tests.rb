class InlineTests
  def self.tested_methods
    METHODS_WITH_INLINE_TESTS
  end

  def self.run!
    test_passes = 0
    test_fails  = 0

    puts "Starting inline test suite:"
    all_tests_start_time = Time.now
    tested_methods.select do |method|
      Kernel.class_variable_set(:@@method_being_tested, method)
      
      method_signature = if method.receiver.class.name === Object.name
        # If the receiver is an Object, it's probably #main, in which case we can just print it directly
        "#{method.receiver}::#{method.name}"

      elsif method.receiver.class.name == Class.name
        # If the receiver is the base Class, then we're dealing with a class method so we have a class ref already
        "#{method.receiver.name}::self.#{method.name}"

      else
        # If the receiver is some child class class, we want to use the class name in printable output
        "#{method.receiver.class.name}::#{method.name}"
      end

      start_time  = Time.now
      begin
        method.run_inline_tests # Throws an exception on fail
        test_time    = Time.now - start_time
        test_passes += 1

        puts "  #{method_signature} - PASSED (#{format_tiny_time test_time} seconds)"

      rescue InlineTestFailure => failure_information
        test_time   = Time.now - start_time
        errors      = failure_information
        test_fails += 1

        puts "  #{method_signature} - FAILED (#{format_tiny_time test_time} seconds)"
        puts errors
      end
    end
    all_tests_end_time = Time.now

    # Print overall test results & stats
    # print_results(method_passing, method_errors)
    puts "#{tested_methods.count} inline tests ran in #{format_tiny_time all_tests_end_time - all_tests_start_time} seconds."
    puts "  #{test_passes} PASSED"
    puts "  #{test_fails} FAILS"
  end

  private

  def self.format_tiny_time(time)
    sprintf('%.15f', time).sub(/0+$/, '').sub(/\.$/, '.0')
  end
end
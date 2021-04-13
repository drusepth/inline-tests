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
      method_signature = "#{method.receiver}::#{method.name}"

      start_time  = Time.now
      begin
        test_time    = Time.now - start_time
        test_passes += 1

        puts "  #{method_signature} - PASSED (#{test_time} seconds)"

      rescue InlineTestFailure => failure_information
        test_time   = Time.now - start_time
        errors      = failure_information
        test_fails += 1

        puts "  #{method_signature} - FAILED (#{test_time} seconds)"
        puts errors
      end
    end
    all_tests_end_time = Time.now

    # Print overall test results & stats
    # print_results(method_passing, method_errors)
    puts "#{tested_methods.count} inline tests ran in #{all_tests_end_time - all_tests_start_time} seconds."
    puts "  #{test_passes} PASSED"
    puts "  #{test_fails} FAILS"
  end
end
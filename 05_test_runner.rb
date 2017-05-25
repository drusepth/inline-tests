require_relative 'examples/04_operators'

class InlineTests
  def self.tested_methods
    METHODS_WITH_INLINE_TESTS
  end

  def self.run!
    method_passing = Hash.new(false)

    tested_methods.select do |method|
      puts "Testing method #{method.receiver.to_s}::#{method.name}"
      method_passing["#{method.receiver}::#{method.name}"] = method.run_inline_tests
    end

    puts "#{tested_methods.count} inline tests ran:"
    puts method_passing.map { |method, result| "  #{method}: #{result ? 'PASSED' : 'FAILED'}"}.join("\n")
  end
end

puts InlineTests.run!

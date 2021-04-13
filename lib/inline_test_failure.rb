class InlineTestFailure < StandardError
  attr_accessor :method, :test_type, :lhs, :rhs, :description

  def initialize(method, test_type=nil, lhs=nil, rhs=nil, description=nil)
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
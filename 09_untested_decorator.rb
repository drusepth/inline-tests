require_relative './lib/loader'

def foo(x, y)
  puts x
end

untested def bar(x, y)
  puts "no tests yet, lol"
end

tested def multiply x, y
  x * y
end,
tests do |this|
  assert_greater_than this[(-100..-1), (-100..-1)], 0, 'multiplying any two negatives should yield a positive'
end

InlineTests.run!
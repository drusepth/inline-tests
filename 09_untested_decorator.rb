require_relative './lib/loader'

def foo(x, y)
  puts x
end

untested def bar(x, y)
  puts "no tests yet, lol"
end

foo(0, 3)
bar(1, 2)
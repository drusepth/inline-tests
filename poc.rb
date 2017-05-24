def divide param_x, param_y
  return Infinity if param_y.zero?
  param_x.to_f / param_y.to_f
end

puts divide 6, 3
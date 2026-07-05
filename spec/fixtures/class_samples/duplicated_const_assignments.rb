# frozen_string_literal: true

A, A = nil, Class.new do
  a = 1
  a = 2
end

B, B = Class.new do
  b = 1
end, nil

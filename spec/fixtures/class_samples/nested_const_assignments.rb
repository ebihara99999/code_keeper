# frozen_string_literal: true

A, (B, C) = nil, [Class.new do
  b = 1
  b = 2
end, Struct.new(:c) do
  c = 1
end]

*D, E = nil, Class.new do
  e = 1
end

*F, G = Class.new do
  g = 1
end

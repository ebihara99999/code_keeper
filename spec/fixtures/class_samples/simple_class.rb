class SimpleClass
  # Two lines of comments are to check if it's really able to count lines of comments precisely.
  # To remove `class XXX` and `end`, two lines, using `node.body` doesn't count the first comment just after the `class XXX`
  a = 1

  # comment4
  a = 2
end

class RootClass
  r = 4
  class NameSpaceClass
    class A
    # A comment

      a = 1
      a = 2
    end

    # NameSpaceClass comment
    n = 1
    n = 2
    n = 3
  end
  # RootClass comment
  r = 1

  class SeperateClass
    # Descirbes a class written seperately instead of inner class.

    s = 1
  end

  r = 2
  r = 3
end

module RootModule 
  module NameSpaceModule
    # NameSpaceModule comment
    n = 1
    n = 2
    module B
      # B comment
      b = 1
      b = 2
      b = 3
      b = 4
    end
  end
  # RootModule comment
  r = 1
  r = 2
  r = 3
end

class C::D::E
  # comment
  e = 1
  e = 2
end

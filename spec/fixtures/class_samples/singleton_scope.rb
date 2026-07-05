# frozen_string_literal: true

module SingletonScopeSample
  class << self
    def module_singleton_method
      :a
    end
  end
end

class SingletonScopeOwner
  class << self
    def class_singleton_method
      :b
    end

    define_method :defined_singleton_method do
      :c
    end

    def build_helper
      define_method :built_instance_method do
        :e
      end
    end
  end
end

class SingletonScopeRuntime
  def attach
    class << self
      def tag
        :d
      end
    end
  end

  def decorate(target)
    class << target
      def label
        :f
      end
    end
  end

  def register
    def self.runtime_singleton
      :h
    end
  end
end

class << SingletonScopeOwner
  def const_singleton_method
    :g
  end
end

class << self
  def top_level_singleton_method
    :i
  end
end

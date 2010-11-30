module Utilities
  module ClassMethods

    def clean_solutions(solutions, symbol_name)
      array = solutions.inject([]) do |a, solution|
        a << solution[symbol_name].to_s
        a
      end
    end

    def clean_solutions_hash(solutions, symbol_array)
      array = solutions.inject([]) do |a, solution|
        hash = symbol_array.inject({}) do |h, sym|
          h[sym] = solution[sym].to_s
          h
        end
        a << hash
        a
      end
    end

  end

  module InstanceMethods
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
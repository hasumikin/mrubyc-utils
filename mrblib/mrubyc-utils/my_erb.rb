module MrubycUtils
  class MyERB
    def initialize(&block)
      self.instance_eval(&block)
    end
  end
end


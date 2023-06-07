module Compiler
  # llvm module
  module Module
    class << self
      # create module
      def create
        LLVM::Module.new('llvm-rb')
      end
    end
  end
end

# frozen_string_literal: true

module Fix
  module Error
    # Error raised when attempting to build a specification without a block
    class MissingSpecificationBlock < ::ArgumentError
      MISSING_BLOCK_ERROR = "Block is required for building a specification"

      def initialize
        super(MISSING_BLOCK_ERROR)
      end
    end
  end
end

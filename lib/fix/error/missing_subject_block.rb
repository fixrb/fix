# frozen_string_literal: true

module Fix
  module Error
    # Error raised when attempting to test a specification without providing a subject block
    class MissingSubjectBlock < ::ArgumentError
      MISSING_BLOCK_ERROR = "Subject block is required for testing a specification. " \
                            "Use: test { subject } or match? { subject }"

      def initialize
        super(MISSING_BLOCK_ERROR)
      end
    end
  end
end

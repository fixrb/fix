# frozen_string_literal: true

module Kernel
  # rubocop:disable Naming/MethodName
  def Fix(subject = nil, **lets, &block)
    ::Fix.describe(subject, **lets, &block)
  end
  # rubocop:enable Naming/MethodName
end

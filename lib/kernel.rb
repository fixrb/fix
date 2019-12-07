module Kernel
  def Fix(subject, **lets, &block)
    ::Fix.describe(subject, **lets, &block)
  end
end

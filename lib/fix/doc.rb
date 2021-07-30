# frozen_string_literal: true

module Fix
  # Module for storing spec documents.
  #
  # @api private
  module Doc
    # @param name [String, Symbol] The constant name of the specifications.
    def self.fetch(name)
      const_get("#{name}::CONTEXTS")
    end

    # @param contexts [Array<::Fix::Dsl>] The list of contexts document.
    def self.specs(*contexts)
      contexts.flat_map do |context|
        env = context.new

        env.public_methods(false).map do |public_method|
          [env] + env.public_send(public_method)
        end
      end
    end
  end
end

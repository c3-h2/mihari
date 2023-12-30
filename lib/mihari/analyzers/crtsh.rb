# frozen_string_literal: true

module Mihari
  module Analyzers
    #
    # crt.sh analyzer
    #
    class Crtsh < Base
      # @return [Boolean]
      attr_reader :exclude_expired

      #
      # @param [String] query
      # @param [Hash, nil] options
      # @param [Bool] exclude_expired
      #
      def initialize(query, options: nil, exclude_expired: true)
        super(query, options: options)

        @exclude_expired = exclude_expired
      end

      def artifacts
        exclude = exclude_expired ? "expired" : nil
        client.search(query, exclude: exclude).map do |result|
          values = result["name_value"].to_s.lines.map(&:chomp).reject { |value| value.starts_with?("*.") }
          values.map { |value| Models::Artifact.new(data: value, metadata: result) }
        end.flatten
      end

      private

      #
      # @return [Mihari::Clients::Crtsh]
      #
      def client
        Mihari::Clients::Crtsh.new(timeout: timeout)
      end
    end
  end
end

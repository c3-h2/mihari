# frozen_string_literal: true

module Mihari
  module Models
    #
    # Reverse DNS name model
    #
    class ReverseDnsName < ActiveRecord::Base
      belongs_to :artifact

      class << self
        include Dry::Monads[:result]

        #
        # Build reverse DNS names
        #
        # @param [String] ip
        # @param [Mihari::Enrichers::Shodan] enricher
        #
        # @return [Array<Mihari::Models::ReverseDnsName>]
        #
        def build_by_ip(ip, enricher: Enrichers::Shodan.new)
          result = enricher.result(ip).bind do |res|
            if res.nil?
              Success []
            else
              Success(res.hostnames.map { |name| new(name: name) })
            end
          end
          result.value_or []
        end
      end
    end
  end
end

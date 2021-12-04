# frozen_string_literal: true

require "urlscan"

module Mihari
  module Analyzers
    class Urlscan < Base
      param :query
      option :title, default: proc { "urlscan search" }
      option :description, default: proc { "query = #{query}" }
      option :tags, default: proc { [] }
      option :allowed_data_types, default: proc { SUPPORTED_DATA_TYPES }

      option :interval, default: proc { 0 }

      SUPPORTED_DATA_TYPES = %w[url domain ip].freeze
      SIZE = 1000

      def initialize(*args, **kwargs)
        super

        raise InvalidInputError, "allowed_data_types should be any of url, domain and ip." unless valid_alllowed_data_types?
      end

      def artifacts
        responses = search
        results = responses.map(&:results).flatten

        allowed_data_types.map do |type|
          results.filter_map do |result|
            page = result.page
            page.send(type.to_sym)
          end.uniq
        end.flatten.compact
      end

      private

      def configuration_keys
        %w[urlscan_api_key]
      end

      def api
        @api ||= ::UrlScan::API.new(Mihari.config.urlscan_api_key)
      end

      #
      # Search with search_after option
      #
      # @return [Structs::Urlscan::Response]
      #
      def search_with_search_after(search_after: nil)
        res = api.search(query, size: SIZE, search_after: search_after)
        Structs::Urlscan::Response.from_dynamic! res
      end

      #
      # Search
      #
      # @return [Array<Structs::Urlscan::Response>]
      #
      def search
        responses = []

        search_after = nil
        loop do
          res = search_with_search_after(search_after: search_after)
          responses << res

          break if res.results.length < SIZE

          search_after = res.results.last.sort.join(",")

          # sleep #{interval} seconds to avoid the rate limitation (if it is set)
          sleep interval
        end

        responses
      end

      #
      # Check whether a data type is valid or not
      #
      # @return [Boolean]
      #
      def valid_alllowed_data_types?
        allowed_data_types.all? { |type| SUPPORTED_DATA_TYPES.include? type }
      end
    end
  end
end

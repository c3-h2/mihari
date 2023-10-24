# frozen_string_literal: true

module Mihari
  module Structs
    module GreyNoise
      class Metadata < Dry::Struct
        include Mixins::AutonomousSystem

        attribute :country, Types::String
        attribute :country_code, Types::String
        attribute :asn, Types::String

        #
        # @return [String]
        #
        def country
          attributes[:country]
        end

        #
        # @return [String]
        #
        def country_code
          attributes[:country_code]
        end

        #
        # @return [String]
        #
        def asn
          attributes[:asn]
        end

        #
        # @return [Mihari::AutonomousSystem]
        #
        def as
          Mihari::Models::AutonomousSystem.new(asn: normalize_asn(asn))
        end

        #
        # @return [Mihari::Geolocation]
        #
        def geolocation
          Mihari::Models::Geolocation.new(
            country: country,
            country_code: country_code
          )
        end

        class << self
          #
          # @param [Hash] d
          #
          # @return [Metadata]
          #
          def from_dynamic!(d)
            d = Types::Hash[d]
            new(
              country: d.fetch("country"),
              country_code: d.fetch("country_code"),
              asn: d.fetch("asn")
            )
          end
        end
      end

      class Datum < Dry::Struct
        attribute :ip, Types::String
        attribute :metadata, Metadata
        attribute :metadata_, Types::Hash

        #
        # @return [String]
        #
        def ip
          attributes[:ip]
        end

        #
        # @return [Metadata]
        #
        def metadata
          attributes[:metadata]
        end

        #
        # @return [Hash]
        #
        def metadata_
          attributes[:metadata_]
        end

        #
        # @return [Mihari::Models::Artifact]
        #
        def artifact
          Mihari::Models::Artifact.new(
            data: ip,
            metadata: metadata_,
            autonomous_system: metadata.as,
            geolocation: metadata.geolocation
          )
        end

        class << self
          #
          # @param [Hash] d
          #
          # @return [Datum]
          #
          def from_dynamic!(d)
            d = Types::Hash[d]
            new(
              ip: d.fetch("ip"),
              metadata: Metadata.from_dynamic!(d.fetch("metadata")),
              metadata_: d
            )
          end
        end
      end

      class Response < Dry::Struct
        attribute :complete, Types::Bool
        attribute :count, Types::Int
        attribute :data, Types.Array(Datum)
        attribute :message, Types::String
        attribute :query, Types::String
        attribute :scroll, Types::String.optional

        #
        # @return [Boolean]
        #
        def complete
          attributes[:complete]
        end

        #
        # @return [Integer]
        #
        def count
          attributes[:count]
        end

        #
        # @return [Array<Datum>]
        #
        def data
          attributes[:data]
        end

        #
        # @return [String]
        #
        def message
          attributes[:message]
        end

        #
        # @return [String]
        #
        def query
          attributes[:query]
        end

        #
        # @return [String, nil]
        #
        def scroll
          attributes[:scroll]
        end

        #
        # @return [Array<Mihari::Models::Artifact>]
        #
        def artifacts
          data.map(&:artifact)
        end

        class << self
          #
          # @param [Hash] d
          #
          # @return [Response]
          #
          def from_dynamic!(d)
            d = Types::Hash[d]
            new(
              complete: d.fetch("complete"),
              count: d.fetch("count"),
              data: d.fetch("data").map { |x| Datum.from_dynamic!(x) },
              message: d.fetch("message"),
              query: d.fetch("query"),
              scroll: d["scroll"]
            )
          end
        end
      end
    end
  end
end

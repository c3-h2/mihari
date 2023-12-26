# frozen_string_literal: true

module Mihari
  module Commands
    #
    # Alert sub-commands
    #
    module Alert
      class << self
        # rubocop:disable Metrics/AbcSize
        def included(thor)
          thor.class_eval do
            include Mixins

            desc "create [PATH]", "Create an alert"
            around :with_db_connection
            #
            # @param [String] path
            #
            def create(path)
              # @type [Mihari::Models::Alert]
              alert = Dry::Monads::Try[StandardError] do
                raise ArgumentError, "#{path} does not exist" unless Pathname(path).exist?

                params = YAML.safe_load(
                  ERB.new(File.read(path)).result,
                  permitted_classes: [Date, Symbol]
                )
                Services::AlertCreator.call params
              end.value!
              data = Entities::Alert.represent(alert)
              puts JSON.pretty_generate(data.as_json)
            end

            desc "list [QUERY]", "List/search alerts"
            around :with_db_connection
            method_option :page, type: :numeric, default: 1
            method_option :limit, type: :numeric, default: 10
            #
            # @param [String] q
            #
            def list(q = "")
              filter = Structs::Filters::Search.new(q: q, page: options["page"], limit: options["limit"])
              value = Services::AlertSearcher.result(filter).value!
              data = Entities::AlertsWithPagination.represent(
                results: value.results,
                total: value.total,
                current_page: value.filter[:page].to_i,
                page_size: value.filter[:limit].to_i
              )
              puts JSON.pretty_generate(data.as_json)
            end

            desc "get [ID]", "Get an alert"
            around :with_db_connection
            #
            # @param [Integer] id
            #
            def get(id)
              value = Services::AlertGetter.result(id).value!
              data = Entities::Alert.represent(value)
              puts JSON.pretty_generate(data.as_json)
            end

            desc "delete [ID]", "Delete an alert"
            around :with_db_connection
            #
            # @param [Integer] id
            #
            def delete(id)
              Services::AlertDestroyer.result(id).value!
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end

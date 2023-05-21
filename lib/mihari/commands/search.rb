# frozen_string_literal: true

module Mihari
  module Commands
    module Search
      class << self
        class RuleWrapper
          include Mixins::ErrorNotification

          # @return [Nihari::Structs::Rule]
          attr_reader :rule

          # @return [Boolean]
          attr_reader :force_overwrite

          def initialize(rule:, force_overwrite:)
            @rule = rule
            @force_overwrite = force_overwrite
          end

          def force_overwrite?
            force_overwrite
          end

          #
          # @return [Boolean]
          #
          def diff?
            model = Mihari::Rule.find(rule.id)
            model.data != rule.data.deep_stringify_keys
          rescue ActiveRecord::RecordNotFound
            false
          end

          def update_or_create
            rule.model.save
          end

          def run
            with_error_notification do
              alert = rule.analyzer.run
              if alert
                data = Mihari::Entities::Alert.represent(alert)
                puts JSON.pretty_generate(data.as_json)
              else
                Mihari.logger.info "There is no new artifact found"
              end
            end
          end
        end

        def included(thor)
          thor.class_eval do
            desc "search [PATH]", "Search by a rule"
            method_option :force_overwrite, type: :boolean, aliases: "-f", desc: "Force an overwrite the rule"
            #
            # Search by a rule
            #
            # @param [String] path_or_id
            #
            def search(path_or_id)
              Mihari::Database.with_db_connection do
                rule = Structs::Rule.from_path_or_id path_or_id

                begin
                  rule.validate!
                rescue RuleValidationError
                  return
                end

                force_overwrite = options["force_overwrite"] || false
                wrapper = RuleWrapper.new(rule: rule, force_overwrite: force_overwrite)

                if wrapper.diff? && !force_overwrite
                  message = "There is diff in the rule (#{rule.id}). Are you sure you want to overwrite the rule? (y/n)"
                  return unless yes?(message)
                end

                wrapper.update_or_create
                wrapper.run
              end
            end
          end
        end
      end
    end
  end
end

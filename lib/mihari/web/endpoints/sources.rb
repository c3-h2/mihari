# frozen_string_literal: true

module Mihari
  module Endpoints
    class Sources < Grape::API
      namespace :sources do
        desc "Get sources", {
          success: Entities::Sources
        }
        get "/" do
          sources = Mihari::Alert.distinct.pluck(:source)
          present({ sources: sources }, with: Entities::Sources)
        end
      end
    end
  end
end

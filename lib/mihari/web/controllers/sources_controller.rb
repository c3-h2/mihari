# frozen_string_literal: true

require "sinatra"
require "sinatra/json"

module Mihari
  module Controllers
    class SourcesController < Sinatra::Base
      get "/api/sources" do
        tags = Mihari::Alert.distinct.pluck(:source)
        json tags
      end
    end
  end
end

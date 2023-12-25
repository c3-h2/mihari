# frozen_string_literal: true

class AlertCLI < Mihari::CLI::Base
  include Mihari::Commands::Alert
end

RSpec.describe Mihari::Commands::Alert do
  include_context "with database fixtures"

  let_it_be(:alert) { Mihari::Models::Alert.first }

  describe "#list" do
    it do
      expect { AlertCLI.start ["list"] }.to output(include(alert.id.to_s)).to_stdout
    end
  end

  describe "#get" do
    it do
      expect { AlertCLI.start ["get", alert.id.to_s] }.to output(include(alert.id.to_s)).to_stdout
    end
  end
end

# frozen_string_literal: true

RSpec.describe Mihari::Analyzers::DNSTwister, :vcr do
  subject(:analyzer) { described_class.new(query) }

  let!(:query) { "example.com" }

  describe "#artifacts" do
    before do
      allow(Resolv).to receive(:getaddress).and_return("1.1.1.1")
    end

    it do
      expect(analyzer.artifacts).to be_an(Array)
    end
  end
end

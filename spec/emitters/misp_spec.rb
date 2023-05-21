# frozen_string_literal: true

RSpec.describe Mihari::Emitters::MISP, :vcr do
  include_context "with database fixtures"

  let(:artifacts) { [Mihari::Artifact.new(data: "1.1.1.1")] }
  let(:rule) { Mihari::Structs::Rule.from_model(Mihari::Rule.first) }

  subject { described_class.new(artifacts: artifacts, rule: rule) }

  describe "#valid?" do
    context "when MISP_URL & MISP_API_KEY are not given" do
      before do
        allow(Mihari.config).to receive(:misp_url).and_return(nil)
        allow(Mihari.config).to receive(:misp_api_key).and_return(nil)
      end

      it do
        expect(subject.valid?).to be(false)
      end
    end
  end

  describe "#emit" do
    it do
      subject.emit
    end
  end
end

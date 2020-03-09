require 'active_support/ordered_options'
module Figaro
  module Rails
    describe Application do

      describe "#skip_secret" do
        let!(:application) { Application.new }
        let(:secrets) {
          secrets = ActiveSupport::OrderedOptions.new
          secrets.TWILIO_CALLER_ID = "somevalue"
          secrets
        }
        subject {
          application.load_secrets
        }
        it "skips setting from secrets when set in ENV already" do
          allow(::Rails).to receive_message_chain(:application, :secrets) { secrets }
          allow(::ENV).to receive(:[]).with("TWILIO_CALLER_ID").and_return("+15555551212")
          subject
          expect(::ENV["TWILIO_CALLER_ID"]).to eq("+15555551212")
        end

        it "skips setting from secrets when set in Figaro app.yml already" do
          allow(::Rails).to receive_message_chain(:application, :secrets) { secrets }
          allow(::ENV).to receive(:[]).with("TWILIO_CALLER_ID").and_return("+15555551212")
          allow(::ENV).to receive(:[]).with("_FIGARO_TWILIO_CALLER_ID").and_return("+15555551212")
          subject
          expect(::ENV["TWILIO_CALLER_ID"]).to eq("+15555551212")
          expect(::ENV["_FIGARO_TWILIO_CALLER_ID"]).to eq("+15555551212")
        end

        it "does not skip setting from secrets when not set in env or app.yml" do
          allow(::Rails).to receive_message_chain(:application, :secrets) { secrets }
          subject
          expect(::ENV["TWILIO_CALLER_ID"]).to eq("somevalue")
        end
      end

      describe "#load_secrets" do
        let!(:application) { Application.new }
        let(:secrets) {
          secrets = ActiveSupport::OrderedOptions.new
          secrets.string_key = "somevalue"
          secrets.hash_key   = {"key" => "value"}
          secrets.boolean_key = true
          secrets.foo = "bar"
          secrets
        }

        subject {
          application.load_secrets
        }

        it "that exist in the Rails.application.secrets" do
          allow(::Rails).to receive_message_chain(:application, :secrets) { secrets }
          subject
          expect(::ENV["string_key"]).to eq "somevalue"
          expect(::ENV["hash_key"]).to eq "{\"key\"=>\"value\"}"
          expect(::ENV["boolean_key"]).to eq "true"
        end

        it "does not overwrite values" do
          allow(::Rails).to receive_message_chain(:application, :secrets) { secrets }
          ::ENV["foo"] = "baz"

          expect(application).to receive(:warn).at_least(:once)

          expect {
            application.load_secrets
          }.not_to change {
            ::ENV["foo"]
          }
        end

      end

      describe "#default_path" do
        let!(:application) { Application.new }

        it "defaults to config/application.yml in Rails.root" do
          allow(::Rails).to receive(:root) { Pathname.new("/path/to/app") }

          expect {
            allow(::Rails).to receive(:root) { Pathname.new("/app") }
          }.to change {
            application.send(:default_path).to_s
          }.from("/path/to/app/config/application.yml").to("/app/config/application.yml")
        end

        it "raises an error when Rails.root isn't set yet" do
          allow(::Rails).to receive(:root) { nil }

          expect {
            application.send(:default_path)
          }.to raise_error(RailsNotInitialized)
        end
      end

      describe "#default_environment" do
        let!(:application) { Application.new }

        it "defaults to Rails.env" do
          allow(::Rails).to receive(:env) { "development" }

          expect {
            allow(::Rails).to receive(:env) { "test" }
          }.to change {
            application.send(:default_environment).to_s
          }.from("development").to("test")
        end

        it "uses env/stackname when STACK_NAME is present" do
          allow(::Rails).to receive(:env) { "development" }
          allow(::ENV).to receive(:[]).
            with('STACK_NAME').
            and_return('mystack')

          expect(application.send(:default_environment)).to eq "development/mystack"
        end

      end
    end
  end
end

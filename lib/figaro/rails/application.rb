module Figaro
  module Rails
    class Application < Figaro::Application

      def load_secrets
        ::Rails.application.secrets.each do |key,value|
          skip?(key) ? key_skipped!(key) : set(key, value)
        end
      end

      private

      def default_path
        rails_not_initialized! unless ::Rails.root

        ::Rails.root.join("config", "application.yml")
      end

      def default_environment
        unless ::ENV['STACK_NAME'].nil?
          "#{::Rails.env}/#{::ENV['STACK_NAME']}"
        else
          ::Rails.env
        end
      end

      def rails_not_initialized!
        raise RailsNotInitialized
      end
    end
  end
end

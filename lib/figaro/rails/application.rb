module Figaro
  module Rails
    class Application < Figaro::Application
      def skip_secret?(key)
        ::ENV.key?(key.to_s)
      end

      def load_secrets
        ::Rails.application.secrets.each do |key,value|
          # Proactive convert to string to avoid warning about string conversion
          key = key.to_s
          if skip_secret?(key)
            key_skipped!(key)
          else
            warn "WARNING: [SET] Setting key #{key.inspect} from Rails.application.secrets.#{key} ..."
            set(key, value)
          end
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

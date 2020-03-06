module Figaro
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        Figaro.load
      end

      config.before_initialize do
        Figaro.application.load_secrets
      end
    end
  end
end

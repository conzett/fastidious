# frozen_string_literal: true

module Fastidious
  class Railtie < Rails::Railtie
    # TODO: Automate task loading, probably only a few we want to skip
    
    rake_tasks do
      load File.expand_path('../tasks/auth.rake', __dir__)
      load File.expand_path('../tasks/tidy.rake', __dir__)
    end
  end
end

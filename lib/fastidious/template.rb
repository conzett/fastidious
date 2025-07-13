# frozen_string_literal: true

require 'find'
require 'pry'

RUBY_VERSION = '3.2.2'

GEMFILE = <<~RUBY.freeze
  source "https://rubygems.org"

  ruby "#{RUBY_VERSION}"

  gem "bootsnap", require: false
  gem "fastidious", path: "../../fastidious"
  gem "importmap-rails"
  gem "propshaft"
  gem "puma", ">= 5.0"
  gem "rails", "~> 8.0.2"
  gem "sqlite3"
  gem "turbo-rails"

  group :development, :test do
    gem "brakeman", require: false
    gem "pry-rails"
  end
RUBY

# NOTE: There is no `before_bundle` so write our own Gemfile first
File.write 'Gemfile', GEMFILE

# NOTE: All the content is inlined here so the script can be self-contained
# and run from a URL. In the future we might build this from a directory

CONTENT = {
  'app/assets/stylesheets/application.css' => '',
  'app/controllers/application_controller.rb' => <<~RUBY,
    class ApplicationController < ActionController::Base
    end
  RUBY

  'app/helpers/application_helper.rb' => nil,
  'app/javascript/application.js' => '',
  'app/jobs/application_job.rb' => <<~RUBY,
    class ApplicationJob < ActiveJob::Base
    end
  RUBY

  'app/models/application_record.rb' => nil,
  'app/views/layouts/application.html.erb' => '<%= yield %>',
  'bin/brakeman' => <<~RUBY,
    #{shebang}

    require "rubygems"
    require "bundler/setup"

    ARGV.unshift "--ensure-latest"

    load Gem.bin_path "brakeman", "brakeman"
  RUBY

  'bin/importmap' => nil,
  'bin/rails' => <<~RUBY,
    #{shebang}

    APP_PATH = File.expand_path "../config/application", __dir__

    require_relative "../config/boot"
    require "rails/commands"
  RUBY

  'bin/rake' => <<~RUBY,
    #{shebang}

    require_relative "../config/boot"
    require "rake"

    Rake.application.run
  RUBY

  'bin/rubocop' => <<~RUBY,
    #{shebang}

    require "rubygems"
    require "bundler/setup"

    ARGV.unshift "--config", File.expand_path("../.rubocop.yml", __dir__)

    load Gem.bin_path "rubocop", "rubocop"
  RUBY

  'config/environments/development.rb' => <<~RUBY,
    require "fastidious/rails/config/environments/development"
  RUBY

  'config/environments/production.rb' => <<~RUBY,
    require "fastidious/rails/config/environments/production"
  RUBY

  'config/environments/test.rb' => <<~RUBY,
    require "fastidious/rails/config/environments/test"
  RUBY

  'config/initializers/assets.rb' => <<~RUBY,
    Rails.application.config.assets.version = "1.0"
  RUBY

  'config/initializers/filter_parameter_logging.rb' => <<~RUBY,
    require "fastidious/rails/config/initializers/filter_parameter_logging"
  RUBY

  'config/locales/en.yml' => 'en:',

  'config/application.rb' => <<~RUBY,
    require_relative "boot"
    require "rails/all"

    Bundler.require(*Rails.groups)

    module #{app_const_base}
      class Application < Rails::Application
        config.load_defaults 8.0
        config.autoload_lib ignore: %w[assets tasks]
      end
    end
  RUBY

  'config/boot.rb' => <<~RUBY,
    ENV["BUNDLE_GEMFILE"] ||= File.expand_path "../Gemfile", __dir__

    require "bundler/setup"
    require "bootsnap/setup"
  RUBY

  'config/database.yml' => <<~YAML,
    default: &default
      adapter: sqlite3
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      timeout: 5000

    development:
      <<: *default
      database: storage/development.sqlite3

    test:
      <<: *default
      database: storage/development.sqlite3
  YAML

  'config/environment.rb' => <<~RUBY,
    require_relative "application"

    Rails.application.initialize!
  RUBY

  'config/importmap.rb' => 'pin "application"',
  'config/routes.rb' => <<~RUBY,
    Rails.application.routes.draw do
      get "up" => "rails/health#show", as: :rails_health_check
    end
  RUBY

  "public/index.html" => "Welcome",

  '.gitattributes' => <<~TEXT,
    bin/*          linguist-generated
    config/*       linguist-generated
    db/schema.rb   linguist-generated
    .gitattributes linguist-generated
    .gitignore     linguist-generated
    .rubocop-yml   linguist-generated
    .ruby-version  linguist-generated
    .config.ru     linguist-generated
    Gemfile.lock   linguist-generated
    Rakefile       linguist-generated
  TEXT

  '.gitignore' => <<~TEXT,
    /log/*
    /storage/*
    /tmp/*
    /.env*
  TEXT

  '.rubocop.yml' => 'inherit_gem: { rubocop-rails-omakase: rubocop.yml }',
  '.ruby-version' => <<~TEXT,
    ruby-#{RUBY_VERSION}
  TEXT

  'config.ru' => <<~RUBY,
    require_relative "config/environment"

    run Rails.application
    Rails.application.load_server
  RUBY

  'Gemfile' => nil, # NOTE: Use the one we already wrote
  'Gemfile.lock' => nil,
  'Rakefile' => <<~RUBY,
    require_relative "config/application"

    Rails.application.load_tasks
  RUBY

  'README.md' => <<~MARKDOWN
    # README
  MARKDOWN
}.transform_keys { "./#{_1}" }

IGNORE = %w[
  .git
  tmp
].map { "./#{_1}" }

REMOVE = %w[
  .github
  app/assets/images
  app/controllers/concerns
  app/mailers
  app/models/concerns
  app/views/pwa
  log
  script
  test/controllers
  test/mailers
  test/system
  vendor
].map { "./#{_1}" }

PRUNE = IGNORE + REMOVE

# NOTE: This speeds things up and prevents generating things we will remove

module MonkeyPatch
  def run_hotwire; end
  def run_kamal; end
  def run_solid; end
end

Rails::Generators::AppGenerator.prepend MonkeyPatch

def rewrite
  Find.find('./') do |path|
    next if path == './'

    if FileTest.directory? path
      remove_dir path if REMOVE.include? path
      Find.prune if PRUNE.include? path
    elsif CONTENT.key? path
      val = CONTENT[path]

      if val.nil?
        puts "       allow  #{path}"
      else
        File.write path, val
      end
    else
      remove_file path
    end
  end
end

after_bundle do
  rewrite
end

# frozen_string_literal: true

require "fileutils"
require "find"

# TODO: Migrate to Rails generator 

namespace :fast do
  namespace :auth do
    TEMPLATE_PATH = File.expand_path '../fastidious/generator/auth', __dir__

    desc 'Wraps the Rails auth generator for 💅'
    task :generate do
      removal_paths = %w[
        app/channels/application_cable/connection.rb
        app/models/current.rb
        app/views/passwords/new.html.erb
        app/views/passwords_mailer/reset.html.erb
        app/views/passwords_mailer/reset.text.erb
      ]

      Rails::Command.invoke 'generate', %w[authentication]

      # TODO: Only if these don't exist?

      # TODO: ApplicationMailer if it doesn't exist
      # TODO: UserController if it doesn't exist

      removal_paths.each do |path|
        remove_file path

        # rails_path = File.join Rails.root, path
        # FileUtils.rm_rf rails_path
      end

      # resources :passwords, param: :token, only: %i[edit update]
      # resources :password_reset_emails, only: %i[new create]
      # resources :users, only: %i[new create]

      # resource :session, only: %i[new create destroy]
      # resolve("Session") { %i[session] }

      # root to: redirect("index.html")
      
      # unless File.read("config/routes.rb").include?("resolve(\"session\")")
      #   insert_into_file "config/routes.rb", <<~RUBY, after: "resource :session\n"
      #     resolve("Session") { %i[session] }
      #   RUBY
      # end

      # unless File.read("Gemfile").include?("bcrypt")
      #   insert_into_file "Gemfile", <<~RUBY, after: /^source ['"].+['"]\n/
      #     gem "bcrypt"
      #   RUBY
      # end

      # TODO: Task that removes empty directories that we can run after this

      for_each_template_file do |path, dest|
        FileUtils.mkdir_p File.dirname(dest)
        copy_file path, dest
      end
    end

    desc 'Reverses auth generator'
    task :destroy do
      Rails::Command.invoke 'destroy', %w[authentication]

      for_each_template_file do |_path, dest|
        puts dest
        # remove_file dest
      end
    end

    private

    def for_each_template_file
      Find.find TEMPLATE_PATH do |path|
        next unless File.file? path

        dest = File.join Rails.root, path.delete_prefix(TEMPLATE_PATH)
        yield path, dest if block_given?
      end
    end
  end
end

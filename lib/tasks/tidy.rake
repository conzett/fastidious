# frozen_string_literal: true

namespace :fast do
  namespace :tidy do
    desc 'Remove comments from schema.rb'
    task :schema do
      data = File.read('db/schema.rb')
      data = data.gsub(/#.*\n+/, '')
      File.write 'db/schema.rb', data
    end
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['fast:tidy:schema'].execute
end

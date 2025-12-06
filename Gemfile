source 'https://rubygems.org'

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.5'

# Use Oracle as the primary database
gem 'activerecord-oracle_enhanced-adapter', '~> 7.0'
gem 'ruby-oci8', '~> 2.2'

# Use MongoDB for document storage
gem 'mongoid', '~> 8.0'

# Load environment variables from .env files
gem 'dotenv-rails', groups: [:development, :test]


# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'



# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false


# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors', '~> 2.0' 

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
end

group :development do
  gem 'pry-rails', '~> 0.3.11'
  gem 'pry-nav', '~> 1.0' 
  gem 'bullet', '~> 8.1'
end




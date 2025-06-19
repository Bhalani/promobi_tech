source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "active_model_serializers"

gem "dry-validation"
gem "dry-matcher"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails"
  gem "factory_bot_rails"

  # Security scanning
  gem "brakeman", require: false

  # Code quality
  gem "rubocop-rails-omakase", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
end

group :test do
  gem "shoulda-matchers"
end

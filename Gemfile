source 'https://rubygems.org'

gemspec

## Code Quality
gem "cane", :platforms => [:mri_19, :mri_20], :require => false
gem 'coveralls', :require => false

## Test tools
gem 'rake', '~> 10.3', require: false
gem 'middleman-pry', '~> 0.0', group: :development, require: false
gem 'aruba', '~> 0.6', require: false
gem 'capybara', '~> 2.5.0', require: false # middleman-core forces all plugins to declare this
# gem 'rspec', '~> 3.0', require: false
gem 'cucumber', '~> 1.3', require: false

## Markdown parser
gem 'kramdown'

platforms :ruby do
  gem 'redcarpet', "~> 3.0"
end

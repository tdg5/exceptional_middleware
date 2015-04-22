source "https://rubygems.org"

gemspec

gem "remotely_exceptional",
  :git => "https://github.com/tdg5/remotely_exceptional.git",
  :branch => :master

group :doc do
  gem "yard"
end

group :test do
  gem "coveralls", :require => false
  gem "guard"
  gem "guard-minitest"
  gem "minitest", ">= 3.0"
  gem "mocha"
  gem "simplecov", :require => false
end

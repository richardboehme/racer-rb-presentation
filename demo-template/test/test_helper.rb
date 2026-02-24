ENV["RAILS_ENV"] ||= "test"
require "racer/minitest"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    include Oaken.loader.test_setup
  end
end

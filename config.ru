require "bundler"
Bundler.require :default

require_relative "app"
run Sinatra::Application

ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'sinatra/base'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class AppServer < Sinatra::Base
  get '/' do
    "Hi, I'm an app tiny_tds gem!"
  end

  run! if app_file == $0
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'memo/it'
require 'byebug'

require 'minitest/autorun'
require 'mocha/mini_test'

Dir[File.dirname(__FILE__) + "/helpers/*.rb"].sort.each { |f| require File.expand_path(f) }

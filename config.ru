# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'testudo'

run Rack::Cascade.new [Testudo::Application, Testudo::API]

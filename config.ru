$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'testudo'

run Testudo::Application

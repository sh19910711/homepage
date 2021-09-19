require 'logger'
require_relative 'app/app'

logger = Logger.new(STDOUT)
def logger.write(msg); end
use Rack::CommonLogger, logger

run Homepage::App

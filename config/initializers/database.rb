# frozen_string_literal: true
require "logger"
require "sequel"
DB = Sequel.connect(ENV.fetch("DATABASE_URL", "postgresql://localhost/shower_development"), logger: Logger.new(STDERR))

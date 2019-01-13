# frozen_string_literal: true
require "i18n"
I18n.load_path << Dir[File.expand_path("../locales", __dir__) + "/*.yml"]
I18n.available_locales = [ :fr, :en ]
I18n.default_locale = :fr

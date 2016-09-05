require 'garner/mixins/active_record'

module ActiveRecord
  class Base
    include Garner::Mixins::ActiveRecord::Base
  end
end

Garner.configure do |config|
  config.cache = Application.config.cache
end

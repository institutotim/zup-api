module ActiveRecordEntity
  extend ActiveSupport::Concern

  def entity(*args)
    self.class::Entity.represent(self, *args)
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordEntity)

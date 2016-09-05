module GrapeEntityHelper
  extend ActiveSupport::Concern

  def extract_options_for(attr)
    if options[:only]
      user_options = options.dup

      # The :only attribute can be an array of hashes or symbols, or mixed
      # e.g
      # - [:id, :user]
      # - [:id, { user: [:id, :name] }]
      user_options[:only] = user_options[:only].select do |i|
        (i.is_a?(Hash) && i.keys.include?(attr))
      end

      if user_options[:only].any?
        user_options[:only] = user_options[:only].first[attr]
      else
        user_options.delete(:only)
      end

      user_options
    else
      options
    end
  end
end

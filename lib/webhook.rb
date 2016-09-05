require 'uri'
require 'net/http'

class Webhook
  class ExternalCategoryNotFound < StandardError; end

  cattr_accessor :url, :update_url, :categories_relation

  def self.find_category_by_title(title)
    category = Hash[categories_relation.map do |k, v| [
      k.mb_chars.downcase.to_s, v]
    end][title.mb_chars.downcase.to_s]

    fail ExternalCategoryNotFound unless category

    category
  end

  def self.load_categories_from_file(file_path)
    self.categories_relation ||= YAML.load_file(file_path)
  end

  def self.enabled?
    !url.nil? && !update_url.nil? && !categories_relation.nil?
  end

  def self.external_category_id(category)
    find_category_by_title(category.title)[1]
  end

  def self.external_category?(category)
    !external_category_id(category).nil?
  rescue
    false
  end

  def self.integration_categories
    Reports::Category.where(
      title: categories_relation.map do |k, _v|
        k
      end
    )
  end

  def self.report?(category)
    find_category_by_title(category.title)[0] == 'O'
  end

  def self.solicitation?(category)
    find_category_by_title(category.title)[0] == 'S'
  end

  def self.zup_category(external_category_id)
    title = categories_relation.invert.select do |k, _v|
      k[1] == external_category_id.to_i
    end.values.first

    if title.present?
      Reports::Category.find_by(title: title)
    end
  end
end

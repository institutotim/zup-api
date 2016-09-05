class Inventory::RenderCategoryFormData
  attr_reader :category, :user

  def initialize(category, user)
    @category = category
    @user = user
  end

  def render
    sections = category.sections.includes(fields: :field_options)
    {
      sections: Inventory::Section::Entity.represent(sections, user: user)
    }
  end
end

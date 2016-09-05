class CaseStepDataAttachment < ActiveRecord::Base
  mount_uploader :attachment, FilesUploader

  belongs_to :case_step_data_field

  def url
    attachment.url
  end

  class Entity < Grape::Entity
    expose :id
    expose :url
    expose :file_name
  end
end

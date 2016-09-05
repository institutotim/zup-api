module Reports
  class Perimeter < Reports::Base
    include EncodedFileUploadable
    include PgSearch
    include NamespaceFilterable

    belongs_to :group,
      foreign_key: 'solver_group_id'

    belongs_to :namespace

    has_many :category_perimeters,
      class_name: 'Reports::CategoryPerimeter',
      foreign_key: 'reports_perimeter_id',
      dependent: :delete_all

    default_scope { order(created_at: :asc) }

    scope :actives, -> { where(active: true) }

    scope :search, ->(latitude, longitude) do
      imported
      .where("ST_Contains(geometry, ST_GeomFromText('POINT(? ?)', 4326))", longitude.to_f, latitude.to_f)
    end

    pg_search_scope :search_by_title, against: :title,
      using: { tsearch: { prefix: true } },
      ignoring: :accents

    validates :title, :shp_file, :shx_file, :priority, :namespace, presence: true
    validates :priority, numericality: { greater_than_or_equal_to: 0,
                                         less_than_or_equal_to: 100 }

    after_commit :import_shapefile

    enum status: [
      :pendent,
      :imported,
      :invalid_file,
      :invalid_quantity,
      :invalid_geometry,
      :unknown_error
    ]

    mount_uploader :shp_file, ShapefileUploader
    mount_uploader :shx_file, ShapefileUploader

    accepts_encoded_file :shp_file, :shx_file

    def enable!
      update!(active: true)
    end

    def disable!
      update!(active: false)
    end

    class Entity < Grape::Entity
      expose :id
      expose :title
      expose :status
      expose :priority
      expose :active
      expose :created_at
      expose :updated_at
      expose :group
      expose :namespace, using: Namespace::Entity
    end

    private

    def import_shapefile
      if pendent?
        ImportShapefile.perform_in(1.minutes, id)
      end
    end
  end
end

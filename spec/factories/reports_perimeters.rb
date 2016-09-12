FactoryGirl.define do
  factory :reports_perimeter, class: 'Reports::Perimeter' do
    namespace { Namespace.first_or_create(default: true, name: 'Namespace') }

    title 'Perimeter'
    status :pendent
    shp_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/valid_shapefile.shp") }
    shx_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/valid_shapefile.shx") }

    trait :invalid_file do
      shp_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_file.shp") }
      shx_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_file.shx") }
    end

    trait :invalid_geometry do
      shp_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_geometry.shp") }
      shx_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_geometry.shx") }
    end

    trait :invalid_quantity do
      shp_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_quantity.shp") }
      shx_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_quantity.shx") }
    end

    trait :invalid_srid do
      shp_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_srid.shp") }
      shx_file { fixture_file_upload("#{Application.config.root}/spec/fixtures/shapefiles/invalid_srid.shx") }
    end

    trait :imported do
      status 1
      geometry { File.read("#{Application.config.root}/spec/fixtures/shapefiles/geometry.txt") }
    end
  end
end

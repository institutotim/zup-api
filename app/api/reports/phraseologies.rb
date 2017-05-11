module Reports
  module Phraseologies
    class API < Grape::API
      helpers do
        def load_phraseology(phraseology_id = params[:id])
          Reports::Phraseology.find(phraseology_id)
        end
      end

      namespace 'phraseologies' do
        desc 'Create a new phraseology'
        params do
          requires :title, type: String,
            desc: 'The report phraseology title'
          requires :description,
            desc: 'The phrase to be used in comment'
          optional :reports_category_id, type: Integer,
            desc: 'The ID of the report category'
        end
        post do
          authenticate!

          phraseology_params = safe_params.permit(
            :title, :description, :reports_category_id
          )

          phraseology_params[:namespace_id] = app_namespace_id

          phraseology = Reports::Phraseology.create!(phraseology_params)

          {
            phraseology: Reports::Phraseology::Entity.represent(
              phraseology,
              only: return_fields
            )
          }
        end

        desc 'List all phraseologies'
        params do
          optional :grouped, type: Boolean, default: true,
            desc: 'Group phraseologies by category title'
          optional :reports_category_id, type: Integer,
            desc: 'Id of report category'
        end
        get do
          authenticate!

          phraseologies = Reports::Phraseology.includes(:category)

          if safe_params[:reports_category_id]
            phraseologies = phraseologies.search_by_category(safe_params[:reports_category_id])
          end

          phraseologies =
            if safe_params[:grouped]
              phraseologies.group_by(&:category_title)
            else
              Reports::Phraseology::Entity.represent(phraseologies)
            end

          {
            phraseologies: phraseologies
          }
        end

        desc 'Returns data for a phraseology'
        get ':id' do
          authenticate!

          phraseology = load_phraseology

          {
            phraseology: Reports::Phraseology::Entity.represent(phraseology)
          }
        end

        desc 'Update phraseology'
        params do
          optional :title, type: String,
            desc: 'The report phraseology title'
          optional :description,
            desc: 'The phrase to be used in comment'
          optional :reports_category_id, type: Integer,
            desc: 'The ID of the report category'
        end
        put ':id' do
          authenticate!

          phraseology_params = safe_params.permit(
            :title, :description, :reports_category_id
          )

          phraseology = load_phraseology
          phraseology.update!(phraseology_params)

          {
            phraseology: Reports::Phraseology::Entity.represent(
              phraseology,
              only: return_fields
            )
          }
        end

        desc 'Destroy phraseology'
        delete ':id' do
          authenticate!

          phraseology = load_phraseology

          if phraseology.destroy
            status 204
          else
            status 422
          end
        end
      end
    end
  end
end

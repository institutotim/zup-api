module Reports::Webhooks
  class API < Base::API
    namespace :webhooks do
      desc 'Receives a new report'
      params do
        requires :external_category_id, type: Integer
        requires :is_solicitation, type: Boolean
        requires :is_report, type: Boolean
        optional :latitude, type: Float
        optional :longitude, type: Float
        optional :description, type: String
        optional :address, type: String
        optional :reference, type: String
        optional :images, type: Array
        optional :status, type: Hash
        optional :user, type: Hash
        optional :comments, type: Array
        optional :namespace_id, type: Integer
      end
      post do
        params[:namespace_id] ||= Namespace.where(default: true).first.id
        service = Reports::CreateItemFromWebhook.new(params)
        report = service.create!

        {
          message: 'Relato criado com sucesso',
          uuid: report.uuid
        }
      end

      desc 'Updates a reports status'
      params do
        optional :status, type: Hash
        optional :comments, type: Array
      end
      put ':uuid' do
        uuid = params[:uuid]

        report = Reports::Item.find_by!(uuid: uuid)

        service = Reports::UpdateItemFromWebhook.new(report, params)
        service.update!

        {
          message: 'Relato atualizado com sucesso'
        }
      end

      desc 'Destroy a report item'
      delete ':uuid' do
        report = Reports::Item.find_by!(uuid: safe_params[:uuid])
        report.destroy!

        {
          message: 'Relato deletado com sucesso'
        }
      end
    end
  end
end

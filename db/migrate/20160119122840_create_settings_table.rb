class CreateSettingsTable < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name, null: false
      t.integer :kind, null: false
      t.string :value, array: true, default: []

      t.timestamps
    end

    ## Create settings
    Setting.create_with(
      value: [
        { id: nil, type: 'protocol', label: 'Protocolo' },
        { id: nil, type: 'priority', label: 'Prioridade' },
        { id: nil, type: 'address', label: 'Endereço' },
        { id: nil, type: 'user', label: 'Solicitante' },
        { id: nil, type: 'reporter', label: 'Criador' },
        { id: nil, type: 'category', label: 'Categoria' },
        { id: nil, type: 'assignment', label: 'Atribuído á' },
        { id: nil, type: 'created_at', label: 'Data de inclusão' }
      ]
    ).find_or_create_by(
      name: 'reports_listing_columns'
    )
  end
end

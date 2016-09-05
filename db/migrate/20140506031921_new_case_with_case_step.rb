class NewCaseWithCaseStep < ActiveRecord::Migration
  def change
    remove_column :cases, :data
    remove_column :cases, :step_id
    change_column :cases, :flow_version, :integer, default: 1
    add_column :cases, :status,       :string,  default: 'active'

    add_column :cases_log_entries, :new_flow_id, :integer

    drop_table :case_images
    drop_table :case_attachments

    create_table :case_steps do |t|
      t.references :case,                       index: true
      t.references :step,                       index: true
      t.integer :step_version,               default: 1
      t.integer :created_by_id,              index: true
      t.integer :updated_by_id,              index: true
      t.integer :trigger_ids,                array: true, default: []
      t.integer :responsible_user_ids,       array: true, default: []
      t.integer :responsible_user_group_ids, array: true, default: []

      t.timestamps
    end

    create_table :case_step_data_fields do |t|
      t.references :case_step, index: true, null: false
      t.references :field,     null: false
      t.string :value
    end

    create_table :case_step_data_images do |t|
      t.string :image
      t.string :file_name
      t.references :case_step_data_field, index: true
      t.timestamps
    end

    create_table :case_step_data_attachments do |t|
      t.string :attachment
      t.string :file_name
      t.references :case_step_data_field, index: true
      t.timestamps
    end
  end
end

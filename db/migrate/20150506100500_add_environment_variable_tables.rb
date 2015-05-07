class AddEnvironmentVariableTables < ActiveRecord::Migration
  def change
    create_table :environment_variable_groups do |t|
      t.string :name, null: false
      t.boolean :stage_specific, default: false, null: false
      t.timestamps null: false
    end

    create_table :environment_variables do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.string :scope, null: false, default: 'All'
      t.belongs_to :environment_variable_group, index: true, null: false
      t.timestamps null: false
    end

    create_join_table :stages, :environment_variable_groups
  end
end

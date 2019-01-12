Sequel.migration do
  up do
    create_table :showers do
      column :family_id, :uuid, null: false
      column :name, :text, null: false
      column :shower_at, "timestamp with time zone", null: false
      foreign_key [:family_id, :name], :children
    end
  end
end

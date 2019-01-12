Sequel.migration do
  up do
    create_table :children do
      column :family_id, :uuid, null: false
      column :name, :text, null: false
      primary_key [:family_id, :name]
      foreign_key [:family_id], :families
    end
  end
end

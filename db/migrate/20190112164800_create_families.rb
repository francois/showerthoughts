Sequel.migration do
  up do
    create_table :families do
      column :family_id, :uuid, primary_key: true
    end
  end
end

class AddOrganizationNameToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :organization_name, :string
  end

  def self.down
    remove_column :addresses, :organization_name
  end
end

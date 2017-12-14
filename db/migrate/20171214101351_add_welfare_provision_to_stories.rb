class AddWelfareProvisionToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :welfare_provision, :boolean, default: false
    add_index :stories, :welfare_provision

    # Update existing Stories
    Story.find_each(&:save)
  end
end

ActiveRecord::Schema.define(:version => 1) do
  create_table 'users', :force => true do |t|
    t.column :name, :string
  end

  create_table 'posts', :force => true do |t|
    t.column :user_id, :integer
    t.column :published, :boolean, :default => true
    t.column :name, :string
  end
  
  create_table 'alternates', :force => true do |t|
    t.column :alternate_id, :integer
    t.column :name, :string
  end

  create_table 'fuzzles', :force => true do |t|
    t.column :fuzzle_id, :integer
    t.column :name, :string
  end
end

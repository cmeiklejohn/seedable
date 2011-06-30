# encoding: UTF-8

ActiveRecord::Schema.define do 
  self.verbose = false

  create_table :garages, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :filtered_garages, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :cars, :force => true do |t|
    t.string :make
    t.string :model
    t.integer :garage_id
    t.timestamps
  end

  create_table :bikes, :force => true do |t|
    t.integer :garage_id
    t.timestamps
  end

  create_table :drivers, :force => true do |t|
    t.string :name
    t.integer :car_id
    t.timestamps
  end

end

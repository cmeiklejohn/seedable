# encoding: UTF-8

class Garage < ActiveRecord::Base
  include Seedable

  has_many :cars
  has_many :bikes

  seedable :include_associations => []
end

class FilteredGarage < ActiveRecord::Base
  include Seedable

  has_many :cars
  has_many :bikes

  seedable :include_associations => [], :filter_attributes => [:name]
end

class Car < ActiveRecord::Base
  include Seedable

  belongs_to :garage

  has_many :drivers

  seedable :include_associations => []
end

class Bike < ActiveRecord::Base
  include Seedable

  belongs_to :garage
end

class Driver < ActiveRecord::Base
  include Seedable

  belongs_to :car

  seedable :include_associations => []
end

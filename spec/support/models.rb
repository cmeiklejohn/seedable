# encoding: UTF-8

class Garage < ActiveRecord::Base
  has_many :cars
  has_many :bikes

  acts_as_seedable :include_associations => []
end

class FilteredGarage < ActiveRecord::Base
  has_many :cars
  has_many :bikes

  acts_as_seedable :include_associations => [], :filter_attributes => [:name]
end

class Car < ActiveRecord::Base
  belongs_to :garage

  has_many :drivers

  acts_as_seedable :include_associations => []
end

class Bike < ActiveRecord::Base
  belongs_to :garage
end

class Driver < ActiveRecord::Base
  belongs_to :car

  acts_as_seedable :include_associations => []
end

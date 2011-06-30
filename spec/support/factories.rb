# encoding: UTF-8

require 'spec_helper'

Factory.define :garage do |garage|
  garage.name "Chris"
end

Factory.define :filtered_garage do |garage|
  garage.name "Chris"
end

Factory.define :car do |car|
  car.make "Subaru"
  car.model "Impreza"
end

Factory.define :driver do |driver|
  driver.name "Chris"
end

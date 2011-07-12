# encoding: UTF-8

require 'spec_helper'

describe Garage do 

  before(:each) do 
    Timecop.freeze(2010, 01, 01)
    @garage = Factory.create(:garage)
  end

  after(:each) do 
    Timecop.return
  end

  describe "with no associations" do
    it "should return a proper hash of attributes and associations" do
      @garage.as_seedable.should == {"garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end

    it "should export and import correctly" do 
      @hash = @garage.as_seedable
      @json = @garage.to_seedable

      @hash.should == {"garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}

      @garage.delete
      Garage.all.count.should == 0

      @garage = Garage.from_seedable(@json) 
      @garage.as_seedable.should == @hash
      @garage.to_seedable.should == @json
    end
  end

  describe "with a bike" do 
    before(:each) do 
      @bike = Factory.create(:bike)
      @garage.bikes << @bike

      Garage.include_associations([:bikes])
    end

    it "should not traverse to bike when exporting since it is not seedable" do 
      @garage.as_seedable.should == {"garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end
  end

  describe "with one car" do
    before(:each) do 
      @car = Factory.create(:car)
      @garage.cars << @car
      Garage.include_associations([:cars])
    end

    it "should return a proper hash of attributes and associations" do
      Car.filter_attributes([])
      Garage.filter_attributes([])
      
      @garage.as_seedable.should == {"garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", "garage_id"=>1, "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end

    it "should omit filtered attributes and return properly formatted json when to_seedable is called" do 
      Garage.filter_attributes([:id])
      Car.filter_attributes([:id, :garage_id])

      @garage.as_seedable.should == {"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end

    it "should export and import the records correctly without ids" do
      Garage.filter_attributes([:id])
      Car.filter_attributes([:id, :garage_id])

      @hash = @garage.as_seedable
      @json = @garage.to_seedable

      @car.delete
      @garage.delete

      Car.all.count.should == 0
      Garage.all.count.should == 0

      @hash.should == {"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}

      @garage = Garage.from_seedable(@json) 
      @garage.as_seedable.should == @hash
      @garage.to_seedable.should == @json
    end

    # TODO: Marked pending since this behavior fails in rails 3.0, but
    # works in rails 3.2.  
    #
    # For this to work, mass assignment protection
    # changes from rails-3.2 are necessary since they'll alow you to
    # bypass protection on all associated objects and set primary key
    # values on the associated objects.
    #
    pending "should export and import the records correctly with ids"
  end

  describe "with one car and two drivers" do
    before(:each) do 
      @car = Factory.create(:car)
      @garage.cars << @car
      2.times do 
        @car.drivers << Factory.create(:driver)
      end

      Car.filter_attributes([:id, :garage_id])
      Garage.filter_attributes([:id])
      Driver.filter_attributes([:id, :car_id])

      Car.include_associations([:drivers])
      Garage.include_associations([:cars])
    end

    it "serialize and deserialize into objects correctly" do
      @hash = @garage.as_seedable
      @json = @garage.to_seedable

      @hash.should == {"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", :drivers=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}, {"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}], "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}

      @garage = Garage.from_seedable(@json)
      @garage.as_seedable.should == @hash
      @garage.to_seedable.should == @json
    end

    describe "with a dependency back to garage" do 
      it "should be able to export correctly by not traversing direct ancestors" do
        Car.filter_attributes([:id, :garage_id])
        Garage.filter_attributes([:id])
        Driver.filter_attributes([:id, :car_id])

        Car.include_associations([:drivers, :garage])
        Garage.include_associations([:cars])

        @hash = @garage.as_seedable
        @json = @garage.to_seedable

        @hash.should == {"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", :drivers=>[{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}, {"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}], "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}

        @garage = Garage.from_seedable(@json)
        @garage.as_seedable.should == @hash
        @garage.to_seedable.should == @json
      end
    end
  end

  describe "with two cars with the same driver" do 
    before(:each) do 
      @driver = Factory.create(:driver)
      2.times do 
        @car = Factory.create(:car)
        @car.drivers << @driver
        @garage.cars << @car
      end

      Car.filter_attributes([])
      Garage.filter_attributes([])
      Driver.filter_attributes([])

      Car.include_associations([:drivers])
      Garage.include_associations([:cars])
    end

    it "should import and export only one driver correctly" do 
      @garage.as_seedable.should == {"garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", "garage_id"=>1, :drivers=>[{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "car_id"=>2, "name"=>"Chris", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}], "make"=>"Subaru"}, {"id"=>2, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "model"=>"Impreza", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010", "garage_id"=>1, :drivers=>[{}], "make"=>"Subaru"}], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end
  end
    
  describe "in an array of garages" do
    before(:each) do 
      @garages = []
      2.times do 
        @garages << @garage
      end

      Car.filter_attributes([:id, :garage_id])
      Garage.filter_attributes([:id])
      Driver.filter_attributes([:id, :car_id])

      @hash = @garages.as_seedable
      @json = @garages.to_seedable
    end

    it "should export correctly" do 
      @hash.should == [{"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}, {"garage"=>{"updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "name"=>"Chris", :cars=>[], "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}]
    end

    it "should reload correctly" do 
      @garages = Seedable.from_seedable(@json)
      @garages.as_seedable.should == @hash
      @garages.to_seedable.should == @json
    end
  end

end

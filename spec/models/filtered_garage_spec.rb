# encoding: UTF-8

require 'spec_helper'

describe FilteredGarage do 

  before(:each) do 
    Timecop.freeze(2010, 01, 01)
    @garage = Factory.create(:filtered_garage)
  end

  after(:each) do 
    Timecop.return
  end

  describe "with filtered attributes" do 
    it "should return properly formatted json when to_seedable is called" do 
      @garage.as_seedable.should == {"filtered_garage"=>{"id"=>1, "updated_at"=>"Fri Jan 01 00:00:00 -0500 2010", "created_at"=>"Fri Jan 01 00:00:00 -0500 2010"}}
    end
  end

end

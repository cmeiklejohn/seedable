# encoding: UTF-8

module Seedable # :nodoc:
  module ActsAsSeedable # :nodoc:
    extend ActiveSupport::Concern

    included do 
      include Seedable::Base
    end

    # Extensions to all ActiveRecord classes to enable this class for
    # import and export of data.
    #
    # Use +acts_as_seedable+ here to enable your classes to use this
    # functionality.
    #
    # Use +from_seedable+ and +to_seedable+ here to perform the
    # serialization and deserialization.
    #
    module ClassMethods

      # Enable seedable export and import for the including class.
      #
      # ==== Options
      #
      # * +filter_attributes+ - Attributes to filter from the export.
      # * +include_associations+ - Associations that should be traversed during export.
      #
      # ==== Examples
      #
      #   class Garage < ActiveRecord::Base 
      #     acts_as_seedable :include_associations => [:cars]
      #   end
      #
      def acts_as_seedable(options = {})
        cattr_accessor :filterable_attributes
        cattr_accessor :includable_associations

        if options[:filter_attributes]
          self.send(:filter_attributes, options.delete(:filter_attributes))
        end

        if options[:include_associations]
          self.send(:include_associations, options.delete(:include_associations))
        else
          self.send(:include_associations, Helpers.associations_for(self))
        end
      end

      # Sets which attributes should be fitlered from the
      # serialization of this object.
      #
      # ==== Parameters
      #
      # * +attributes+ - Array of symbols representing attributes.
      #
      # ==== Examples
      #
      #   Garage.filter_attributes([:id, :name])
      #
      def filter_attributes(attributes)
        self.send(:filterable_attributes=, attributes)
      end

      # Sets which associations should be traversed when performing
      # serialization.
      #
      # ==== Parameters
      #
      # * +associations+ - Array of symbols representing associations.
      #
      # ==== Examples
      #
      #   Garage.include_associations([:cars])
      #
      #   Car.include_associations([:garage, :drivers])
      #
      def include_associations(associations)
        self.send(:includable_associations=, associations)

        associations.each do |association|
          self.accepts_nested_attributes_for association
        end
      end

      # Create object from attributes without a root node, since it's
      # assumed to be the type this method is being called on.
      #
      # ==== Parameters
      #
      # * +attributes+ - Hash of attributes, without a root node.
      #
      # ==== Examples
      #
      #   Garage.from_seedable_attributes({ :id => '1', :name => 'Name' })
      #
      def from_seedable_attributes(attributes) # :nodoc:
        object = self.new

        # Handling for rails-3.2.x vs. rails-3.0.x changes.
        #
        if object.respond_to?(:assign_attributes)
          object.assign_attributes(
            Helpers.convert_to_nested_attributes(self, attributes), 
            :without_protection => true
          )
        else
          object.send(
            :attributes=,
            Helpers.convert_to_nested_attributes(self, attributes), 
            false
          )
        end

        object.save!(:validate => false)
        object
      end

    end

    # Extensions to all ActiveRecord classes to enable this class for
    # import and export of data.
    #
    # Use +acts_as_seedable+ here to enable your classes to use this
    # functionality.
    #
    # Use +from_seedable+ and +to_seedable+ here to perform the
    # serialization and deserialization.
    #
    module InstanceMethods
      
      # Returns hash of objects attributes and all included associations
      # attributes.
      # 
      # ==== Examples 
      #
      #   json = @garage.as_seedable.to_json
      #
      def as_seedable
        includable = Helpers.traverse_includable_associations_from_instance(self)
        exceptions = Helpers.filterable_attributes(self)

        self.as_json(:include => includable, :except => exceptions)
      end

      # Performs render of as_seedable content into properly formatted
      # JSON.
      #
      # ==== Examples 
      #
      #   json = @garage.to_seedable
      #
      def to_seedable
        as_seedable.to_json
      end

    end
  end
end

ActiveRecord::Base.send :include, Seedable::ActsAsSeedable

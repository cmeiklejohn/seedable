# encoding: UTF-8

module Seedable # :nodoc:
  module Base # :nodoc: 
    extend ActiveSupport::Concern

    # Seedable methods for loading serialized objects of unknown or
    # disperse types into objects.
    #
    # Use +from_seedable+ here to load arrays of one or multiple types,
    # or when you do not know what type of object the JSON represents to
    # have it return the appropriate object.
    #
    module ClassMethods

      # Takes JSON and builds objects from it.  Returns either the
      # object, or array of objects depending on input.
      #
      # ==== Parameters
      #
      # * +json+ - A block of JSON.
      # 
      # ==== Examples
      #
      #   array_of_objects = Seedable.from_seedable(json_containing_array_of_hashes)
      #   object = Seedable.from_seedable(json_for_one_object)
      #
      def from_seedable(json)
        objects = Helpers.parse_seedable(json)

        if Array === objects
          objects.map do |object| 
            objects_from_serialized_hash(object)
          end
        else
          objects_from_serialized_hash(objects)
        end
      end

      # Convert a hash's root node to a class, and return the remainder
      # of the hash as attributes.
      #
      # ==== Parameters
      #
      # * +hash+ - Hash with one root note reflecting a class.
      #
      def objects_from_serialized_hash(hash) # :nodoc:
        klass, attributes = Helpers.to_class_and_attributes(hash)
        klass.from_seedable_attributes(attributes)
      end
      private :objects_from_serialized_hash

    end
  end
end

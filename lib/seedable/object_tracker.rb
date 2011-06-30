# encoding: UTF-8

module Seedable # :nodoc:
  class ObjectTracker # :nodoc:

    attr_accessor :graph

    # Create a new instance of the object tracker.
    #
    def initialize
      @graph = {}
    end

    # Determine if the object tracker has already picked this object up.
    #
    def contains?(object)
      key, id = to_key_and_id(object)

      @graph[key].is_a?(Enumerable) ? @graph[key].include?(id) : @graph[key]
    end

    # Add this object to the object tracker.
    #
    def add(object)
      key, id = to_key_and_id(object)

      @graph[key] ? @graph[key] << id : @graph[key] = [id]
    end

    # Display the object tracker in yaml for easy viewing.
    #
    def to_s
      @graph.to_yaml
    end

    # Convert a particular object to a hash key and id, based from the
    # object's class and primary key.
    # 
    def to_key_and_id(object)
      [object.class.to_s.underscore.to_sym, object.id]
    end
    private :to_key_and_id

  end
end

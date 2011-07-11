# encoding: UTF-8

module Seedable # :nodoc:
  module CoreExt # :nodoc:
    module Array # :nodoc:
      extend ActiveSupport::Concern

      module InstanceMethods # :nodoc:

        # Serialize an array of heterogeneous objects.
        #
        def as_seedable
          map { |o| o.as_seedable }
        end

        # Serialize an array of heterogeneous objects and output as
        # JSON.
        #
        def to_seedable
          as_seedable.to_json
        end

      end
    end

    module Serialization # :nodoc:
      extend ActiveSupport::Concern

      included do
        alias_method_chain :serializable_hash, :object_tracker
      end

      # Use thread-local storage to carry the object tracker through the
      # association traversal.
      #
      module InstanceMethods # :nodoc:

        # Extend serializable_hash functionality by calling out to the
        # object tracker.
        #
        def serializable_hash_with_object_tracker(options = {})
          unless object_tracker = Thread.current[:object_tracker]
            object_tracker                  = ObjectTracker.new
            clean_up                        = true
            Thread.current[:object_tracker] = object_tracker
          end

          if object_tracker.contains?(self)
            return_value = {}
          else
            object_tracker.add(self)
            return_value = serializable_hash_without_object_tracker(options)
          end
         
          Thread.current[:object_tracker] = nil if clean_up

          return_value
        end
      end
    end
  end
end

Array.send :include, Seedable::CoreExt::Array

ActiveRecord::Base.send :include, Seedable::CoreExt::Serialization

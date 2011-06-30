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
        alias_method_chain :as_json, :object_tracker
        alias_method_chain :serializable_hash, :object_tracker
      end

      # :nodoc: 
      #
      # @@object_tracker 
      #
      # Can't use dependency injection here, as serializable_add_include
      # doesn't carry down the options throughout associations for
      # security.
      # 
      # TODO: Refactor when we've found a better way.
      #

      module InstanceMethods # :nodoc:

        # Extend as_json by creating a new instance of the object
        # tracker.
        #
        def as_json_with_object_tracker(options = {})
          @@object_tracker = ObjectTracker.new
          as_json_without_object_tracker(options)
        end

        # Extend serializable_hash functionality by calling out to the
        # object tracker.
        #
        def serializable_hash_with_object_tracker(options = {}) 
          if self.class.prevent_duplicate_records? && @@object_tracker.contains?(self)
            {}
          else
            @@object_tracker.add(self)
            serializable_hash_without_object_tracker(options)
          end
        end

      end
    end
  end
end

Array.send :include, Seedable::CoreExt::Array

ActiveRecord::Base.send :include, Seedable::CoreExt::Serialization

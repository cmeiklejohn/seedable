# encoding: UTF-8

module Seedable # :nodoc:
  module Helpers # :nodoc:

    # Convert a string or symbol to a class in the object space.
    #
    def self.to_class(string)
      string.to_s.classify.constantize
    end

    # Parse a seedable object returning a hash.
    #
    def self.parse_seedable(json)
      JSON.parse(json)
    end

    # Convert hash root node to class, and return attributes.
    #
    def self.to_class_and_attributes(hash)
      node       = hash.keys.first
      attributes = hash.delete(node)
      klass      = Helpers.to_class(node)

      [klass, attributes]
    end

    # Traverse all associations starting from an instance of a
    # particular class.
    #
    def self.traverse_includable_associations_from_instance(klass)
      traverse_includable_associations(klass.class, klass.class)
    end

    # Traverse all associations starting from a particular class.
    #
    def self.traverse_includable_associations(klass, ancestor_klass)
      if klass.respond_to?(:includable_associations) 
        klass.includable_associations.inject({}) do |associations, association|
          descendent_klass = Helpers.to_class(association)
          unless descendent_klass == ancestor_klass || !descendent_klass.seedable?
            associations[association] = { 
              :include => traverse_includable_associations(Helpers.to_class(association), klass),
              :except  => filterable_attributes(Helpers.to_class(association))
            }
          end
          associations
        end
      else 
        {}
      end
    end

    # Filterable attributes for a particular class.
    #
    def self.filterable_attributes(klass)
      if klass.respond_to?(:filterable_attributes) 
        klass.filterable_attributes
      else
        []
      end
    end

    # Valid traversable association types.
    #
    def self.valid_association_types
      [:has_many, :has_one, :belongs_to]
    end

    # Determine if a particular association macro is valid.
    #
    def self.valid_associations_include?(macro)
      valid_association_types.include?(macro)
    end

    # Return all associations for a particular class.
    #
    def self.associations_for(klass)
      klass.reflections.map do |reflection| 
        valid_associations_include?(reflection.last.macro) ? reflection.first : nil
      end.compact
    end

    # Returns true of a particular association is valid for a particular
    # class.
    #
    def self.is_key_association_for_class?(klass, key)
      klass.reflections.any? do |reflection| 
        valid_associations_include?(reflection.last.macro) && reflection.first == key.to_sym
      end
    end

    # Return all attributes in a hash, without the root node, if
    # present.
    #
    def self.attributes_without_root(attributes, root) 
      attributes.delete(root)
    end

    # Return the name of the nested association accessor for a
    # particular association.
    #
    def self.nested_attributes_key_for(key)
      "#{key}_attributes"
    end

    # Return a particular reflection on an object or class.
    #
    def self.return_reflection(klass, association) 
      if klass.respond_to?(:reflect_on_association) 
        klass.reflect_on_association(association)
      else 
        klass.class.reflect_on_association(association)
      end
    end

    # Return the proper active_record reflection type for a nested
    # association.
    #
    def self.reflection_type(klass, association)
      return_reflection(klass, association).collection? ? :collection : :one_to_one
    end

    # Convert a hash of nested model attributes to a valid hash to be
    # passed to assign_attributes by substituting association name for
    # the appropriate association accessors.
    #
    def self.convert_to_nested_attributes(klass, node_attributes) 
      node_attributes.keys.inject(node_attributes) do |attributes, key|
        if is_key_association_for_class?(klass, key)
          sub_attributes = attributes_without_root(attributes, key)

          attributes[nested_attributes_key_for(key)] = sub_attributes.is_a?(Enumerable) ?
            sub_attributes.map do |sub_attribute| 
              convert_to_nested_attributes(to_class(key), sub_attribute)
            end :
            convert_to_nested_attributes(to_class(key), sub_attributes)
        end
        attributes
      end
    end
  end
end


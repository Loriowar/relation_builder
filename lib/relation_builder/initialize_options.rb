module RelationBuilder
  module InitializeOptions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :initialize, :build_relation
    end

    private

    # Chain initialize method for support additional options
    def initialize_with_build_relation(new_attributes = nil, options = {})
      # relation build strategy:
      #   nested - using nested_attributes
      #   build  - using standard build method
      nested_build_strategy = options[:build_strategy] || :nested
      processed_attributes = new_attributes || {}
      auto_build_relation_list = options.delete(:auto_build_relations)

      if nested_build_strategy == :nested && auto_build_relation_list.present?
        nested_relations_attributes = create_nested_options(auto_build_relation_list)
        processed_attributes = nested_deep_merge(processed_attributes, nested_relations_attributes)
      end

      # store return value to save default behaviour of initialize
      ret_val = initialize_without_build_relation(processed_attributes, options)

      if nested_build_strategy == :build && auto_build_relation_list.present?
        if auto_build_relation_list.is_a?(Array)
          auto_build_relation_list.each do |rel|
            build_relation_with_options(rel)
          end
        elsif auto_build_relation_list.is_a?(Hash)
          auto_build_relation_list.each do |rel, nested_options|
            build_relation_with_options(rel, auto_build_relations: nested_options)
          end
        elsif auto_build_relation_list.is_a?(Symbol) || auto_build_relation_list.is_a?(String)
          build_relation_with_options(auto_build_relation_list)
        end
      end

      ret_val
    end

    # Get onformation about relation
    def reflection_for(method)
      if self.class.respond_to?(:reflect_on_association)
        self.class.reflect_on_association(method)
      elsif self.class.respond_to?(:associations) # MongoMapper uses the 'associations(method)' instead
        self.class.associations[method]
      end
    end

    # Build relation based on type of it
    def build_relation_with_options(rel, options = {})
      reflection = reflection_for(rel)
      if reflection.present?
        relation = instance_eval(rel.to_s)
        if %i(has_and_belongs_to_many
                  has_many
                  references_and_referenced_in_many
                  references_many).include?(reflection.macro)
          if relation.blank?
            relation << reflection.klass.new({}, options)
          end
        else
          if relation.blank?
            self.send("#{rel}=", reflection.klass.new({}, options))
          end
        end
      end
    end

    # Create nested Hash with attributes for using in nested_attributes
    # Example:
    #   input:  {versions:
    #             {doc_kit_source: [:source, :author]},
    #              product: :project}
    #   Output: {versions_attributes:
    #             {doc_kit_source_attributes:
    #               {source_attributes: {},
    #                author_attributes: {}
    #               }
    #             },
    #            product_attributes:
    #             {project_attributes: {}}
    #           }
    #
    def create_nested_options(build_options)
      new_attributes = {}
      if build_options.is_a?(Hash)
        build_options.each do |required_rel, nested_rels|
          new_attributes.merge!(rel_name_to_nested_attrs(required_rel))
          nested_key = to_nested_attributes_key(required_rel)
          if nested_rels.is_a?(Symbol)
            new_attributes[nested_key].merge!(rel_name_to_nested_attrs(nested_rels))
          elsif nested_rels.is_a?(Array)
            nested_rels.each do |nested_rel|
              new_attributes[nested_key].merge!(rel_name_to_nested_attrs(nested_rel))
            end
          elsif nested_rels.is_a?(Hash)
            new_attributes[nested_key].merge!(create_nested_options(nested_rels))
          end
        end
      end

      new_attributes
    end

    # Generate key-name for nested_attributes from relation name
    def to_nested_attributes_key(relation_name)
      "#{relation_name}_attributes".to_sym
    end

    # Hash for passing into nested_attributes for build single relation
    def rel_name_to_nested_attrs(relation_name)
      {to_nested_attributes_key(relation_name) => {}}
    end

    # Merge of initialize params and additional options for build relations through nested_attributes
    def nested_deep_merge(master, slave)
      # Add alternative deep_merge method for instanse of Hash
      extend_deep_merge = ->(obj){obj.send(:extend, RelationBuilder::ExtDeepMerge) unless master.is_a? RelationBuilder::ExtDeepMerge; obj)

      extend_deep_merge.call(master)
      extend_deep_merge.call(slave)

      # extend_deep_merge call block for any coincide keys
      master.ext_deep_merge(slave) do |_, master_val, slave_val|
        # special processiog of attributes for has_many relation (see nested_attributes documentation for details)
        if master_val.is_a?(Hash) && master_val.all?{|k, _| key_is_numeric?(k)}
          extend_deep_merge.call(master_val)
          master_val.inject(extend_deep_merge.call({}) do |h, (inner_key, value)|
            h[inner_key] = nested_deep_merge(value, slave_val)
            h
          end
        elsif master_val.is_a?(Hash) && slave_val.is_a?(Hash)
          extend_deep_merge.call(master_val)
          extend_deep_merge.call(slave_val)

          nested_deep_merge(master_val, slave_val)
        else
          master_val
        end
      end
    end

    def key_is_numeric?(key)
      !(key =~ /^\d+$/).nil?
    end

    class_methods do
      # stub
    end

  end
end
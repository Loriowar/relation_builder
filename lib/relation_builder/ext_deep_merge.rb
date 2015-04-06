module RelationBuilder
  module ExtDeepMerge
    # Alternative for native method of Hash
    # It call block for any coincide keys even if values is Hash too
    def ext_deep_merge(other_hash, &block)
      dup.ext_deep_merge!(other_hash, &block)
    end

    # Same as +ext_deep_merge+, but modifies +self+.
    def ext_deep_merge!(other_hash, &block)
      other_hash.each_pair do |current_key, other_value|
        this_value = self[current_key]
        self[current_key] =
            if block_given? && key?(current_key)
              block.call(current_key, this_value, other_value)
            else
              if this_value.is_a?(Hash) && other_value.is_a?(Hash)
                this_value.ext_deep_merge(other_value, &block)
              else
                other_value
              end
            end
      end
      self
    end
  end
end

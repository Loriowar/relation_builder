require 'relation_builder/version'

module RelationBuilder
  extend ActiveSupport::Autoload

  autoload :InitializeOptions
  autoload :ExtDeepMerge

  eager_autoload do
    autoload :InitializeOptions
    autoload :ExtDeepMerge
  end
end

# encoding: UTF-8

require "seedable/version"
require "seedable/importer"
require "seedable/exporter"
require "seedable/helpers"
require "seedable/core_ext"
require "seedable/object_tracker"

module Seedable # :nodoc:
  include Seedable::Importer

  extend ActiveSupport::Concern 

  included do
    include Seedable::Importer
    include Seedable::Exporter
  end
end

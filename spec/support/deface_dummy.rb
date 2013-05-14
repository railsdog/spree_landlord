# Dummy Deface instance for testing actions / applicator
class DefaceDummy
  extend Deface::Applicator::ClassMethods
  extend Deface::Search::ClassMethods

  attr_reader :parsed_document

  def self.all
    Rails.application.config.deface.overrides.all
  end
end

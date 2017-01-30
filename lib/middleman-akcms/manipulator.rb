
module Middleman::Akcms
  ## base class of manipulators
  class Manipulator
    attr_reader :controller
    def initialize(controller)
      @controller = controller
    end
    def manipulate_resource_list(resources)
      resources
    end
  end
end

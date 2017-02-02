
module Middleman::Akcms
  ## base class of manipulators
  class Manipulator
    attr_reader :controller, :sitemap
    def initialize(controller)
      @controller = controller
      @sitemap = controller.extension.app.sitemap
    end
    def manipulate_resource_list(resources)
      resources
    end
  end
end

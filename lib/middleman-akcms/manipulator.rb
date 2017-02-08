
## base module of manipulators
module Middleman::Akcms
  module Manipulator
    include ::Contracts
    attr_reader :controller, :app, :template

    def initialize(controller)
      @controller = controller
    end
    # set_attributes(controller: controller, template
    def set_attributes(controller, template=nil)
      @controller = controller
      @app = controller.app
#      @sitemap = @app.sitemap
      @template = template
      @controller.app.ignore @template if @template
    end
    Contract String, Hash => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(link, metadata = {})
      Middleman::Sitemap::ProxyResource.new(@app.sitemap, link, @template).tap do |p|
        p.add_metadata(metadata)
      end
    end

    ## abstract
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      resources
    end
  end
end  ## module


## base module of manipulators
module Middleman::Akcms
  module Manipulator
    include ::Contracts
    attr_reader :controller, :app, :template

    Contract Controller, KeywordArgs[:template => Optional[String]] => Any
    def initialize_manipulator(controller, template: nil)
      @controller = controller
      @app = @controller.app

      if (@template = template)
        @controller.app.ignore @template
      end
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

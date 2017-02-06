
## base class of manipulators
module Middleman::Akcms
  class Manipulator
    include Contracts
    
    attr_reader :controller, :sitemap

    def initialize(controller)
      @controller = controller
      @sitemap = controller.extension.app.sitemap

#      @controller.app.ignore @template if @template
    end
    
    Contract String, Hash => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(link, locals = {})
      Middleman::Sitemap::ProxyResource.new(@sitemap, link, @template).tap do |p|
        p.add_metadata(locals: locals)
      end
    end

    ## abstract
    Contract Array => Array
    def manipulate_resource_list(resources)
      resources
    end
  end
end

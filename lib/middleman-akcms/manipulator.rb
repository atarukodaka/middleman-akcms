
## base class of manipulators
module Middleman::Akcms
  class Manipulator
    include Contracts
    
    attr_reader :controller, :sitemap

    def initialize(controller)
      @controller = controller
      @sitemap = controller.extension.app.sitemap
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

    ## abstract    
    Contract String => String
    def link(name)
      name
    end
  end
end

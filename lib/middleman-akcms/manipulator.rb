
module Middleman::Akcms
  ## base class of manipulators
  class Manipulator
    include Contracts
    
    attr_reader :controller, :sitemap
    def initialize(controller)
      @controller = controller
      @sitemap = controller.extension.app.sitemap
    end

    
#    Contract Symbol, Any, Hash => Middleman::Sitemap::ProxyResource
    def create_proxy_resource(link, locals = {})
#    def create_proxy_resource(key_sym, key, locals = {})
      Middleman::Sitemap::ProxyResource.new(@sitemap, link, @template).tap do |p|
        p.add_metadata(locals: locals)
#        p.add_metadata(locals: locals.merge({key_sym => key}))
      end
    end

    ## abstract
    Contract Array => Array
    def manipulate_resource_list(resources)
      resources
    end

    ## abstract    
    private
    Contract String => String
    def link(name)
      name
    end
  end
end


## base class of manipulators
module Middleman::Akcms
  module Manipulator
    include ::Contracts
    attr_reader :controller, :sitemap, :template

    def set_attributes(controller, template=nil)
      @controller = controller
      @sitemap = controller.extension.app.sitemap
      @template = template
      @controller.app.ignore @template if @template
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
=begin
  class MManipulator
    include ::Contracts
    
    attr_reader :controller, :sitemap

    def initialize(controller, template = nil)
      @controller = controller
      @sitemap = controller.extension.app.sitemap
      @template = template
      @controller.app.ignore @template if @template
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
=end
end  ## module

require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class BreadcrumbManipulator
    Middleman::Akcms::Controller.register(:breadcrumb, self)
    
    include Manipulator
    include Contracts

    def initialize(controller)
      controller.extension.class.defined_helpers << Middleman::Akcms::BreadcrumbHelper
      set_attributes(controller)
    end
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      resources.each {|res|
        ancestors = []
        #if resource.source_file != controller.app.sitemap.find_resource_by_path("/").source_file
        p = res.parent
        while p
          ancestors.unshift(p)
          p = p.parent
        end
        res.add_metadata({ancestors: ancestors})
      }
      resources
    end
  end ## class
end

################
module Middleman::Akcms
  module BreadcrumbHelper
    include Contracts
    
    Contract Resource => String
    def breadcrumb(resource)
      ## return content tags
      items = resource.metadata[:ancestors].map {|res|
        content_tag(:li, link_to(h(res.metadata[:directory][:name] || res.data.title), res))
      }
      items << content_tag(:li, link_to(h(top_page.data.title), top_page)) if items.empty?
      items << (content_tag(:li, h(yield_content(:title) || resource.data.title))) unless resource.source_file == top_page.source_file
      
      return content_tag(:nav, :class=>"crumbs") do
        content_tag(:ol, items, :class=>"breadcrumb")
      end
    end
  end  ## module
end


       

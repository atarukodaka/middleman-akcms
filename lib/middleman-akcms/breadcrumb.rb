require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class BreadcrumbManipulator < Manipulator
    class << self
      def enable?(controller)
        true
      end
    end
    Middleman::Akcms::Controller.register(:breadcrumb, self)
    
    include ::Contracts
    C = Middleman::Akcms::Contracts

    def initialize(controller)
      controller.extension.class.defined_helpers << Middleman::Akcms::BreadcrumbHelper
      super(controller)
    end
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      resources.each {|res|
        ancestors = []
        if true  # resource.source_file != controller.app.sitemap.find_resource_by_path("/").source_file
          p = res.parent
          while p
            ancestors.unshift(p)
            p = p.parent
          end
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
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    Contract C::Resource => String
    def breadcrumb(resource)
      ## return content tags
      items = resource.metadata[:ancestors].map {|res|
        content_tag(:li) do
          link_to(res.metadata[:directory][:name] || res.data.title, res)
        end
      }
      items << (content_tag(:li, yield_content(:title) || resource.data.title))
      
      return content_tag(:nav, :class=>"crumbs") do
        content_tag(:ol, items, :class=>"breadcrumb")
      end
    end
  end  ## module
end


       

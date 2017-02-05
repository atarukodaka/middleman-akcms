module Middleman::Akcms
  module BreadcrumbHelper
    def breadcrumb(page)
      list = []
      ## first, put current title unless this page is top
      #unless page.locals[:paginator] &&  page.locals[:paginator][:paginated_resources].first == top_page
      unless pagination? && page.locals[:paginator][:paginated_resources].first == top_page
        
        list.unshift(yield_content(:title) || page.data.title)
      end

      ## add categories
      p = page.parent
      while p && p != top_page()
        list.unshift(content_tag(:a, p.metadata[:directory][:name] || p.data.title, href: url_for(p)))
        p = p.parent
      end
      list.unshift(content_tag(:a, "Home", href: url_for(top_page()))) #  unless page == top_page()

      ## add home as last
      content_tag(:nav, :class=>"crumbs") do
        content_tag(:ol, list.map {|elem| content_tag(:li, elem)}, :class=>"breadcrumb")
      end
    end
  end  ## module
end

module Middleman::Akcms
  module Helpers
    include BreadcrumbHelper
#    include PaginationHelper
    include Contracts

    Contract Middleman::Akcms::Controller
    def akcms
      app.extensions[:akcms].controller
    end
    
    def page_for(path)
      sitemap.find_resource_by_path(path)
    end
    alias_method :resource_for, :page_for

    def top_page
      sitemap.find_resource_by_path("/" + config[:index_file])
    end
  end ## Helpers
end

module Middleman::Akcms
  module BreadcrumbHelper
    include Contracts

    Contract Middleman::Sitemap::Resource => String
    def breadcrumb(page)
      list = []
      ## first add home as last
      list << content_tag(:a, "Home", href: url_for(top_page)) #  unless page == top_page()

      ## add categories
      p = page.parent
      while p && p != top_page()
        list << content_tag(:a, p.metadata[:directory][:name] || p.data.title, href: url_for(p))
        p = p.parent
      end
      
      ## first, put current title unless this page is top
      #unless page.locals[:paginator] &&  page.locals[:paginator][:paginated_resources].first == top_page
      
      list << (yield_content(:title) || page.data.title) unless current_resource.source_file == top_page().source_file


      ## return content tags
      content_tag(:nav, :class=>"crumbs") do
        content_tag(:ol, list.map {|elem| content_tag(:li, elem)}, :class=>"breadcrumb")
      end
    end
  end  ## module
end

module Middleman::Akcms
  module Helpers
    include BreadcrumbHelper
    include Contracts

    Contract Middleman::Akcms::Controller
    def akcms
      app.extensions[:akcms].controller
    end

    Contract String => Middleman::Sitemap::Resource
    def page_for(path)
      sitemap.find_resource_by_path(path)
    end
    alias_method :resource_for, :page_for

    Contract nil => Middleman::Sitemap::Resource
    def top_page
      sitemap.find_resource_by_path("/" + config[:index_file])
    end
  end ## Helpers
end

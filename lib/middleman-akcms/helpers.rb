module Middleman::Akcms
  module Helpers
    include Contracts

    Contract Middleman::Akcms::Controller
    def akcms
      app.extensions[:akcms].controller
    end
    
#    def articles
#      app.extensions[:akcms].controller.articles
#    end
    def page_for(path)
      sitemap.find_resource_by_path(path)
    end
    alias_method :resource_for, :page_for

    def top_page
      sitemap.find_resource_by_path("/" + config[:index_file])
    end

    ## breadcrumb
    def breadcrumb(page)
      get_title = proc {|p| p.locals[:display_name] || p.data.title || yield_content(:title) || ""}

      list = []
      ## unshift current title unless this page is top
      list.unshift(get_title.call(page)) unless pagination &&  page.locals[:paginator][:paginated_resources].first == top_page

      ## add categories
      p = page.parent
      while p && p != top_page()
        list.unshift(content_tag(:a, get_title.call(p), href: url_for(p)))
        p = p.parent
      end
      list.unshift(content_tag(:a, "Home", href: url_for(top_page()))) #  unless page == top_page()

      ## add home as last
      content_tag(:nav, :class=>"crumbs") do
        content_tag(:ol, list.map {|elem| content_tag(:li, elem)}, :class=>"breadcrumb")
      end
    end
  end ## Helpers
end

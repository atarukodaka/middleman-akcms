module Middleman::Akcms
  module Helpers
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
    ## pagination
    def pagination_render(type, label: nil, max_display: 10)
      case type
      when :prev_page, :next_page
        page = current_resource.locals[:paginator][type]
        cls = "page-item" + ((page.nil?) ? ' disabled' : '')
        content_tag(:li, link_to(label, page), :class => cls)
      when :pages
        pagination_render_pages(max_display)
      else
        "!!! no such type: #{h(type)} !!!"
      end
    end
    def pagination_render_pages(max_display = 10)
      page_number = current_resource.locals[:paginator][:page_number]
      pages = current_resource.locals[:paginator][:paginated_resources]

      list = [pages[page_number-1]]
      i = 1
      cnt = 1

      while cnt < max_display
        if unreached_bottom = (page_number+i-1 < pages.size)
          list.push pages[page_number+i-1]
          cnt = cnt + 1
        end
        if unreached_top = (page_number-i > 0)
          list.unshift pages[page_number-i-1]
          cnt = cnt + 1
        end
        i += 1
        break if !unreached_bottom && !unreached_top
      end
      list.map do |res|
        cls = "page-item" + ((res == current_resource) ? ' active' : '')
        content_tag(:li, link_to(res.locals[:paginator][:page_number], res), :class=>cls)
      end.join
    end
  end ## Helpers
end

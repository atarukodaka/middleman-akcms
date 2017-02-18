module Middleman::Akcms::Pagination
  class Extension < Middleman::Extension
    include Contracts

    helpers do
      def pagination?
        res = current_resource
        (res.data.pagination && res.locals[:paginator].present?) ? true : false
      end
    end

    Contract Middleman::Sitemap::Resource, Integer, Hash => Middleman::Sitemap::Resource
    def create_page_resource(resource, page_num, metadata = {})
      page_url = @app.config.akcms[:pagination][:page_link] % {page_number: page_num}
      link = resource.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2-#{page_url}.\\3")

      if resource.is_a? Middleman::Sitemap::ProxyResource
        Middleman::Sitemap::ProxyResource.new(@app.sitemap, link, resource.target)
      else
        Middleman::Sitemap::Resource.new(@app.sitemap, link, resource.source_file)
      end.tap do |res|
        res.add_metadata(resource.metadata)
        res.add_metadata(metadata) unless metadata.empty?
        app.logger.debug("  * new pager added: #{res.path}")
      end
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      new_resources = []
      
      resources.each {|res|
        pagination = res.data.pagination
        next if res.ignored? || !pagination
        
        paginated_resources = []
        prev_page = nil
        per_page = pagination.try(:[], :per_page) || @app.config.akcms[:pagination][:per_page]
        
        articles = res.locals[:articles] || @app.sitemap.articles || []
        articles.per_page(per_page).each {|items, num, meta, _is_last|
          # set pager
          meta.prev_page = prev_page
          meta.next_page = nil
          md = {locals: {page_articles: items, paginator: meta}}
          
          if num == 1                          # original resource
            res.add_metadata(md)
            paginated_resources << res
            prev_page = res
          else                                 # new pager resource 2-
            new_res = create_page_resource(res, num, md)
            prev_page.locals[:paginator][:next_page] = new_res
            paginated_resources << new_res
            prev_page = new_res
            new_resources << new_res
          end
        } # each for per_page
        add_paginated_resources(paginated_resources)
      }  # resources
      resources + new_resources
    end

    Contract ResourceList => Any
    def add_paginated_resources(paginated_resources)
      paginated_resources.each {|p|
        p.locals[:paginator][:paginated_resources] = paginated_resources
        p.locals[:paginator][:paginated_resources_for_navigation] =  proc {|r, m|
          paginated_resources_for_navigation(r, m)}
      }
    end
    ## if u have100 pages for navigation and in 8th resource,
    ## u wld get like 4..13th resources
    Contract Middleman::Sitemap::Resource, Integer => ResourceList
    def paginated_resources_for_navigation(resource, max_display=10)
      pages = resource.locals[:paginator][:paginated_resources]
      size = pages.size
      page_number = resource.locals[:paginator][:page_number] -1

      half = (max_display/2).ceil
      start = 0

      0.upto(size - max_display).each do |i|
        start = i
        break if i + half >= page_number
      end
      ed = start + max_display - 1

      return pages[start..ed]
    end
  end ## class
end

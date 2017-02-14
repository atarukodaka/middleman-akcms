## helper
module Middleman::Akcms
  module PaginationHelper
    include ::Contracts

    Contract Bool
    def pagination?
      (current_resource.data.pagination && current_resource.locals.has_key?(:paginator)) ? true : false
    end
    Middleman::Akcms::Extension.helpers(self)
  end  ## module
end

################################################################

module Middleman::Akcms::Pagination
  class Extension < Middleman::Extension
    include Contracts

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
        per_page = @app.config.akcms[:pagination][:per_page]
        if pagination.is_a?(Hash) && pagination[:per_page].to_i > 0
          per_page = pagination[:per_page].to_i
        end

        articles = res.locals[:articles] || @app.sitemap.articles || []
        articles.per_page(per_page).each {|items, num, meta, _is_last|
          locals = {locals: {articles: items, paginator: meta}}
          
          # set pager
          meta.prev_page = prev_page
          meta.next_page = nil
          
          if num == 1                          # original resource
            res.add_metadata(locals)
            paginated_resources << res
            prev_page = res
          else                                 # new pager resource 2-
            new_res = create_page_resource(res, num, locals)
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
        p.locals[:paginator][:paginated_resources_for_navigation] =  proc {|r|
          paginated_resources_for_navigation(r)}
      }
    end
    ## if u have100 pages for navigation and in 8th resource,
    ## u wld get like 4..13th resources
    Contract Middleman::Sitemap::Resource, Integer => ResourceList
    def paginated_resources_for_navigation(resource, max_display = 10)
      current_resource = resource
      page_number = current_resource.locals[:paginator][:page_number]
      pages = current_resource.locals[:paginator][:paginated_resources]

      list = [pages[page_number-1]]
      i = 1
      cnt = 1

      while cnt < max_display
        if (unreached_bottom = (page_number+i-1 < pages.size))
          list.push pages[page_number+i-1]
          cnt = cnt + 1
        end
        if (unreached_top = (page_number-i > 0))
          list.unshift pages[page_number-i-1]
          cnt = cnt + 1
        end
        i += 1
        break if !unreached_bottom && !unreached_top
      end
      return list
    end
  end ## class
end

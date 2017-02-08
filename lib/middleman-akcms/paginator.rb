require 'middleman-akcms/manipulator'

## helper
module Middleman::Akcms
  module PaginationHelper
    include ::Contracts

    Contract Bool
    def pagination?
      (current_resource.data.pagination && current_resource.locals.has_key?(:paginator)) ? true : false
    end
  end  ## module
end

################################################################

module Middleman::Akcms
  class PaginatorManipulator
    Middleman::Akcms::Controller.register(:paginator, self)
    
    include Manipulator
    include Contracts
    
    def initialize(controller)
      controller.extension.class.defined_helpers << Middleman::Akcms::PaginationHelper
      set_attributes(controller)
    end

    Contract Middleman::Sitemap::Resource, Integer, Hash => Middleman::Sitemap::Resource
    def create_page_resource(resource, page_num, metadata = {})
      page_url = @controller.options.pagination_page_link % {page_number: page_num}
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

        articles = res.locals[:articles] || @controller.articles
        paginated_resources = []
        prev_page = nil
        per_page = (pagination.is_a? Hash) ? pagination[:per_page] : @controller.options.pagination_per_page

        articles.per_page(per_page).each {|items, num, meta, _is_last|
          locals = {locals: {articles: items, paginator: meta}}
          
          # set pager
          meta.prev_page = prev_page
          meta.next_page = nil
          
          if num == 1      # original resource
            res.add_metadata(locals)
            paginated_resources << res
            prev_page = res
          else             # new pager resource 2-
            new_res = create_page_resource(res, num, locals)
            prev_page.locals[:paginator][:next_page] = new_res
            paginated_resources << new_res
            prev_page = new_res
            new_resources << new_res
          end
        } # each for per_page
        paginated_resources.each {|p|
          p.locals[:paginator][:paginated_resources] = paginated_resources
          p.locals[:paginator][:paginated_resources_for_navigation] =  proc {|r|
            paginated_resources_for_navigation(r)}
        }
      }  # resources
      resources + new_resources
    end

    ## if u have100 pages for navigation and in 8th resource,
    ## u wld get like 4..13th resources as array
    Contract Middleman::Sitemap::Resource, Integer => ResourceList
    def paginated_resources_for_navigation(resource, max_display = 10)
      current_resource = resource
      page_number = current_resource.locals[:paginator][:page_number]
      pages = current_resource.locals[:paginator][:paginated_resources]

      list = [pages[page_number-1]]
      i = 1
      cnt = 1

      while cnt < max_display
        if unreached_bottom = (page_number+i-1 < pages.size) # rubocop:disable all
          list.push pages[page_number+i-1]
          cnt = cnt + 1
        end
        if unreached_top = (page_number-i > 0)               # rubocop:disable all
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

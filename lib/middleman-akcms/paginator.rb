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
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    def initialize(controller)
      controller.extension.class.defined_helpers << Middleman::Akcms::PaginationHelper
      set_attributes(controller)
    end

    Contract C::Resource, Integer, Hash => C::Resource
    def create_page_resource(resource, page_num, metadata = {})
      page_url = @controller.options.pagination_page_link % {page_number: page_num}
      link = resource.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2-#{page_url}.\\3")

      if resource.is_a? Middleman::Sitemap::ProxyResource
        Middleman::Sitemap::ProxyResource.new(@sitemap, link, resource.target)
      else
        Middleman::Sitemap::Resource.new(@sitemap, link, resource.source_file)
      end.tap do |res|
        res.add_metadata(resource.metadata)
        res.add_metadata(metadata) unless metadata.empty?
      end
    end

    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      controller.app.logger.debug("-- paginator manipulation")
      new_resources = []
      
      resources.each {|res|
        next if res.ignored? || !res.data.pagination

        articles = res.locals[:articles] || @controller.articles
        paginated_resources = []
        md = res.metadata
        prev_page = nil
        
        per_page = if res.data.pagination.is_a? Hash
                     res.data.pagination[:per_page]
                   else
                     @controller.options.pagination_per_page
                   end
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
          p.locals[:paginator][:paginated_resources_for_navigation] =  proc {|res|
            paginated_resources_for_navigation(res)}
        }
      }  # resources
      resources + new_resources
    end

    ## if u have100 pages for navigation and in 8th resource,
    ## u wld get like 4..13th resources as array
    Contract C::Resource, Integer => ArrayOf[C::Resource]
    def paginated_resources_for_navigation(resource, max_display = 10)
      current_resource = resource
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
      return list
    end
  end ## class
end

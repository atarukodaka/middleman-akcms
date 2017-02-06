require 'middleman-akcms/manipulator'

## helper

module Middleman::Akcms
  module PaginationHelper
    include ::Contracts
    C = Middleman::Akcms::Contracts
    
    Contract Bool
    def pagination?
      (current_resource.data.pagination && current_resource.locals.has_key?(:paginator)) ? true : false
    end
    
=begin
    Contract Integer => ArrayOf[C::Resource]
    def pagination_display_pages(max_display = 10)
      page_number = current_resource.locals[:paginator][:page_number]
      pages = current_resource.locals[:paginator][:paginated_resources] || []

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
=end    
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

    Contract C::Resource, Integer => C::Resource
    def create_page_resource(resource, page_num)
      #sitemap = @controller.extension.app.sitemap
      page_url = @controller.options.pagination_page_link % {page_number: page_num}
      link = resource.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2-#{page_url}.\\3")

      if resource.is_a? Middleman::Sitemap::ProxyResource
        Middleman::Sitemap::ProxyResource.new(@sitemap, link, resource.target)
      else
        Middleman::Sitemap::Resource.new(@sitemap, link, resource.source_file)
      end
    end

    def paginated_resources_for_navigation(resource, max_display = 10)
      current_resource = resource
      page_number = current_resource.locals[:paginator][:page_number]
      pages = current_resource.locals[:paginator][:paginated_resources] || []

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
    
    Contract ArrayOf[C::Resource] => ArrayOf[C::Resource]
    def manipulate_resource_list(resources)
      new_resources = []
      
      resources.each {|res|
        next if res.ignored? || !res.data.pagination

        articles = res.locals[:articles] || @controller.articles
        paginated_resources = []
        md = res.metadata
        prev_page = nil
        per_page = (res.data.pagination.is_a? Hash) ? res.data.pagination[:per_page] : @controller.options.pagination_per_page
        articles.per_page(per_page).each {|items, num, meta, _is_last|
          meta.prev_page = prev_page
          meta.next_page = nil

          if num == 1
            res.add_metadata(locals: {articles: items, paginator: meta})
            paginated_resources << res
            prev_page = res
          else
            new_res = create_page_resource(res, num).tap do|p|
              p.add_metadata(md)
              p.add_metadata(locals: {articles: items, paginator: meta})
            end
            prev_page.locals[:paginator][:next_page] = new_res
            prev_page = new_res

            new_resources << new_res
            paginated_resources << new_res
          end
        } # each for per_page
        paginated_resources.each {|p|
          p.locals[:paginator][:paginated_resources] = paginated_resources
          p.locals[:paginator][:paginated_resources_for_navigation] =  proc {|res| paginated_resources_for_navigation(res)}
        }
      }  # resources
      resources + new_resources
    end
  end ## class
end

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
    Contract Integer => String
    def pagination_render_pages(max_display = 10)
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
      list.map do |res|
        cls = "page-item" + ((res == current_resource) ? ' active' : '')
        content_tag(:li, link_to(res.locals[:paginator][:page_number], res), :class=>cls)
      end.join
    end
  end  ## module
end

################################################################

module Middleman::Akcms
  class PaginatorManipulator < Manipulator
    Middleman::Akcms::Controller.register(:paginator, self)
    ################
    include Contracts
    C = Middleman::Akcms::Contracts
    
    def initialize(controller)
      controller.extension.class.defined_helpers << Middleman::Akcms::PaginationHelper
      super(controller)
    end

    Contract C::Resource, Integer => C::Resource
    def create_page_resource(resource, page_num)
      sitemap = @controller.extension.app.sitemap
      page_url = @controller.options.pagination_page_link % {page_number: page_num}
      link = resource.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2-#{page_url}.\\3")

      if resource.is_a? Middleman::Sitemap::ProxyResource
        Middleman::Sitemap::ProxyResource.new(sitemap, link, resource.target)
      else
        Middleman::Sitemap::Resource.new(sitemap, link, resource.source_file)
      end
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
            #meta[:articles] = items
            res.add_metadata(locals: {articles: items})
            res.add_metadata(locals: {paginator: meta})
            paginated_resources << res
            prev_page = res
          else
            #meta[:articles] = items
            new_res = create_page_resource(res, num)
            new_res.add_metadata(md)
            new_res.add_metadata(locals: {paginator: meta})
            new_res.add_metadata(locals: {articles: items})
            prev_page.locals[:paginator][:next_page] = new_res
            prev_page = new_res

            new_resources << new_res
            paginated_resources << new_res
          end
        } # each for per_page
        paginated_resources.each {|p|
          p.add_metadata(locals: {paginator: {paginated_resources: paginated_resources}})
        }
      }  # resources
      resources + new_resources
    end
  end ## class
end

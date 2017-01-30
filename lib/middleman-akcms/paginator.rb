require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class PaginatorManipulator < Manipulator

    module Helpers
      def render_item(type, label = "-")
        binding.pry
        case type
        when :prev
          cls = "page-item" + (prev_page.nil?) ? ' disabled' : ''
          content_tag(:li, link_to(label, prev_page), :class => cls)
        when :next
          cls = "page-item" + (next_page.nil?) ? ' disabled' : ''
          content_tag(:li, link_to(label, next_page), :class => cls)
        when :pages
          paginated_resources.map_with_index do |res, i|
            cls = "page-item"
            content_tag(:li, link_to(i, res), :class => cls)
          end
        else
          raise
        end
      end
    end
    ################
    
    def create_page_resource(resource, page_num)
      sitemap = @controller.extension.app.sitemap
      page_url = @controller.options.pagination_page_link % {page_number: page_num}
      link = resource.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2/#{page_url}.\\3")

      if resource.is_a? Middleman::Sitemap::ProxyResource
        Middleman::Sitemap::ProxyResource.new(sitemap, link, resource.target)
      else
        Middleman::Sitemap::Resource.new(sitemap, link, resource.source_file)
      end
    end
    def manipulate_resource_list(resources)
      new_resources = []
      
      resources.each {|res|
        next if res.ignored?
        next unless res.data.pagination
        
        paginated_resources = []
        md = res.metadata
        prev_page = nil

        per_page = (res.data.pagination.is_a? Hash) ? res.data.pagination[:per_page] : @controller.options.pagination_per_page

        articles = res.locals[:articles] || @controller.articles
        articles.per_page(per_page).each {|items, num, meta, is_last|
          meta.prev_page = prev_page
          meta.next_page = nil

          if num == 1
            res.add_metadata(locals: {page_articles: items, paginator: meta})
            paginated_resources << res
            prev_page = res
          else
            new_res = create_page_resource(res, num).tap {|p|
              p.add_metadata(md)
              p.add_metadata(locals: {page_articles: items, paginator: meta})
              #prev_page.add_metadata(locals: {next_page: p})
              prev_page.locals[:paginator][:next_page] = p
              prev_page = p
            }
            new_resources << new_res
            paginated_resources << new_res
          end
        } # each for per_page
        paginated_resources.each {|res|
          res.add_metadata(locals: {paginator: {paginated_resources: paginated_resources}})
        }
      }  # resources
      resources + new_resources
    end
  end ## class
end

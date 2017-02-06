module Middleman::Akcms
  module Helpers
#    include BreadcrumbHelper
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

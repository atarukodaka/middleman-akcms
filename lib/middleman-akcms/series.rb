require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class SeriesManipulator < Manipulator
    include Contracts
    
    attr_reader :tags

    Contract Array => Array    
    def manipulate_resource_list(resources)
      used_resources = []
      modified_resources  = []

      resources.each {|res|
        if res.data.series
          #name = res.data.series[:name] || res.category_resource.locals[:display_name]
          #number = res.data.series[:number] || nil
          name = res.category_resource.locals[:display_name]
          fname = File.split(res.path).last
          md = fname.match(/^([0-9]+)[_\-\s]/)
          number = (md.nil?) ? 0 : md[1].to_i
          title = controller.options.series_title_template % {name: name, number: number, title: res.data.title}
          #res.add_metadata(page: {title: "#{name}[#{number}]: #{res.data.title}"}) ## yet optionable
          res.add_metadata(page: {title: title})
          res.add_metadata(locals: {series: {name: name, number: number, related_articles: []}})
          modified_resources << res
        else
          used_resources << res
        end
      }
      modified_resources.each {|res|
        related_articles = modified_resources.select {|r| r.locals[:series][:name] == res.locals[:series][:name]}
        res.locals[:series][:related_articles] = related_articles
      }
      #binding.pry
      used_resources + modified_resources
    end
    ################################################################
    private
    Contract String => String
    def link(name)
      @controller.options.tag_link % {tag: name}
    end
  end # class
end

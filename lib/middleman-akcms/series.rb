require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class SeriesManipulator < Manipulator
    include Contracts
    
    Contract Array => Array    
    def manipulate_resource_list(resources)
      used_resources = []
      modified_resources  = []

      resources.each {|res|
        if res.data.series
          name = res.metadata[:directory][:name]
          fname = File.split(res.path).last
          md = fname.match(/^([0-9]+)[_\-\s]/)
          number = (md.nil?) ? 0 : md[1].to_i
          title = controller.options.series_title_template % {name: name, number: number, title: res.data.title}
          res.add_metadata(page: {title: title})
          res.add_metadata(locals: {series: {name: name, number: number}})
          modified_resources << res
        else
          used_resources << res
        end
      }
      modified_resources.each {|res|
        series_articles = modified_resources.select {|r| r.locals[:series][:name] == res.locals[:series][:name]}
        res.add_metadata(locals: {series: {series_articles: series_articles}})
      }
      used_resources + modified_resources
    end
  end # class
end

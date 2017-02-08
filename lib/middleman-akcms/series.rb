require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class SeriesManipulator
    Middleman::Akcms::Controller.register(:series, self)

    include Manipulator
    include Contracts
    
    def initialize(controller)
      set_attributes(controller)
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      new_resources = []
      controller.articles.each do|article|
        if article.data.series
          name = article.metadata[:directory][:name]
          File.split(article.path).last =~ /^([0-9]+)[_\-\s]/
          number = $1.to_i
          title = apply_title(name: name, number: number, title: article.title)
          article.add_metadata({page: { title: title },
                                 locals: {
                                   series: {
                                     name: name,
                                     number: number}}})
          new_resources << article
        end
      end

      new_resources.each do |res|
        res_name = res.locals[:series][:name]
        res.locals[:series][:articles] = new_resources.select {|r|
          res_name == r.locals[:series][:name]
        }
      end
      resources
    end
=begin
    Contract ResourceList => ResourceList
    def _manipulate_resource_list(resources)
      used_resources = []
      series_resources  = []

      resources.each {|res|
        if res.data.series
          name = res.metadata[:directory][:name]
          fname = File.split(res.path).last
          md = fname.match(/^([0-9]+)[_\-\s]/)
          number = (md.nil?) ? 0 : md[1].to_i
          title = apply_title(name: name, number: number, title: res.data.title)
          res.add_metadata({page: {title: title},
                             locals: {series: {name: name, number: number}}})
          #res.add_metadata(
          series_resources << res
        else
          used_resources << res
        end
      }
      series_resources.each {|res|
        res.locals[:series][:articles] = series_resources.select {|r|
          r.locals[:series][:name] == res.locals[:series][:name]}
      }
      used_resources + series_resources
    end
=end
    Contract Hash => String
    def apply_title(hash)
      controller.options.series_title_template % hash
    end
  end # class
end

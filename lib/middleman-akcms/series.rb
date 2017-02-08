require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class SeriesManipulator
    Middleman::Akcms::Controller.register(:series, self)

    include Manipulator
    include Contracts
    
    def initialize(controller)
      initialize_manipulator(controller)
    end
    
    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      new_resources = []

      controller.articles.each do|article|
        if article.data.series
          name = ((article.metadata.has_key?(:directory)) ? article.metadata[:directory][:name] : nil) || File.dirname(article.path).last
          number = (File.split(article.path).last =~ /^([0-9]+)[_\-\s]/).nil? ? 0 : $1.to_i
          
          hash = { name: name, number: number}
          title = apply_title(hash.merge(article_title: article.title))
          article.add_metadata({page: { title: title }, locals: { series: hash }})
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
    Contract Hash => String
    def apply_title(hash)
      controller.options.series_title_template % hash
    end
  end # class
end

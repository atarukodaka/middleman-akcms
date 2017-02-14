module Middleman::Akcms::Series
  class Extension < Middleman::Extension
    include Contracts

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      series_articles = []

      resources.select {|r| r.is_article? }.each do|article|
        if article.data.series
          name = ((article.metadata.has_key?(:directory)) ? article.metadata[:directory][:name] : nil) || File.dirname(article.path).last
          number = (File.split(article.path).last =~ /^([0-9]+)[_\-\s]/).nil? ? 0 : $1.to_i
          
          hash = { name: name, number: number}
          title = apply_title(hash.merge(article_title: article.title))
          article.add_metadata({page: { title: title }, locals: { series: hash }})
          series_articles << article
        end
      end

      series_articles.each do |res|
        res_name = res.locals[:series][:name]
        res.locals[:series][:articles] = series_articles.select {|r|
          res_name == r.locals[:series][:name]
        }
      end
      resources
    end

    Contract Hash => String
    def apply_title(hash)
      @app.config.akcms[:series][:title_template] % hash
      #controller.options.series_title_template % hash
    end
  end # class
end

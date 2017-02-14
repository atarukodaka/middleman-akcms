require "middleman-core"
# require "middleman-aks/template"
require "middleman-akcms/version"


::Middleman::Extensions.register(:akcms) do
  require 'middleman-akcms/extension'
  ::Middleman::Akcms::Extension
end

Middleman::Extensions.register(:akcms_article) do
  require 'middleman-akcms/article'
  Middleman::Akcms::Article::Extension
end

Middleman::Extensions.register(:akcms_directory_summary) do
  require 'middleman-akcms/directory_summary'
  Middleman::Akcms::DirectorySummary::Extension
end


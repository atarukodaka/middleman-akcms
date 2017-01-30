require "middleman-core"
# require "middleman-aks/template"
require "middleman-akcms/version"


::Middleman::Extensions.register(:akcms) do
  require 'middleman-akcms/extension'
  ::Middleman::Akcms::Extension
end

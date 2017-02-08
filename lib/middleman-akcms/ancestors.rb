require 'middleman-akcms/manipulator'

module Middleman::Akcms
  class AncestorsManipulator
    Middleman::Akcms::Controller.register(:ancestors, self)
    
    include Manipulator
    include Contracts

    Contract Middleman::Akcms::Controller => Any
    def initialize(controller)
      initialize_manipulator(controller)
    end

    Contract ResourceList => ResourceList
    def manipulate_resource_list(resources)
      resources.each {|res|
        ancestors = []
        p = res.parent
        while p
          ancestors << p
          p = p.parent
        end
        res.add_metadata({ancestors: ancestors})
      }
      resources
    end
  end ## class
end

def show(res)
  ar = ["<li>#{res[:text]}"]
  if res[:children]
    ar << "<ul>"
    res[:children].each do |child|
      ar << show(child)
    end
    ar << "</ul>"
  end
  ar << "</li>"
  ar.join("\n")
end


top = {text: "top", children:
  [{text: "child1", children:
     [{text: "mago"}]
   },
   {text: "child2"}
  ],}

puts "<ul>#{show(top)}</ul>"



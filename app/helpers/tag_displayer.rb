module TagDisplayer
  def css_label(tag)
    tag.name.downcase.sub(/\s+/, '-')
  end
end

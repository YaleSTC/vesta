module TagDisplayer
  def self.tag_with_remove(tag, remove_path)
    remove_button = button_to("X", remove_path,
                              id: "remove-#{tag.name.downcase}")
    "<p> #{tag.name} #{remove_button} </p>"
  end
end

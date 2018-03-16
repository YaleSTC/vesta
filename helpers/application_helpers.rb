# frozen_string_literal: true

module ApplicationHelpers
  def markdown(contents)
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      fenced_code_blocks: true,
      footnotes: true,
      highlight: true,
      smartypants: true,
      strikethrough: true,
      tables: true,
      with_toc_data: true
    )
    markdown.render(contents)
  end

  def svg(name)
    root = Middleman::Application.root
    images_path = config[:images_dir]
    file_path = "#{root}/source/#{images_path}/#{name}"

    return File.read(file_path) if File.exists?(file_path)

    raise "SVG not found: #{name}"
  end

  def page_title
    base = 'Vesta Docs'
    return base unless current_page.data.title.present?
    "#{base} | #{current_page.data.title}"
  end
end

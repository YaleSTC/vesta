# frozen_string_literal: true

require 'open-uri'

# Utility class to retrieve a file from the internet and download it to the tmp
# directory
class FileFetcher
  include Callable

  # Initialize a new FileFetcher
  def initialize(url:, io: $stdout)
    @url = url
    @filename = url.split('/').last
    @location = Rails.root.join('tmp', filename)
    @io = io
  end

  def fetch
    download_file
    location
  rescue Errno::ENOENT
    io.puts 'Invalid URL - you must enter a valid file URL'
    exit # rubocop:disable Rails/Exit
  rescue Errno::ECONNREFUSED
    io.puts "Unable to download a file from #{url}"
    exit # rubocop:disable Rails/Exit
  end

  make_callable :fetch

  private

  attr_reader :filename, :location, :url, :io

  def download_file
    download = open(url)
    IO.copy_stream(download, location)
    io.puts "Downloaded #{filename}"
  end
end

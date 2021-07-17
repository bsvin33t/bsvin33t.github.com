require "active_support/inflector"
require "date"

DIR_NAME = "../"
PAGE_FILES = ["about"]
IGNORED_FILES = ["README"]

class Post
  LAYOUT = "layout: post"
  CATEGORIES = "undefined"
  OUTPUT_DIR = "_posts"

  attr_reader :title, :file, :categories, :created_at, :file_basename

  def initialize(file_path)
    @file = File.open(file_path)
    @file_basename = File.basename(file_path, ".md")
    @title = @file_basename.humanize
    @categories = CATEGORIES
    @created_at = File.mtime(file_path)
  end

  def write
    Dir.mkdir(OUTPUT_DIR) unless File.exists?(OUTPUT_DIR)
    File.open("#{self.class::OUTPUT_DIR}/#{file_name}", "w") do |f|
      f.write(file_content)
    end
  end

  private

  def file_content
    "---\n"\
      "#{LAYOUT}\n"\
      "title: \"#{title.titleize}\"\n"\
      "date: #{created_at}\n"\
      "---\n"\
      "#{file.read}\n"
  end

  def file_name
    "#{file_name_timestamp}-#{file_basename}.markdown"
  end

  def file_name_timestamp
    created_at.strftime("%Y-%m-%d")
  end
end

class Page < Post
  LAYOUT = "layout: page"
  OUTPUT_DIR = "."

  def file_content
    "---\n"\
      "#{LAYOUT}\n"\
      "title: \"#{file_basename.titleize}\"\n"\
      "permalink: /#{file_basename}/\n"\
      "---\n"\
      "#{file.read}\n"
  end

  def file_name
    "#{file_basename}.markdown"
  end
end

class Blog
  def self.build
    Dir["#{Dir.pwd}/#{DIR_NAME}/*.md"].each do |file|
      post = Post.new(file)

      next if PAGE_FILES.any?(post.file_basename)
      next if IGNORED_FILES.any?(post.file_basename)

      post.write
    end

    Dir["#{Dir.pwd}/#{DIR_NAME}/*.md"].each do |file|
      page = Page.new(file)

      next unless PAGE_FILES.any?(page.file_basename)
      next if IGNORED_FILES.any?(page.file_basename)

      page.write
    end
  end
end

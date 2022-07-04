require_relative 'blog'
task :default do
  puts "Starting build process!"
  Blog.build
  puts "Build process done"
end

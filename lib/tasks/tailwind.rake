namespace :tailwind do
  task :copy do
    source = Rails.root.join("app/assets/builds/tailwind.css")
    dest   = Rails.root.join("app/assets/stylesheets/tailwind.css")
    FileUtils.cp(source, dest) if File.exist?(source)
    puts "tailwind.css copied to stylesheets"
  end
end

Rake::Task["tailwindcss:build"].enhance do
  Rake::Task["tailwind:copy"].invoke
end
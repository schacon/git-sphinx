#! /usr/bin/env ruby
require 'git_sphinx'

# accepts --main and --new for building the main and the new index

dm = DataMapper.setup(:default, 'mysql://localhost/git_file_index')
#DataMapper.auto_migrate!

# look for flag
if ARGV[0] == '--main'
  index_main = true
else
  index_new = true
end

# get repository list from db (based on main or new)
repos = []
if index_main
  projects = `locate '.git/description' | grep projects`
  projects.each do |project_line|
    project_line = project_line.split('/')
    project_line.pop
    if(project_line.size < 7)
      project = project_line.join('/')
      pname = project.scan(/\/([a-zA-z0-9\-_]*?)\/.git/).first.first rescue nil
      repos << [pname, project] if pname
    end
  end
else
  repos << ['grit', '/Users/schacon/projects/grit/.git']
end

idx = GitSphinx::Indexer.new(dm)
idx.print_header
repos.each do |repo, path|
  idx.print_document(repo, path)
end  
idx.print_footer

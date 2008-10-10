# /usr/bin/env ruby
require 'git_sphinx'

# accepts --main and --new for building the main and the new index

# look for flag
if ARGV[0] == '--main'
  index_main = true
else
  index_new = true
end

# get repository list from db (based on main or new)
repos = [
  ['fuzed', '/Users/schacon/projects/fuzed/.git']
]

idx = GitSphinx::Indexer.new
idx.print_header
repos.each do |repo, path|
  idx.print_document(repo, path)
end  
idx.print_footer

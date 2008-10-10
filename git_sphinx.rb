require 'rubygems'
require 'grit'
require 'pp'

module GitSphinx
  class Indexer
    
    def initialize
    end
    
    def print_header
      puts '<?xml version="1.0" encoding="utf-8"?>'
      puts '<sphinx:docset>'
      puts '<sphinx:schema>
  <sphinx:field name="repository"/> 
  <sphinx:attr name="modified" type="timestamp"/>
  <sphinx:field name="language"/>
</sphinx:schema>'
    end

    # open up this project and enter every normal file into the parser
    # that was modified after [modified_date] (if supplied)
    def print_document(repo, path, modified_date = nil)
      g = Grit::Repo.new(path)
      pp g.commits

      pp g.commit('master').tree
      
      puts "<sphinx:document id=\"1234\">
  <repository>#{repo}</repository>
  <modified>1012325463</modified>
  <language></language>
  <content></content>
</sphinx:document>"
    end
    
    def print_footer
      puts '</sphinx:docset>'
    end
    
  end
end
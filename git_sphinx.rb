require 'rubygems'
require 'grit'
require 'fast_xs'
require 'dm-core'
require 'albino'
require 'pp'

class GitFile
 include DataMapper::Resource
 property :id,    Integer, :serial => true
 property :repo,  String
 property :path,  String
 property :sha_value,  String
end
 
module GitSphinx
  class Indexer
    
    def initialize(dm_connection)
      @map = dm_connection
    end
    
    def print_header
      puts '<?xml version="1.0" encoding="utf-8"?>'
      puts '<sphinx:docset>'
      puts '<sphinx:schema>
  <sphinx:field name="repository"/> 
  <sphinx:field name="path"/> 
  <sphinx:attr name="modified" type="timestamp"/>
  <sphinx:field name="language"/>
</sphinx:schema>'
    end

    # open up this project and enter every normal file into the parser
    # that was modified after [modified_date] (if supplied)
    def print_document(repo, path, modified_date = nil)
      g = Grit::Repo.new(path)

      # !!! do this for each head, ignoring common blobs, starting with master
      g.git.method_missing('ls_tree', {'full-name' => true, 'r' => true}, 'master').split("\n").each do |line|
        (info, path) = line.split("\t")
        (mode, type, sha) = info.split(' ')

        lexer = Albino.find_lexer(path)
        if type == 'blob' && (lexer != 'plain')
          next if !(id = get_object_id(repo, path, sha))
          blob = g.blob(sha)
          
          # i'd like to check for binary data here, but I suppose it doens't really 
          # matter - i assume sphinx will just ignore it if it can't parse any
          # valid chars out of it
                    
          content = blob.data
          #.fast_xs
          
          puts "<sphinx:document id=\"#{id}\">
  <repository>#{repo}</repository>
  <path>#{path}</path>
  <modified>1012325463</modified>
  <language></language>
  <content><![CDATA[#{content}]]></content>
</sphinx:document>"
        end
      end
    end
    
    def get_object_id(repo, file_path, sha)
      if gf = GitFile.first(:repo => repo, :path => file_path, :sha_value => sha)
        return gf.id
      else
        gf = GitFile.create(:repo => repo, :path => file_path, :sha_value => sha)
        return gf.id
      end
    end
    
    def print_footer
      puts '</sphinx:docset>'
    end
    
  end
end
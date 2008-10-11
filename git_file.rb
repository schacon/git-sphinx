class GitFile
  include DataMapper::Resource
  property :id,    Integer, :serial => true
  property :repo,  String
  property :path,  String
  property :sha_value,  String
end
#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'riddle'
require 'dm-core'
require 'dm-aggregates'
require 'git_file'
require 'pp'

# sinatra server for searching your codes
DataMapper.setup(:default, 'mysql://localhost/git_file_index')
$client = Riddle::Client.new

def show_doc(id)
  f = GitFile.get(id.to_i)
  [f.repo, f.path].join(', ')
end

template :layout do
"
<html>
<form method=\"POST\" action=\"/search\">
  <input name=\"search\" type=\"text\">
  <input type=\"submit\">
</form>

<%= yield %>
</html>
"
end
  
template :index do
  '<em>type a search term to begin</em>'
end

template :results do
'
<h1><%= @results[:total] %> Results</h1>
<% @results[:matches].each do |match| %>
  <li><%= show_doc(match[:doc]) %>
<% end %>

<hr/>
<h3>Matches</h3>
<% @results[:words].each do |word, stats| %>
  <li><%= word %> (docs:<%= stats[:docs] %>, hits:<%= stats[:hits] %>)
<% end %>

<hr/>
Results took : <%= @results[:time] %>s
'
end

get '/' do
  erb :index
end

post '/search' do
  
  @results = $client.query params[:search]
  erb :results
end

#collected 40569 docs, 216.5 MB
#sorted 15.8 Mhits, 100.0% done
#total 40569 docs, 216528702 bytes
#total 617.686 sec, 350548.44 bytes/sec, 65.68 docs/sec

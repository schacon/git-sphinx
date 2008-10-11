##
# Wrapper for the Pygments command line tool, pygmentize.
#
# Pygments: http://pygments.org/
#
# Assumes pygmentize is in the path.  If not, set its location
# with Albino.bin = '/path/to/pygmentize'
#
# Use like so:
#
#   @syntaxer = Albino.new('/some/file.rb', :ruby)
#   puts @syntaxer.colorize
#
# This'll print out an HTMLized, Ruby-highlighted version
# of '/some/file.rb'.
#
# To use another formatter, pass it as the third argument:
#
#   @syntaxer = Albino.new('/some/file.rb', :ruby, :bbcode)
#   puts @syntaxer.colorize
#
# You can also use the #colorize class method:
#
#   puts Albino.colorize('/some/file.rb', :ruby)
#
# Another also: you get a #to_s, for somewhat nicer use in Rails views.
#
#   ... helper file ...
#   def highlight(text)
#     Albino.new(text, :ruby)
#   end
#
#   ... view file ...
#   <%= highlight text %>
#
# The default lexer is 'text'.  You need to specify a lexer yourself;
# because we are using STDIN there is no auto-detect.
#
# To see all lexers and formatters available, run `pygmentize -L`.
#
# Chris Wanstrath // chris@ozmm.org 
#         GitHub // http://github.com
#
require 'rubygems' unless defined? Gem
require 'open4'

class Albino
  @@bin = defined?(Rails) && Rails.development? ? 'pygmentize' : '/usr/bin/pygmentize'

  def self.bin=(path)
    @@bin = path
  end

  def self.colorize(*args)
    new(*args).colorize
  end

  def self.find_lexer(file_name)
    if arr = Albino.find_lexer_array(file_name)
      arr[1]
    else
      'plain'
    end
  end

  def self.find_lexer_name(file_name)
    if arr = Albino.find_lexer_array(file_name)
      arr[2]
    else
      'Text'
    end
  end

  def self.find_lexer_array(file_name)
    ext = File.extname(file_name)
    if arr = Albino.extensions.assoc(ext)
      arr
    end
  end

  def self.name_extensions
    lexers = {}
    Albino.extensions.map { |a| lexers[a[2]] = a[0] }
    lexers.to_a.sort
  end

  def self.extensions
    [
      ['.as', 'as', 'ActionScript'],
      ['.sh', 'bash', 'Bash'],
      ['.bat', 'bat', 'Batchfile'],
      ['.cmd', 'bat', 'Batchfile'],
      ['.befunge', 'befunge', 'Befunge'],
      ['.boo', 'boo', 'Boo'],
      ['.bf', 'brainfuck', 'Brainfuck'],
      ['.b', 'brainfuck', 'Brainfuck'],
      ['.c-objdump', 'c-objdump', 'c-objdump'],
      ['.h', 'c', 'C'],
      ['.c', 'c', 'C'],
      ['.cl', 'common-lisp', 'Common Lisp'],
      ['.lisp', 'common-lisp', 'Common Lisp'],
      ['.el', 'common-lisp', 'Common Lisp'],
      ['.hpp', 'cpp', 'C++'],
      ['.c++', 'cpp', 'C++'],
      ['.h++', 'cpp', 'C++'],
      ['.cc', 'cpp', 'C++'],
      ['.hh', 'cpp', 'C++'],
      ['.cxx', 'cpp', 'C++'],
      ['.hxx', 'cpp', 'C++'],
      ['.cpp', 'cpp', 'C++'],
      ['.cpp-objdump', 'cpp-objdump', 'cpp-objdump'],
      ['.c++-objdump', 'cpp-objdump', 'cpp-objdump'],
      ['.cxx-objdump', 'cpp-objdump', 'cpp-objdump'],
      ['.cs', 'csharp', 'C#'],
      ['.css', 'css', 'CSS'],
      ['.d-objdump', 'd-objdump', 'd-objdump'],
      ['.d', 'd', 'D'],
      ['.di', 'd', 'D'],
      ['.pas', 'delphi', 'Delphi'],
      ['.patch', 'diff', 'Diff'],
      ['.diff', 'diff', 'Diff'],
      ['.dpatch', 'dpatch', 'Darcs Patch'],
      ['.darcspatch', 'dpatch', 'Darcs Patch'],
      ['.dylan', 'dylan', 'Dylan'],
      ['.hrl', 'erlang', 'Erlang'],
      ['.erl', 'erlang', 'Erlang'],
      ['.f', 'fortran', 'Fortran'],
      ['.f90', 'fortran', 'Fortran'],
      ['.s', 'gas', 'GAS'],
      ['.S', 'gas', 'GAS'],
      ['.kid', 'genshi', 'Genshi'],
      ['.[1234567]', 'groff', 'Groff'],
      ['.man', 'groff', 'Groff'],
      ['.hs', 'haskell', 'Haskell'],
      ['.phtml', 'html+php', 'HTML+PHP'],
      ['.htm', 'html', 'HTML'],
      ['.xhtml', 'html', 'HTML'],
      ['.xslt', 'html', 'HTML'],
      ['.html', 'html', 'HTML'],
      ['.ini', 'ini', 'INI'],
      ['.cfg', 'ini', 'INI'],
      ['.properties', 'ini', 'INI'],
      ['.io', 'io', 'Io'],
      ['.weechatlog', 'irc', 'IRC logs'],
      ['.java', 'java', 'Java'],
      ['.js', 'js', 'JavaScript'],
      ['.jsp', 'jsp', 'Java Server Page'],
      ['.lhs', 'lhs', 'Literate Haskell'],
      ['.ll', 'llvm', 'LLVM'],
      ['.lgt', 'logtalk', 'Logtalk'],
      ['.lua', 'lua', 'Lua'],
      ['.mak', 'make', 'Makefile'],
      ['.mao', 'mako', 'Mako'],
      ['.matlab', 'matlab', 'Matlab'],
      ['.md', 'minid', 'MiniD'],
      ['.moo', 'moocode', 'MOOCode'],
      ['.mu', 'mupad', 'MuPAD'],
      ['.myt', 'myghty', 'Myghty'],
      ['.py', 'numpy', 'NumPy'],
      ['.pyw', 'numpy', 'NumPy'],
      ['.sc', 'numpy', 'NumPy'],
      ['.objdump', 'objdump', 'objdump'],
      ['.m', 'objective-c', 'Objective-C'],
      ['.mli', 'ocaml', 'OCaml'],
      ['.mll', 'ocaml', 'OCaml'],
      ['.mly', 'ocaml', 'OCaml'],
      ['.ml', 'ocaml', 'OCaml'],
      ['.pm', 'perl', 'Perl'],
      ['.pl', 'perl', 'Perl'],
      ['.php[345]', 'php', 'PHP'],
      ['.php', 'php', 'PHP'],
      ['.pot', 'pot', 'Gettext Catalog'],
      ['.po', 'pot', 'Gettext Catalog'],
      ['.pytb', 'pytb', 'Python Traceback'],
      ['.pyw', 'python', 'Python'],
      ['.py', 'python', 'Python'],
      ['.sc', 'python', 'Python'],
      ['.raw', 'raw', 'Raw token data'],
      ['.rb', 'rb', 'Ruby'],
      ['.rbw', 'rb', 'Ruby'],
      ['.rake', 'rb', 'Ruby'],
      ['.gemspec', 'rb', 'Ruby'],
      ['.rbx', 'rb', 'Ruby'],
      ['.cw', 'redcode', 'Redcode'],
      ['.rhtml', 'rhtml', 'RHTML'],
      ['.rst', 'rst', 'reStructuredText'],
      ['.rest', 'rst', 'reStructuredText'],
      ['.scm', 'scheme', 'Scheme'],
      ['.st', 'smalltalk', 'Smalltalk'],
      ['.tpl', 'smarty', 'Smarty'],
      ['.S', 'splus', 'S'],
      ['.R', 'splus', 'S'],
      ['.sql', 'sql', 'SQL'],
      ['.tcl', 'tcl', 'Tcl'],
      ['.tcsh', 'tcsh', 'Tcsh'],
      ['.csh', 'tcsh', 'Tcsh'],
      ['.aux', 'tex', 'TeX'],
      ['.toc', 'tex', 'TeX'],
      ['.tex', 'tex', 'TeX'],
      ['.txt', 'text', 'Text only'],
      ['.vb', 'vb.net', 'VB.net'],
      ['.bas', 'vb.net', 'VB.net'],
      ['.vim', 'vim', 'VimL'],
      ['.xsl', 'xml', 'XML'],
      ['.rss', 'xml', 'XML'],
      ['.xslt', 'xml', 'XML'],
      ['.xsd', 'xml', 'XML'],
      ['.wsdl', 'xml', 'XML'],
      ['.xml', 'xml', 'XML'],
      ['.xsl', 'xslt', 'XSLT'],
      ['.xslt', 'xslt', 'XSLT'],
    ]
  end

  def initialize(target, lexer = :text, format = :html)
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    @options = { :l => lexer, :f => format }
  end

  def execute(command)
    out = nil
    open4(command) do |pid, stdin, stdout, stderr|
      stdin.puts @target
      stdin.close
      out = stdout.read.strip
    end
    out
  end

  def colorize(options = {})
    execute @@bin + convert_options(options) + ' -O encoding=utf-8'
  end
  alias_method :to_s, :colorize

  def convert_options(options = {})
    @options.merge(options).inject('') do |string, (flag, value)|
      string + " -#{flag} #{value}"
    end
  end
end

if $0 == __FILE__
  require 'rubygems'
  require 'test/spec'
  require 'mocha'
  begin require 'redgreen'; rescue LoadError; end

  context "Albino" do
    setup do
      @syntaxer = Albino.new(__FILE__, :ruby)
    end

    specify "defaults to text" do
      syntaxer = Albino.new(__FILE__)
      syntaxer.expects(:execute).with('/usr/bin/pygmentize -l text -f html -O encoding=utf-8').returns(true)
      syntaxer.colorize
    end

    specify "accepts options" do
      @syntaxer.expects(:execute).with('/usr/bin/pygmentize -l ruby -f html -O encoding=utf-8').returns(true)
      @syntaxer.colorize
    end

    specify "works with strings" do
      syntaxer = Albino.new('class New; end', :ruby)
      assert_match %r(highlight), syntaxer.colorize
    end

    specify "aliases to_s" do
      assert_equal @syntaxer.colorize, @syntaxer.to_s
    end

    specify "class method colorize" do
      assert_equal @syntaxer.colorize, Albino.colorize(__FILE__, :ruby)
    end
  end
end

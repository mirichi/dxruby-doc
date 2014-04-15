require 'rouge'
require 'strscan'
require 'uri'
require 'find'
require 'fileutils'
require 'pp'

module Doxme
  
  class Doxme
    
    class IndentNode
      attr_reader :parent, :level
      attr_accessor :content, :type
      def initialize(parent, level, content)
        @parent   = parent
        @level    = level
        @content  = content
        @children = []
        @type     = nil
        
        @parent.add(self) unless @parent.nil?
        @type = :empty if @content.nil?
      end
      
      def add(node)
        @children << node
      end
      
      def children(type=nil)
        return @children if type.nil?
        @children.select { |n| n.type == type }
      end
      
      def visit(f)
        @children.each { |n| n.visit(f) } if f.call(self)
      end
      
      def indented_text(base_level=0, add_level=0)
        t = ' ' * (@level - base_level + add_level)
        t << @content if @content
        t << "\n"
        @children.each do |n|
          t << n.indented_text(base_level, add_level)
        end
        t
      end
    end
    
    attr_reader :modules, :classes, :objects, :links
    def initialize(render)
      @render  = render
    end
    
    def extract_links(text)
      t = text.gsub(/^\s*\[(\w+)\]:\s+(\S+)\s*$/m) do
        links[$1] = $2
        ''
      end
      t
    end

    def parse(dir_path)
      @modules = []
      @classes = []
      @objects = {}
      @links   = {}
      Dir.glob(File.join(dir_path, '*.doxme')).each do |path|
        begin
          _parse(path)
        rescue
          puts path
          puts $!
          exit
        end
      end
      interlink
    end

    def _parse(path)
      inherited_params  = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      inherited_options = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      
      s = StringScanner.new(extract_links(File.read(path, encoding:Encoding::UTF_8)))
      root = IndentNode.new(nil, -1, '')
      parent = root
      
      until s.eos?
        case
        when s.scan(/([ ]*)　/)
          raise "行頭インデントに全角空白が含まれています: #{path}".encode('SJIS')
        when s.scan(/([ ]*)\t/)
          raise "行頭インデントにタブが含まれています: #{path}".encode('SJIS')
        when s.scan(/([ ]*)(\S.*)\n/)
          level = s[1].size
          parent = parent.parent while parent.level >= level
          node = IndentNode.new(parent, level, s[2])
          parent = node
        when s.scan(/([ \t]*)\n/)
          IndentNode.new(parent, parent.level + 1, nil)
        end
      end
      
      tags = {
        'module'  => :module,
        'class'   => :class,
        'def'     => :method,
        'constant' => :constant,
        '@param'  => :param,
        '@note'   => :note,
        '@see'    => :link,
        '@code'   => :code,
        '@option' => :option,
        '@since' => :since,
        '@obsolete' => :obsolete,
      }
      
      r0 = /^(#{tags.keys.join('|')})[ ]+(\S.*)/
      r1 = /^(#{tags.keys.join('|')})$/
      root.visit(->(node){
        return true if node.type == :empty
        if node.content =~ r0 or node.content =~ r1
          node.type = tags[$1]
          node.content = $2
          return false if node.type == :code
        else
          raise "unknown tag: #{node.content}" if node.content =~ /^@/
          node.type = :desc
        end
        true
      })
      
      root.children.each do |n|
        case n.type
        when :module then ModuleDoc.new(nil, n, self, inherited_params, inherited_options)
        when :class  then ClassDoc.new(nil, n, self, inherited_params, inherited_options)
        end
      end
    end
    
    def add(formal_name, object)
      @objects[formal_name] = object
      @modules << object if object.class == ModuleDoc
      @classes << object if object.class == ClassDoc
    end

    def publish(output_dir, input_dir)
      target = {}
      Find.find(input_dir) do |path|
        dirname = File.dirname(path)
        next if target.key? dirname
        next if File.extname(path) != '.doxme'
        target[dirname] = dirname.sub("#{input_dir}/", '')
      end
      target.each do |input_dir, output_sub_dir|
        parse(input_dir)
        @render.publish(self, output_dir, output_sub_dir)
      end
    end

    def interlink
      # SEE ALSOを相互リンク化
      linkmap = Hash.new { |h, k| h[k] = [] }
      @objects.each do |formal_name, o|
        o.correct_linkname(@objects)
        # getter/setterを相互リンク化
        if @objects.key? "#{formal_name}="
          linkmap["#{formal_name}="] << formal_name
          linkmap[formal_name] << "#{formal_name}="
        end
        next if o.links.empty?
        linkmap[formal_name] += o.links
        o.links.each { |x| linkmap[x] << formal_name }
      end

      linkmap.each do |name, links|
        next unless @objects.key? name
        @objects[name].links = links.uniq
      end
    end
  end
  
  class ObjectDoc
    attr_reader :descs, :notes, :codes
    attr_accessor :links, :parent, :crumbs
    def initialize(parent, node, *args)
      @parent  = parent
      @descs   = node.children(:desc).map(&:content)
      @codes   = node.children(:code)
      @version = node.children(:version).map(&:content)
      @links   = node.children(:link).map(&:content)
      @notes   = []
      node.children(:note).each do |n|
        @notes += [n.content, *n.children(:desc).map(&:content)]
      end

      xs = [self]
      x = @parent
      while x
        xs << x
        x = x.parent
      end
      @crumbs = xs.reverse
    end

    def correct_linkname(objects)
      @links = @links.map do |x|
        xs = @parent ? [x, "#{@parent.formal_name}##{x}", "#{@parent.formal_name}.#{x}"] : [x]
        v = xs.find { |n| objects.key? n }
        next v if v
        puts "cannot link #{x} at SEE ALSO / #{@name}"
        x
      end
    end

    def indented_codes(indent_level=0)
      t = ''
      @codes.each do |c|
        lv = c.children[0].level
        c.children.each do |n|
          t << n.indented_text(lv, indent_level)
        end
      end
      t.strip
    end
  end
  
  class ModuleDoc < ObjectDoc
    attr_reader :formal_name, :modules, :classes, :methods, :name
    def initialize(parent, node, doc, inherited_params, inherited_options)
      super
      @document    = doc
      @name        = node.content
      @formal_name = @parent ? "#{@parent.formal_name}::#{@name}" : @name
      @document.add(@formal_name, self)
      
      @modules = node.children(:module).map { |n| ModuleDoc.new(self, n, doc, inherited_params, inherited_options) }
      @methods = node.children(:method).map { |n| MethodDoc.new(self, n, doc, inherited_params, inherited_options) }
      @classes = node.children(:class).map { |n| ClassDoc.new(self, n, doc, inherited_params, inherited_options) }
    end
  end
  
  class ClassDoc < ModuleDoc
  end
  
  
  class MethodDoc < ObjectDoc
    attr_reader :name, :return_type, :params, :unique, :formal_name, :block, :parent
    def initialize(parent, node, doc, inherited_params, inherited_options)
      raise if node.type != :method
      super
      begin
        r = /([^ \(\{-]+)\s*(\(.+\))?\s*(\{[^\}]+\})?\s*(?:->)?\s*(\S.*?)?\s*$/
        @name, args, @block, @return_type = r.match(node.content).to_a.drop(1)
        
        @unique = @name =~ /^self\./
        if @unique
          @name.sub!(/self\./, '')
          @formal_name = "#{@parent.formal_name}.#{@name}"
        else
          @formal_name = "#{@parent.formal_name}##{@name}"
        end
        
        @params = ParamsDoc.new(args)
        node.children(:param).each { |n| @params.update(n, inherited_params, inherited_options) }
        
        @params.inherit(inherited_params)
        if not node.children(:option).empty?
          @params.add_automatic_param_option(node, inherited_options)
        end
        
        doc.add(@formal_name, self)
      rescue
        puts "method parsing error:#{@name}"
        puts $!
        raise
      end
    end
  end
  
  class ParamsDoc
    REGEX = /(\S+)\s+(\S+)\s+(\S.*)/
    Param = Struct.new(:name, :defval, :type, :descs, :options)
    
    def initialize(text)
      @args = parse_argument(text)
    end
    
    def parse_argument(text) # ネストした配列、ハッシュには対応しない
      args = {}
      return args unless text
      s = StringScanner.new(text.gsub(/(^\(|\)$)/, ''))
      until s.eos?
        case
        when s.scan(/([^=,]+)=/)
          a = s[1].strip
          
          case
          when s.scan(/('(?:(?:(?!\\).)?(?:(?:\\\\)*\\)'|[^'])*')(?:,|$)/)
            args[a] = { defval: s[1] }
          when s.scan(/("(?:(?:(?!\\).)?(?:(?:\\\\)*\\)"|[^"])*")(?:,|$)/)
            args[a] = { defval: s[1] }
          when s.scan(/(\[[^\]]+\])(?:,|$)/)
            args[a] = { defval: s[1] }
          when s.scan(/(\{[^\}]+\})(?:,|$)/)
            args[a] = { defval: s[1] }
          when s.scan(/([^,]+)(?:,|$)/)
            args[a] = { defval: s[1].strip }
          end
          
        when s.scan(/([^=,]+)(?:,|$)/)
          args[s[1].strip] = { defval: nil }
        else
          raise "argument-parse error: #{text}"
        end
      end
      args
    end

    def each(&block)
      @args.each { |name, hash| block.call(Param.new(name, hash[:defval], hash[:type], hash[:descs], hash[:options])) }
    end
    
    def empty?
      @args.empty?
    end

    def arguments
      return '' if @args.empty?
      "(" + @args.map { |name, v| "#{name}" + (v[:defval] ? "=#{v[:defval]}" : '') }.join(', ') + ")"
    end
    
    def update(node, inherited_params, inherited_options)
      raise if node.type != :param
      raise "malformed: #{node.content}" unless REGEX =~ node.content
      
      name, type, desc = REGEX.match(node.content).to_a.drop(1)
      raise "unknown argument: @param #{name}" unless @args.key? name
      
      @args[name][:type]  = type
      @args[name][:descs] = [desc, *node.children(:desc).map(&:content)]
      inherited_params[name][:type]  = @args[name][:type].dup
      inherited_params[name][:descs] = @args[name][:descs].dup
      add_options(name, node, inherited_options)
    end
    
    def add_automatic_param_option(node, inherited_options)
      # Hashオブジェクトをデフォルト引数にするParamが唯一であるかを確認する
      xs = @args.map.select { |name, v| v[:defval] =~ /^\{.*\}$/ }
      raise "There are multiple Hash params" if xs.size > 1
      add_options(xs[0][0], node, inherited_options)
    end
    
    def add_options(name, node, inherited_options)
      @args[name][:options] = node.children(:option).map { |n| OptionDoc.new(n, inherited_options) }
    end
    
    def inherit(params)
      @args.each do |name, v|
        next if @args[name].key? :type
        raise "cannot find param-name in inherited_params: #{name}" unless params.key? name
        v[:type]  = params[name][:type]
        v[:descs] = params[name][:descs]
        v[:options] = [] 
      end
    end
  end
  
  class OptionDoc
    attr_reader :name, :type, :defval, :descs
    def initialize(node, inherited_options)
      raise if node.type != :option
      case node.content
      when /^(\S+)\s+(\S+)\s+(\S+)\s+(\S.*)$/
        @name   = $1
        @type   = $2
        @defval = $3
        @descs  = [$4, *node.children(:desc).map(&:content)]
        inherited_options[$1] = { name:@name, type:@type, defval:@defval, descs:@descs.dup }
      when /^(\S+)\s*$/
        @name   = $1
        raise "unknown option: #{@name}" unless inherited_options.key? @name
        @type   = inherited_options[@name][:type].dup
        @defval = inherited_options[@name][:defval].dup
        @descs  = inherited_options[@name][:descs].dup
      else
        raise "malformed: #{node.content}"
      end
    end
  end


  class HTMLRender
    TEMPLATE_ARTCILE = 'template.article.doxme'
    TEMPLATE_INDEX   = 'template.index.doxme'

    def initialize(template_dir)
      @template_article = File.read(File.join(template_dir, TEMPLATE_ARTCILE), encoding:Encoding::UTF_8)
      @template_index = File.read(File.join(template_dir, TEMPLATE_INDEX), encoding:Encoding::UTF_8)
      @css_files = Dir.glob(File.join(template_dir, '*.css'))
      @css_names = @css_files.map { |x| File.basename(x) }
      
      @formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight')
      @lexer = Rouge::Lexers::Shell.new
    end
    
    def link_name(obj)
      URI.encode_www_form_component(obj.formal_name).gsub(/[%\.:]/, '_') + '.html'
    end


    def embed_links(doc)
      f = ->(x){ x.descs.map! { |t| doc.links.each { |w, uri| t.gsub!(/\[(.+?)\]\[#{w}\]/) { "<a href='#{uri}'>#{$1}</a>" } }; t } }

      os = doc.objects
      os.each do |name, x|
        if not x.links.empty?
          x.links.map! { |v| os.key?(v) ? "<a href='#{link_name(os[v])}'>#{v}</a>" : v }
        end
        if not x.crumbs.empty?
          x.crumbs.map! { |v| "<a href='#{link_name(v)}'>#{v.name}</a>" }
        end
        f.call(x)
        if x.class == MethodDoc
          x.params.each do |param|
            f.call(param)
            param.options.each do |opt|
              f.call(opt)
            end
          end
        end
      end
    end
    
    def write(output_dir, name, text)
      FileUtils.mkdir_p(output_dir)
      open(File.join(output_dir, name), 'w') { |f| f.write text }
    end

    def generate_index(methods, header)
      return '' if methods.empty?
      <<-EOS
<h2>#{header}</h2>
<dl>
#{methods.map{ |m| "<dt><a href='#{link_name(m)}'>#{m.name}</a></dt><dd>#{m.descs[0]}</dd>" }.join}
</dl>
EOS
    end

    def generate_crumbs(obj)
      "<section class='crumbs'><a href='index.html'>INDEX</a> &gt; #{obj.crumbs.join(' &gt; ')}</section>"
    end

    def generate_note(obj)
      return '' if obj.notes.empty?
      t = <<-EOS
<div class='note'>
<strong>Note:</strong>
#{obj.notes.join('<br />')}
</div>
EOS
    end

    def generate_link(obj)
      return '' if obj.links.empty?
      links = obj.links.map { |x| "<li>#{x}</li>" }.join
      t = <<-EOS
<h2>See Also</h2>
<ul>#{links}</ul>
EOS
    end

    def generate_example(obj)
      return '' if obj.codes.empty?
      c = @formatter.format(@lexer.lex(obj.indented_codes(0)))
      t = <<EOS
<h2>Example</h2>
#{c}
EOS
    end

    def generate_parameters(obj)
      return '' if obj.params.empty?
      t = '<h2>Parameters</h2>'
      t << '<dl>'
      obj.params.each do |param|
        t << <<-EOS
<dt><code>#{param.name} <span class="type">#{param.type}</span></code></dt>
<dd>#{param.descs.join("<br />")}</dd>
#{generate_options(param.options)}
EOS
      end
      t << '</dl>'
      t
    end

    def generate_options(obj)
      return '' if obj.empty?
      t = '<dd><dl>'
      obj.each do |opt|
        t << <<-EOS
<dt><code>#{opt.name} <span class="type">#{opt.type}</span> <span class="defval">(default: #{opt.defval})</span></code></dt>
<dd>#{opt.descs.join('<br />')}</dd>
EOS
      end
      t << '</dl></dd>'
      t
    end

    def generate_return_type(obj)
      return '' unless obj.return_type
      <<-EOS
<h2>Returns</h2>
<p>#{obj.return_type}</p>
EOS
    end

    def generate_module(obj)
      <<-EOS
<div class="box">

<section id="content">
#{generate_crumbs(obj)}
<h1>module #{obj.name}</h1>
<h2>Description</h2>
<p>#{obj.descs.join('<br />')}</p>
#{generate_note(obj)}
#{generate_example(obj)}
#{generate_link(obj)}

#{generate_index(obj.methods, 'Module Methods')}
</section>

#{generate_method_index(obj)}

</div>
EOS
    end

    def generate_class(obj)
      class_methods, instance_methods = obj.methods.partition(&:unique)
      <<-EOS
<div class="box">

<section id="content">
#{generate_crumbs(obj)}
<h1>class #{obj.name}</h1>
<h2>Description</h2>
<p>#{obj.descs.join("<br />")}</p>

#{generate_index(class_methods, 'Class Methods')}

#{generate_index(instance_methods, 'Instance Methods')}
</section>

#{generate_method_index(obj)}

</div>
EOS
    end

    def generate_method_index(obj)
      x = obj.class == MethodDoc ? obj.parent : obj
      methods = x.methods.map { |m| m == obj ? "<li>#{m.name}</li>" : "<li><a href='#{link_name(m)}'>#{m.name}</a></li>" }.join

      t = <<-EOS
<section id="navi">
<span class="title">Method Index</span>
<ul>
  <li><strong><a href="#{link_name(x)}">#{x.name}</a></strong></li>
  <li>
    <ul>
    #{methods}
    </ul>
  </li>
</ul>
</section>
EOS
    end

    def generate_method(obj)
      t = <<-EOS
<div class="box">

<section id="content">
#{generate_crumbs(obj)}
<h1>#{obj.formal_name}#{obj.params.arguments}#{obj.block}</h1>

<h2>Description</h2>
<p>#{obj.descs.join("<br />")}</p>
#{generate_parameters(obj)}
#{generate_return_type(obj)}

#{generate_note(obj)}
#{generate_example(obj)}
#{generate_link(obj)}
</section>

#{generate_method_index(obj)}

</div>
EOS
    end

    def generate_root_index(doc, sub_dir_level)
      base = '../' * sub_dir_level
      css = @css_names.map { |x| "<link rel='stylesheet' type='text/css' href='#{base}#{x}' />" }.join("\n")
      gen_index_module = ->(x) { "<dt><a href='#{link_name(x)}'>module #{x.formal_name}</a></dt><dd>#{x.descs[0]}</dd>" }
      gen_index_class  = ->(x) { "<dt><a href='#{link_name(x)}'>class #{x.formal_name}</a></dt><dd>#{x.descs[0]}</dd>" }
      t =<<-EOS
<section id="content">
<h1>API INDEX</h1>
<dl>
#{doc.modules.map{ |x| gen_index_module.call(x) }.join}
#{doc.classes.map{ |x| gen_index_class.call(x) }.join}
</dl>
</section>
EOS
      @template_index.sub('$$$CONTENT$$$', t).sub('$$$CSS$$$', css)
    end


    def generate_article(obj, generator, sub_dir_level)
      base = '../' * sub_dir_level
      css = @css_names.map { |x| "<link rel='stylesheet' type='text/css' href='#{base}#{x}' />" }.join("\n")
      t = @template_article.dup
      {
        '$$$CONTENT$$$' => send(generator, obj),
        '$$$TITLE$$$' => obj.formal_name,
        '$$$CSS$$$' => css,
      }.each { |w, v| t.sub!(w, v) }
      t
    end
    
    def publish(doc, output_dir, sub_dir)
      embed_links(doc)
      n = sub_dir == '' ? 0 : (sub_dir.gsub('\\', '/').count('/') + 1)
      FileUtils.copy(@css_files, output_dir)
      output_dir = File.join(output_dir, sub_dir)

      doc.modules.each do |x|
        write(output_dir, link_name(x), generate_article(x, :generate_module, n))
        x.methods.each do |m|
          write(output_dir, link_name(m), generate_article(m, :generate_method, n))
        end
      end

      doc.classes.each do |x|
        write(output_dir, link_name(x), generate_article(x, :generate_class, n))
        x.methods.each do |m|
          write(output_dir, link_name(m), generate_article(m, :generate_method, n))
        end
      end

      write(output_dir, 'index.html', generate_root_index(doc, n))
    end
  end

end




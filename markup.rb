require 'find'
require 'fileutils'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'


class Markup

  class DXRubyDocRender < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  INDEX_ANCHOR_PREFIX = 'AUTOINDEXANCHOR_'

  def initialize(template_dir)
    render = DXRubyDocRender.new(hard_wrap:true)
    @markdown = Redcarpet::Markdown.new(render,
      fenced_code_blocks: true,
      tables: true,
      autolink: true,
      space_after_headers: true,
      no_intra_emphasis: true,
      )
    @template_article = File.read(File.join(template_dir, 'template.article.html'))
    @template_article.freeze
    @css = Dir.glob(File.join(template_dir, '*.css'))
  end

  def publish(output_dir, input_dir, option={})
    target = {}
    top_link_path = ''
    top_link_dir = ''
    Find.find(input_dir) do |path|
      next if File.extname(path) != '.md'
      target[path] = path.sub("#{input_dir}/", '').sub(/\.md$/, '.html')
      if File.basename(path) == option[:top_link]
        option[:top_link_original_path] = path
        top_link_dir = File.dirname(path)
      end
    end
    option[:top_link].sub!(/\.md$/, '.html')

    target.each do |path, output_name|
      FileUtils.mkdir_p(File.join(output_dir, File.dirname(output_name)))
      open(File.join(output_dir, output_name), 'w') do |f|
        option[:top_link_level] = path.sub("#{top_link_dir}/", '').count('/')
        f.write convert(path, output_name.count('/'), option)
      end
    end
    FileUtils.copy(@css, output_dir)
  end

  def convert(path, dir_level, auto_index:true, top_link_level:'', top_link:'', top_link_original_path:'')
    markdown = File.read(path, encoding:Encoding::UTF_8)
    markdown = insert_index(markdown) if auto_index
    html = @template_article.dup
    level = '../' * dir_level
    css = @css.map { |x| "<link rel='stylesheet' type='text/css' href='#{level}#{File.basename(x)}' />" }.join("\n")
    top_link_tag = path == top_link_original_path ? '' : "<a href='#{'../' * top_link_level}#{top_link}'>TOPへ戻る</a>"

    title = $1 if markdown =~ /^#+ (\S.*)\n/
    {
      '$$$CONTENT$$$' => @markdown.render(markdown),
      '$$$TITLE$$$' => title,
      '$$$CSS$$$' => css,
      '$$$TOP_LINK$$$' => top_link_tag,
      /href="(.*?)\.md"/ => 'href="\1.html"',
    }.each { |k, v| html.gsub!(k, v) }
    html
  end

  def insert_index(text)
    min_level = 100
    index = []
    code_block = false
    lines = []
    line_num = -1
    text.lines.each do |line|
      if line =~ /^```/
        code_block = !code_block
      elsif code_block
        
      elsif line =~ /^(##+)\s+(\S.*)$/
        lv = $1.size
        line_num = lines.size if line_num < 0
        anchor = "#{INDEX_ANCHOR_PREFIX}#{index.size}"
        index << {level:lv, content:$2, anchor:anchor}
        min_level = lv if lv < min_level
        lines << "<a name='#{anchor}'></a>\n"
      end
      lines << line
    end
    return lines.join if line_num < 0

    t = "## 目次\n"
    index.each do |head|
      t << '  ' * (head[:level] - min_level) + "1. [#{head[:content]}](##{head[:anchor]})\n"
    end
    lines.insert(line_num, "#{t}\n\n----\n\n")
    lines.join
  end
end



require './doxme'
require './markup'

def copy_misc(output_dir, input_dir)
  target = {}
  Find.find(input_dir) do |path|
    ext = File.extname(path)
    next if ext == '.md' or ext == '.doxme'
    next if Dir.exist? path
    target[path] = path.sub("#{input_dir}/", '')
  end

  target.each do |path, output_name|
    FileUtils.mkdir_p(File.join(output_dir, File.dirname(output_name)))
    FileUtils.copy(path, File.join(output_dir, output_name))
  end
end


def make_dxruby_doc(output_dir, template_dir, input_dir)
  m = Markup.new(template_dir)
  m.publish(output_dir, input_dir, top_link:'README.md', auto_index:true)

  d = Doxme::Doxme.new(Doxme::HTMLRender.new(template_dir))
  d.publish(output_dir, input_dir)

  copy_misc(output_dir, input_dir)
end

output_dir = ARGV.size > 0 ? ARGV.first : 'html'
make_dxruby_doc(output_dir, 'template', 'source')




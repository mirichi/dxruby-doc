require './doxme'
require './markup'

def make_dxruby_doc(output_dir, template_dir, input_dir)
  m = Markup.new(template_dir)
  m.publish(output_dir, input_dir, top_link:'README.md', auto_index:true)

  d = Doxme::Doxme.new(Doxme::HTMLRender.new(template_dir))
  d.publish(output_dir, input_dir)
end

output_dir = ARGV.size > 0 ? ARGV.first : 'html'
make_dxruby_doc(output_dir, 'template', 'source')




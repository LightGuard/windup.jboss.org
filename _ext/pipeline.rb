require File.join File.dirname(__FILE__), 'documentation'

Awestruct::Extensions::Pipeline.new do
  # extension Awestruct::Extensions::Posts.new( '/news' ) 
  # extension Awestruct::Extensions::Indexifier.new
  extension JBoss::Windup::Awestruct::Extensions::Documentation.new('/windup.wiki', '.md')
end


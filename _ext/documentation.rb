require 'nokogiri'

# Extension to import docs from github wiki and render as a single page with TOC
module JBoss
  module Windup
    module Awestruct
      module Extensions
        class Documentation 

          def initialize(path_prefix, suffix, opts = {})
            @path_prefix = path_prefix
            @suffix = suffix
          end

          def execute(site)
            sections = []
            toc = []
            ids = []
            site.pages.each do |page|
              if ( page.relative_source_path =~ /^#{@path_prefix}\/([0-9]\.[0-9])(.*)#{@suffix}$/ ) 
                number = $1
                name = $2
                id = number.gsub(/\./, '-') + name.gsub(/\?/,'')
                ids << id
                title = name.gsub(/-/, ' ').strip
                subsection = number.gsub(/\.0/, ' ') == number
                content =  Nokogiri::HTML(page.content)
                relative_path_prefix = @path_prefix[1, @path_prefix.length]
                content.css('img').each do |img|
                  if relative? img['src']
                    img['src'] = "#{relative_path_prefix}/#{img['src']}"
                  end
                end
                content.css('a').each do |a|
                  if relative? a['href']
                    a['href'] = "##{a['href']}"
                  end
                end
               
                if subsection
                  toc.last.children << OpenStruct.new({
                    :text=>"#{number} #{title}",
                    :link_id=>id,
                    :subsection=>true
                  })
                else
                  toc << OpenStruct.new({
                    :text=>"#{number} #{title}",
                    :link_id=>id,
                    :subsection=>false,
                    :children=>[]
                  })
                end

                content.css('h2').each do |header_html|
                  sub_id = header_html.inner_html.gsub(/ /, '-').gsub(/\?/,'').gsub(/\./, '-').gsub(/\!/, '').gsub(/:/, '-')
                  toc.last.children << OpenStruct.new({
                    :text=>header_html.inner_html,
                    :link_id=>sub_id,
                    :subsection=>true
                  })
                  header_html.inner_html = "<a id=\"#{sub_id}\">#{header_html.inner_html}</a>"
                  ids << sub_id
                end

                sections << OpenStruct.new({
                  :content=>content,
                  :number=>number.gsub(/\.0/, ' '),
                  :subsection=>subsection,
                  :id=>id,
                  :title=>title
                })
              end
            end
            site.documentation = OpenStruct.new({
              :sections=>sections,
              :toc=>toc,
              :ids=>ids
            })
          end

          def relative?(url)
            not url.match(/^[a-z]+:[\/]{2}/)
          end
        end
      end
    end
  end
end

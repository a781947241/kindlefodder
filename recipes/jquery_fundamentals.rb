require 'kindlefodder'

class JqueryFundamentals < Kindlefodder
  

  def get_source_files
    sections = extract_sections
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

  def document 
    {
      'title' => 'jQuery Fundamentals',
      'author' => 'Murphey, Rebecca',
      'cover' => nil,
      'masthead' => nil
    }
  end

  def extract_sections
    url = 'http://jqfundamentals.com/'
    html = `curl -Ls #{url}`
    doc = Nokogiri::HTML  html

    # fixups
    tighten_pre doc 
    tighten_lists doc

    [frontmatter(doc)] + doc.search('.chapter').map {|chapter|
      chapter_title = chapter['title']
      {
        title: chapter_title,
        articles: chapter.search('.section').map {|section|
          title = section['title']
          content = section.inner_html
          path = "#{chapter_title}.#{title}".downcase.gsub(/\W/, '_')
          File.open("#{output_dir}/#{path}", 'w') {|f| f.puts content}

          {
            title: section['title'],
            path: path
          }

        }
      }
    }
  end

  def frontmatter doc
    x = doc.at('#titlepage')
    content = x.inner_html
    path = "frontmatter.frontmatter"
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts content}
    article = { 
      title: x.at("h1.title").inner_text.strip,
      path: path
    }

    {
      title: "Frontmatter",
      articles: [ article ]
    }
  end

 
end

JqueryFundamentals.generate


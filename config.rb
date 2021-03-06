###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end
#

class PadrinoRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language || :ruby)
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, hard_wrap: true, tables: true, fenced_code_blocks: true, autolink: true, strikethrough: true,
               lax_html_blocks: true, space_after_headers: true, no_intra_emphasis: true, with_toc_data: true, renderer: PadrinoRenderer.new


MENU_TITLES = {
  code: "https://github.com/padrino/padrino-framework",
  blog: "/blog",
  guides: "/guides",
  api: "/api",
  contribute: nil,
  why: nil,
  changes: nil,
  team: nil
}

helpers do
  def toc(path)
    Redcarpet::Markdown.new(toc_renderer).render(File.read(path).gsub(/---\n.+?---/m, ""))
  end

  def toc_renderer
    @toc_renderer ||= Redcarpet::Render::HTML_TOC
  end

  def menu_titles
    MENU_TITLES
  end

  def page_numbers(page_number, num_pages)
    @page_numbers = (page_number - 2 .. page_number + 2).select{|i| i > 0 && i <= num_pages}
    @page_numbers.unshift(1)         if @page_numbers.first == 2
    @page_numbers.unshift(1, 0)      if @page_numbers.first > 2
    @page_numbers.push(0, num_pages) if @page_numbers.last < num_pages - 1
    @page_numbers.push(num_pages)    if @page_numbers.last == num_pages - 1
    @page_numbers
  end
end

activate :directory_indexes

activate :sprockets

sprockets.append_path "/source/fonts/"

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  activate :bourbon

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.branch = "gh-pages"
  deploy.build_before = true
end

page "/guides/*",  layout: :layout
page "/pages/*",   layout: :document_layout

proxy "/index.html", "/posts/padrino-0-10-0-routing-upgrades-rbx-and-jruby-support-and-minor-breaking-changes.html", layout: :layout
proxy "/guides/index.html", "/guides/home.html", layout: :layout
proxy "/blog/index.html", "/pages/blog.html", layout: :layout

activate :blog do |blog|
  blog.permalink          = "/blog/:title"
  blog.sources            = "/posts/:title.html"
  blog.layout             = "document_layout"
  blog.summary_separator  = /<break>/
  blog.summary_length     = nil
  blog.paginate           = true
  blog.per_page           = 10
  blog.page_link          = "page/:num"
end

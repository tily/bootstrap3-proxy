require 'open-uri'
require 'kconv'
Bundler.require

class Bootstrap3Proxy
	def initialize(url)
		@url = url
	end

	def response
		html = open(@url, 'r:binary').read
		@doc = Nokogiri::HTML(html.toutf8, nil, 'utf-8')
		make_links_absolute
		set_charset_to_utf8
		add_class_to_buttons
		add_class_to_tables
		add_class_to_uls
		link_bootstrap
		append_to_container
		@doc.to_s
	end

	def link_bootstrap
		head = @doc.xpath('//head').first
		link = Nokogiri::XML::Node.new("link", @doc)
		link['rel'] = 'stylesheet'
		link['href'] = '/bootstrap.min.css'
		head.add_next_sibling(link)
	end

	# http://blog.biasedwalk.com/2014/03/making-relative-links-absolute-with.html
	def make_links_absolute
		tags = {
			'img' => 'src',
			'script' => 'src',
			'a' => 'href',
			'link' => 'href',
			'table' => 'background'
		}
		@doc.search(tags.keys.join(',')).each do |node|
			url_param = tags[node.name]
			src = node[url_param]
			if src
				next if src.match(/^https?:/)
				begin
					if src.match(/^[^\/]/)
						path = File.dirname URI.parse(@url).path
						src = File.join(path, src)
					end
					path = URI.parse(src).path
					uri = URI.parse(path)
					uri.scheme = URI.parse(@url).scheme
					uri.host = URI.parse(@url).host
					node[url_param] = uri.to_s
				rescue URI::InvalidURIError => e
				end
			end
		end
	end

	def set_charset_to_utf8
		meta = @doc.xpath('//meta[@http-equiv="Content-Type"]').first
		meta['content'] = meta['content'].gsub(/(charset\=)(.+)/) { "#{$1}utf-8" }
	end

	def add_class_to_buttons
		xpaths = ['//button', '//input[@type="submit"]']
		xpaths.each do |xpath|
			@doc.xpath(xpath).each do |button|
				button['class'] ||= ''
				button['class'] += ' btn btn-default'
			end
		end
	end

	def add_class_to_tables
		@doc.xpath('//table').each do |button|
			button['class'] ||= ''
			button['class'] += ' table'
		end
	end

	def add_class_to_uls
		@doc.xpath('//ul').each do |ul|
			ul['class'] ||= ''
			ul['class'] += ' list-group'
			ul.xpath('//li').each do |li|
				li['class'] ||= ''
				li['class'] += ' list-group-item'
			end
		end
	end

	def append_to_container
		body = @doc.xpath('//body').first
		div = Nokogiri::XML::Node.new("div", @doc)
		div['class'] = 'container'
		div << body.children.dup
		body.children.remove
		body << div
	end
end

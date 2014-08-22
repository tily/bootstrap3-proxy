require 'open-uri'
require './lib/bootstrap3_proxy.rb'
Bundler.require

enable :inline_templates
set :public_folder, 'public'

get '/' do
	haml :'/'
end

get '/response' do
	Bootstrap3Proxy.new(params[:url]).response
end

__END__
@@ /
!!! 5
%html
	%head
		%title
			bootstrap3 proxy
			- if params[:url]
				= ":"
				= params[:url]
		%link{rel:'stylesheet',href:'/bootstrap.min.css'}
		:css
			.jumbotron { background-color: white }
			html, body { height: 100% }
			#header { height: 5%; padding-top: 0.5em; }
			iframe#response { width: 100%; height: 95% }
	%body
		- if params[:url]
			%div.container#header
				%a{href:'/'}
					%strong bootstrap3 proxy
				= ":"
				%a{href:params[:url]}= params[:url]
			%iframe#response{src:"/response?url=#{params[:url]}"}
		- else
			%div.jumbotron.text-center
				%h1 bootstrap3 proxy
				%form.form-inline{method:'GET',action:'/'}
					%div.form-group
						%label.control-label URL
					%input.form-control{type:'text',name:'url'}
					%div.form-group
						%button.btn.btn-default go

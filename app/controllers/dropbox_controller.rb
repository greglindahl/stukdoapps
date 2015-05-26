require "net/http"
require "json"
require "pp"

class DropboxController < ApplicationController
	
	def oauth
		key = params.fetch('element')
		redirect_to_oauth_provider(key)
	end

	def provision
		state = params.fetch('state')
		code = params.fetch('code')
		provision_oauth_element(state, code)
	end

	private

	def get_data(state, code)
		{
			"element": {
				"key": state
			},
			"providerData": {
				"code": code
			},
			"configuration": {
				"oauth.callback.url": "http://localhost:3000/login",
				"oauth.api.key": ENV["#{state.upcase}_API_KEY"],
				"oauth.api.secret": ENV["#{state.upcase}_API_SECRET"]
			},
			"tags": ["Ruby"],
			"name": "Ruby Test"
		}
	end


	def provision_oauth_element(state, code)
		uri = URI.parse("https://api.cloud-elements.com/elements/api-v2/instances")
		data = JSON.generate(get_data(state, code))
		p "*" * 80
		p data
		p "*" * 80
		request = Net::HTTP::Post.new(uri)
		request.body = data
		request['Content-Type'] = 'application/json'
		request['Authorization'] = "User #{ENV['CLOUD_ELEMENTS_USER_SECRET']}, Organization #{ENV['CLOUD_ELEMENTS_ORG_SECRET']}"
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true		
		response = http.request(request)
		@body = response.body
	end

	def redirect_to_oauth_provider(element_key)
		uri = URI.parse("https://api.cloud-elements.com/elements/api-v2/elements/#{element_key}/oauth/url")
		args = { :apiKey => ENV["#{element_key.upcase}_API_KEY"], :apiSecret => ENV["#{element_key.upcase}_API_SECRET"], :callbackUrl => "http://localhost:3000/login" }
		uri.query = URI.encode_www_form(args)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		request = Net::HTTP::Get.new(uri.request_uri)

		response = http.request(request)
		response_body = JSON.parse(response.body)
		oauthUrl = response_body.fetch("oauthUrl")
		redirect_to oauthUrl
	end
end
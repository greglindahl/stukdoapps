module CloudElements

	BASE_URL = "https://console.cloud-elements.com"

	class Base

		def configure
			user_secret = ENV['CLOUD_ELEMENTS_USER_SECRET']
			org_secret = ENV['CLOUD_ELEMENTS_ORG_SECRET']
			if user_secret.nil? || org_secret.nil?
				# throw an error
			end
		end

	end

	class GoogleDrive	

	end


	class Salesforce
	end


end
module DynamicFormsEngine
	class FormEntryMailer < ActionMailer::Base
		default from: 'applications@sfrent.net'

		def email_entry(form_entry)
	  		@form_entry = form_entry
	  		if Rails.env.development?
	  			@domain_name = "http://localhost:3000"
	  		else
	  			@domain_name = "https://tenant-application.herokuapp.com"
	  		end
	  		mail(to: "#{form_entry.user.email}", subject: form_entry.in_progress ? 'Your Applicaton has been saved' : 'Your Application has been submitted')
	  	end

	end
end

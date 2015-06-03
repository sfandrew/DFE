module DynamicFormsEngine
	class FormEntryMailer < ActionMailer::Base
		default from: 'andrew@sfrent.net'


		def email_entry(form_entry)
	  		@form_entry = form_entry
	  		mail(to: 'andrew@sfrent.net', subject: 'Is this working?')
	  	end

	end
end

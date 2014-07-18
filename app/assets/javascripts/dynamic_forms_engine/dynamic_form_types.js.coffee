init_autocomplete = ($element) -> 
    console.log $element
    auto_complete_source = $('.name-search').data('autocomplete-source')
    $element.autocomplete
            change: (event,ui) -> 
                
                name_search = $(this).val()

                # alert email 
                contacts = $element.data('contacts')
                # console.log contacts[name_search]
                phone =  contacts[name_search][1]
                email =  contacts[name_search][2]
                # type = contacts[name_search][0]
                # checks to see if a contact has a company
                if contacts[name_search][3]?
                    company = contacts[name_search][3]
                else
                    company = "No company"
                if contacts[name_search][0] == "Property Manager" || contacts[name_search][0] == "Landlord" ||
                   contacts[name_search][0] == "Resident Manager" || contacts[name_search][0] == "Roommate"
                    type = contacts[name_search][0]
                else
                    type = "Other"
                # alert company
                $(this).closest("fieldset").find(".phone-field").val phone
                $(this).closest("fieldset").find(".email-field").val email
                $(this).closest("fieldset").find(".company-field").val company
                $(this).closest("fieldset").find(".type-field").val type

            source: $('.name-search').data('autocomplete-source')

ready = ->
    $( "#field_fields" ).sortable
        stop: (event, ui) ->                    # On sort drop (stop) update order
            window.updateOrder()
            return
    $( "#field_fields" ).disableSelection()     # Disable text selection inside fields
    window.updateOrder()

    init_autocomplete($('.name-search'))                        # Update order on page load
    return

# Update function
window.updateOrder = () ->
    $field_fields = $("#field_fields fieldset")
    $field_fields.each (index, element) ->
        $element = $(element)
        $element.find('h3').html(index+1)
        $element.find('.field_order').val(index)
    return

# Add and remove listeners
$(document).on 'click', 'form .remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').fadeOut()
    event.preventDefault()
    window.updateOrder()
    
# this fires event on dynamic form builder
$(document).on 'click', 'form .add_many_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    # this is adding the autocomplete feature on the workorders page
    new_row = $(this).data('fields').replace(regexp, time)
    $new_contact = $(new_row)
    init_autocomplete($new_contact.find('.name-search'))
    $('#field_fields').append($new_contact)
    $('#no_field_fields').remove()
    event.preventDefault()
    window.updateOrder()

# this fires when a user has selected a contact field on the dynamic form builder
$(document).on 'click', 'form .add_fields', (event) ->
    # ajax request to get /contacts/contact_field
    # returns an html of the contact form
    # Add it to $('#field_fields').append( html_returned )
    $.get '/apis/contact_field', (data) ->
        console.log data
        $('#field_fields').append data
        init_autocomplete($new_contact.find('.name-search'))
        window.updateOrder()
    $new_contact = $('#field_fields')
    init_autocomplete($new_contact.find('.name-search'))
    # console.log init_autocomplete
    $('#field_fields').append($new_contact)
    $('#no_field_fields').remove()
    event.preventDefault()
    window.updateOrder()

# Doc rdy
$(document).ready(ready)
# Turbo links rdy (http://stackoverflow.com/questions/18770517/rails-4-how-to-use-document-ready-with-turbo-links)
$(document).on('page:load', ready)
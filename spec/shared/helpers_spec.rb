def console_user
	sign_in user, no_capybara: true
end

def www_user
	sign_in user
end


def console_admin
	sign_in admin, no_capybara: true
end

def www_admin
	sign_in admin
end

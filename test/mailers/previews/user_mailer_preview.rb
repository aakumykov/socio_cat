class UserMailerPreview < ActionMailer::Preview
  def welcome_message
    UserMailer.welcome_message(User.last)
  end

  def reset_message
    UserMailer.reset_message(
    	user:User.last, 
    	reset_code: User.new_remember_token, 
    	date: Time.now
    )
  end
end
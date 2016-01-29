class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.welcome_email(User.last)
  end

  def reset_email
    UserMailer.reset_email(
    	user:User.last, 
    	reset_code: User.new_remember_token, 
    	date: Time.now
    )
  end
end
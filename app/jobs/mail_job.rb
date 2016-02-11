class MailJob < ActiveJob::Base
  queue_as :email

  def perform(user)
    UserMailer.welcome_message(user).deliver_now
  end
end

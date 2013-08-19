class WeddingMailer < ActionMailer::Base
  default from: "wesleysee@gmail.com"

  def contact_us(email, subject, body)
    mail(:to => email, :subject => subject, :body => body)
  end
end

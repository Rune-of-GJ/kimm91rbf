class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("GMAIL_USERNAME", "noreply@speakflow.kro.kr")
  layout "mailer"
end

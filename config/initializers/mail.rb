ActionMailer::Base.smtp_settings = {
  :address => "server",
  :port    => 25,
  :domain => "server",
  :authentication => nil,
}

# base64 encodings - useful for manual SMTP testing:
# username => dXNlcm5hbWU=

# password => cGFzc3dvcmQ=

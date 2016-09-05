if Application.config.env.development?
  APNS.host = 'gateway.sandbox.push.apple.com'
else
  APNS.host = 'gateway.push.apple.com'
end

APNS.port = 2195
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

APNS.pem  = ENV['APNS_PEM_PATH']
# this is the file you just created

APNS.pass = ENV['APNS_PEM_PASS']
# Just in case your pem need a password

GCM.key = ENV['GCM_KEY']

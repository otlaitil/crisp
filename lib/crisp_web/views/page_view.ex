defmodule CrispWeb.PageView do
  use CrispWeb, :view

  def otp_enrollment_url() do
    secret = "FJNOZXKTF56FTX3UEDYD7RZ5NX5EBTUQXBSSLGDM4OXKHCLTLOJQ===="
    # token = :pot.topt(secret)
    email = "jouni.img@gmail.com"

    "otpauth://totp/TOTP%20Example:#{email}?secret=#{secret}&issuer=Crisp&algorithm=SHA1&digits=6&period=30"
  end
end

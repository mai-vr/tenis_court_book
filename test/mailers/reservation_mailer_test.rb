require "test_helper"

class ReservationMailerTest < ActionMailer::TestCase
test "confirmation_email" do
  reservation = reservations(:one)
  email = ReservationMailer.confirmation_email(reservation)

  assert_emails 1 do
    email.deliver_now
  end
  assert_equal [ reservation.user.email_address ], email.to
end
end

require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reservation = reservations(:one)
    @club = @reservation.court.club
    sign_in_as(users(:admin))
  end

  test "should get new" do
    get new_admin_club_reservation_payment_url(@club, @reservation)

    assert_response :success
  end

  test "should get create" do
    post admin_club_reservation_payments_url(@club, @reservation),
      params: {
        payment: {
          payment_method: "cash"
        }
      }

    assert_response :redirect
  end
end

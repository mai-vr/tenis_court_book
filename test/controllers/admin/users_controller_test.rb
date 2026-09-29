require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
  @admin = User.create!(
    first_name: "Admin",
    last_name: "Test",
    email_address: "admin@test.com",
    password: "password123",
    role: :superadmin
  )
end

test "should get index" do
  sign_in_as(@admin)
  get admin_users_url
  assert_response :success
end

test "should get new" do
  sign_in_as(@admin)
  get new_admin_user_url
  assert_response :success
end

test "should create user" do
  sign_in_as(@admin)
  post admin_users_url, params: {
      user: {
        first_name: "Tomas",
        last_name: "Alvarez",
        email_address: "tomas@gmail.com",
        password: "password123",
        club_id: clubs(:one).id
      }
  }
  assert_response :redirect
end
end

  require "test_helper"

  class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      first_name: "Pepe",
      last_name: "Martinez",
      email_address: "pepe@gmail.com",
      password: "pepe123",
      role: :user
    )
  end

    test "es válido con atributos correctos" do
      puts @user.errors.full_messages unless @user.valid?
      assert @user.valid?
    end

    test "normaliza el email eliminando espacios y pasándolo a minúsculas" do
      @user.email_address = "  TEST@Example.com  "
      @user.save!
      assert_equal "test@example.com", @user.email_address
    end

    test "club_admin requiere obligatoriamente tener un club asignado" do
      admin = User.new(
        first_name: "Admin",
        last_name: "Club",
        email_address: "admin@club.com",
        password: "password123",
        role: :club_admin,
        club: nil
      )
      refute admin.valid?
      assert_includes admin.errors[:club], "es obligatorio para administradores de club"
    end

    test "el método backoffice? detecta administradores correctamente" do
      assert User.new(role: :superadmin).backoffice?
      assert User.new(role: :club_admin).backoffice?
      refute User.new(role: :user).backoffice?
    end
  end
class Admin::UsersController < ApplicationController
  before_action :validate_superadmin

  def new
    @user = User.new
    @clubs = Club.order(:name) 
  end

  def create
    @user = User.new(user_params)
    @user.role = :club_admin

    if @user.save
      redirect_to admin_users_path
    else
      @clubs = Club.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @users = User.order(:email_address)
  end

  def validate_superadmin
    unless current_user&.superadmin?
      redirect_to admin_clubs_path
    end
  end

  def user_params
    params.expect(user: %i[first_name last_name email_address password password_confirmation, club_id])
  end
end

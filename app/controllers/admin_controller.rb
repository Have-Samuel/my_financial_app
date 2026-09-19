class AdminController < ApplicationController
  before_action :authenticate_admin! # Ensures that only authenticated admins can access the admin dashboard

  def index
  end
end

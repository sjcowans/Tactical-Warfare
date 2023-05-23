# frozen_string_literal: true

class AdminController < ApplicationController
  def index
    return if current_user.admin?

    render file: 'public/404.html', status: :not_found, layout: false
  end
end

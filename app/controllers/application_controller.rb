class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def record_not_found
    render file: Rails.root.join("public/404.html"),
           status: :not_found,
           layout: false
  end
end
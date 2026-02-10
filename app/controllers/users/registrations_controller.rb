# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # Set flash message when create action fails due to validation errors
  def create
    super do |resource|
      if !resource.persisted? && resource.errors.any?
        flash.now[:alert] = t('.error')
      end
    end
  end
end

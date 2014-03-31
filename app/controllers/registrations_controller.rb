class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, only: [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy]

  def create
    if Rails.env == 'test' || verify_solvemedia_puzzle
      super
    else
      build_resource(sign_up_params)
      resource.valid?
      resource.errors.add(:base, "There was a problem with the Solve Media code below. Please reenter the code.")
      clean_up_passwords(resource)
      respond_with(resource)
    end
  end
end

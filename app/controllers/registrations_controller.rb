class RegistrationsController < Devise::RegistrationsController
  def create
    p verify_solvemedia_puzzle
    if verify_solvemedia_puzzle(:error_message => 'Solve Media puzzle input is invalid')
      super
    else
      # error
    end
  end
end
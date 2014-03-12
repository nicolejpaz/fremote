class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  field :name, type: String
  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  validates_length_of :name, maximum: 16
  # attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time
  after_initialize :spawn_memberships
  has_many :remotes
  embeds_one :membership
  attr_accessor :login

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      self.any_of({ :name => /^#{Regexp.escape(login)}$/i }, { :email => /^#{Regexp.escape(login)}$/i }).first
    else
      super
    end
  end

  def add_to_membership(remote)
    unless self.membership.remote_ids.include? remote.remote_id
      self.membership.remote_ids << remote.remote_id
      self.save
    end
  end

  def delete_remote_from_user_memberships(remote)
    self.membership.remote_ids.delete(remote.remote_id)
    self.save
  end

  private
  def spawn_memberships
    self.membership = Membership.new if self.membership == nil
  end
end

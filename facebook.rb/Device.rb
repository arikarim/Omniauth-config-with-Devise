/put these gems:
 gem 'omniauth-facebook'
 gem 'omniauth'
 change devise to gem 'devise', github: 'heartcombo/devise', branch: 'ca-omniauth-2'
 gem 'omniauth-rails_csrf_protection'


2//rails g migration AddOmniauthToUsers provider:string uid:string
then rails db:migrate


3// run: `EDITOR="code --wait" bin/rails credentials:edit`
then put:
facebook:
  APP_ID: '<facebook_app_id>'
  APP_SECRET: '<facebook_app_secret>'

4//in config/initializers/devise.rb put:
config.omniauth :facebook, Rails.application.credentials.facebook[:APP_ID], Rails.application.credentials.facebook[:APP_SECRET], token_params: { parse: :json }



5//in user model put
A/devise :omniauthable, omniauth_providers: %i[facebook]
B/def self.from_omniauth(auth)
  name_split = auth.info.name.split(" ")
  user = User.where(email: auth.info.email).first
  user ||= User.create!(provider: auth.provider, uid: auth.uid, last_name: name_split[0], first_name: name_split[1], email: auth.info.email, password: Devise.friendly_token[0, 20])
    user
end


6//app/controllers/users/omniauth_callbacks_controller.rb:

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end


7//confug/routes.rb:
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

8//inside view:
<%= link_to "Register with Facebook", user_facebook_omniauth_authorize_path, method: :post %>

9//app/views/devise/shared/links at the bottom add (method: :post) to the registration link.

10// in some cases create .env file in the root and add this:
HTTPS= true


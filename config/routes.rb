Rails.application.routes.draw do
# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#home'

  devise_for :users,
             path: '',
             path_names: { sign_in: 'login',
                           sign_out: 'logout',
                           edit: 'profile',
                           sign_up: 'registration' }

  controller :users do
    get 'keytech_settings' => :edit_keytech_settings
    put 'update_keytech_settings' => :update_keytech_settings
    put 'set_keytech_demo_server' => :set_keytech_demo_server
  end

end

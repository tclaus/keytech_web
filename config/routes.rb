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

  resource :user

  get 'search' , to: 'elements#search', as: 'search_element'
  # Element Tabs, need to match with tabs provided by keytech API

  get 'element/:id/editor', to: 'elements#show_editor'
  get 'element/:id/links', to: 'elements#show_links'
  get 'element/:id/whereused', to: 'elements#show_whereused'
  get 'element/:id/notes', to: 'elements#show_notes'
  get 'element/:id/files', to: 'elements#show'
  get 'element/:id/status', to: 'elements#show'
  get 'element/:id/messages', to: 'elements#show'
  get 'element/:id/files', to: 'elements#show'

  get 'element/:id/preview', to: 'elements#preview', as: 'preview_element'
  get 'element/:id/thumbnail', to: 'elements#thumbnail', as: 'thumbnail_element'
  get 'element/:id/masterfile', to: 'elements#masterfile', as: 'masterfile_element'

  get 'element/:id', to: redirect('element/%{id}/editor'), as: 'show_element'

end

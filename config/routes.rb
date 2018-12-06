Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#home'

  devise_for :users,
             path: '',
             path_names: { sign_in: 'login',
                           sign_out: 'logout',
                           edit: 'profile',
                           sign_up: 'registration' }

  resources :users, only: %i[show destroy]
  controller :users do
    get 'keytech_settings' => :edit_keytech_settings
    put 'keytech_settings' => :update_keytech_settings
    put 'set_keytech_demo_server' => :set_keytech_demo_server
  end

  get 'dashboard', to: 'application#dashboard'

  get 'search', to: 'elements#search', as: 'search_element'
  # Element Tabs, need to match with tabs provided by keytech API
  resources :elements, only: [:destroy]
  # TODO: Show auf "Show_element" gehen lasen?

  # TODO: Hier den Controller - Trick anwenden?
  get 'element/:id/editor', to: 'elements#show_editor', as: 'show_element'
  get 'element/:id/links', to: 'elements#show_links'
  get 'element/:id/whereused', to: 'elements#show_whereused'
  get 'element/:id/notes', to: 'elements#show_notes'
  get 'element/:id/files', to: 'elements#show'
  get 'element/:id/status', to: 'elements#show_status'
  get 'element/:id/messages', to: 'elements#show_mails'
  get 'element/:id/billofmaterial', to: 'elements#show_bom'

  get 'element/:id/preview', to: 'elements#preview', as: 'preview_element'
  get 'element/:id/thumbnail', to: 'elements#thumbnail', as: 'thumbnail_element'
  get 'element/:id/masterfile', to: 'elements#masterfile', as: 'masterfile_element'

  get 'element/:id', to: redirect('element/%{id}/editor')

  # Show classlist dialog (first)
  get 'engine/new_element_class', to: 'engine#show_classes_dialog'
  get 'engine/classes', to: 'engine#show_classes'
  get 'engine/checkserver', to: 'engine#checkserver'

  # Show new note dialog
  get 'engine/new_note', to: 'engine#show_new_note_dialog'
  post 'engine/new_note', to: 'engine#create_new_note'
  delete 'engine/notes/:id', to: 'engine#delete_note'
  
  # Show element properties
  get 'engine/newelement', to: 'engine#show_new_element_dialog'
  post '/engine/newelement', to: 'engine#new_element'

  # Element Value formular
  get 'engine/value_form', to: 'engine#show_value_form'
  post 'engine/value_form', to: 'engine#update_value_form'

  post 'files', to: 'fileupload#file_upload'

  controller :admin do
    get 'admin' => :index
  end
end

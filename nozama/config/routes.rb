Nozama::Application.routes.draw do

  match '/indexbatchinventory', to: 'inventories#batch_index', via: 'get'
  match '/batchinventory', to: 'inventories#batch_inventory', via: 'get'
  match '/batchinventorydeleteone', to: 'inventories#batch_delete', via: 'get'
  match '/batchinventorydeleteall', to: 'inventories#batch_delete_all', via: 'get'
  match '/batchinventoryshow', to: 'inventories#show', via: 'get'
  match '/inventorysearch', to: 'inventories#search', via: 'get'
  match '/inventorysearchindex', to: 'inventories#search_index', via: 'get'

  match '/indexbatchsales', to: 'sales#batch_index', via: 'get'
  match '/batchsales', to: 'sales#batch_sales', via: 'get'
  match '/batchsalesdeleteone', to: 'sales#batch_delete', via: 'get'
  match '/batchsalesdeleteall', to: 'sales#batch_delete_all', via: 'get'
  match '/salessearch', to: 'sales#search', via: 'get'
  match '/salessearchindex', to: 'sales#search_index', via: 'get'
  match '/salesstatistics', to: 'sales#statistics', via: 'get'

  resources :users
  resources :inventories
  resources :sales
  resources :sessions, only: [:new, :create, :destroy]

  root 'static_pages#home'
  match '/signup', to: 'users#new', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/help', to: 'static_pages#help', via: 'get'

end

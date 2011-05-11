Qtlhighliter::Application.routes.draw do

  root :to => "pages#home"

  devise_for :users
  resources :users, :only => [:show]

  resources :ontology_terms

  resources :genes do
    collection do
      post :direct
    end
  end

  resources :qtls do
    collection do
      post :genes
      post :ontology_terms
    end
  end

  resources :gene_searches do
    collection do
      post :upload
    end
  end

  match '/graphs', :to => 'pages#graphs', :as => 'graphs'
  match '/about', :to => 'pages#about', :as => 'about'
  match '/help', :to => 'pages#help', :as => 'help'
  match '/css', :to => 'pages#css_test', :as => 'css'
  match '/downloads', :to => 'pages#downloads', :as => 'downloads'

end

Rails.application.routes.draw do
  namespace :v1 do
    resources :users, shallow: true do
      resources :sleeps do
        post "clock_in", on: :collection
      end
    end
  end
end

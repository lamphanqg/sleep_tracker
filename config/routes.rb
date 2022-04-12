Rails.application.routes.draw do
  namespace :v1, defaults: {format: "json"} do
    resources :users, shallow: true do
      member do
        post "follow"
      end

      resources :sleeps do
        post "clock_in", on: :collection
      end
    end
  end
end

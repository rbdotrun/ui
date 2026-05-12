# Engine routes. The host mounts the engine to expose them, e.g.:
#
#     # config/routes.rb in the host app
#     mount RbrunUi::Engine => "/_dev" if Rails.env.development?
#
# Routes here are dev-only by design — the showcase is for component
# authoring, not for production traffic. The controller guards on
# `Rails.env.development?` as a second line of defense in case the
# host forgets the conditional mount.
RbrunUi::Engine.routes.draw do
  # Routes resolve to controllers under `RbrunUi::Dev::*` because
  # `isolate_namespace RbrunUi` in the engine namespaces controller
  # lookup. So `dev/showcase#index` → `RbrunUi::Dev::ShowcaseController#index`.
  get "/showcase",            to: "dev/showcase#index", as: :showcase
  get "/showcase/:component", to: "dev/showcase#show",  as: :showcase_component
  post "/showcase/flash-demo/vanilla", to: "dev/flash_demos#create_vanilla", as: :flash_demo_vanilla
  post "/showcase/flash-demo/async",   to: "dev/flash_demos#create_async",   as: :flash_demo_async
end

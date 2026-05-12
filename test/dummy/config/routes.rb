Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  # Mount the engine — the showcase route lives behind here. The
  # component tests don't actually need the route table; they invoke
  # ViewComponents directly via render_inline. But mounting keeps the
  # importmap-rails sidecar test honest (it walks Rails.application.importmap).
  mount RbrunUi::Engine => "/_dev"
end

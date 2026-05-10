module RbrunUi
  # Base controller for every controller the engine ships. Exists so
  # engine routes render in the engine layout (which loads the engine's
  # importmap, its Stimulus app, its CSS) regardless of what the host
  # has set up. No host inheritance, no host helper leakage.
  class ApplicationController < ActionController::Base
    layout "rbrun_ui/application"

    # The engine doesn't ship a CSRF strategy — it's a UI library, not
    # an auth surface. Host concerns (auth, CSP, request forgery) are
    # the host's problem; engine routes only render visual swatches in
    # development.
    protect_from_forgery with: :null_session
  end
end

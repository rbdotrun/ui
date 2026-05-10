require "test_helper"

# Guards the wiring between three moving pieces:
#
#   1. Sidecar JS files at `app/components/rbrun_ui/ui/<name>/controller.js`.
#   2. The importmap pin in `config/importmap.rb`
#      (`pin_all_from "app/components/rbrun_ui/ui", under: "rbrun_ui/components/ui"`).
#   3. Propshaft's asset paths registered by `lib/rbrun_ui/engine.rb`.
#
# If any of these three drift out of alignment, importmap-rails silently
# drops the offending entry from the rendered `<script type="importmap">`
# tag (you'll see "Importmap skipped missing path: …" in the boot log)
# — Stimulus then can't import the sidecar at runtime and the component
# just doesn't open. The bug is invisible to a render-only component
# test (the markup still ships) but the page is dead.
#
# We assert against `RbrunUi.importmap` (the engine's own
# `Importmap::Map` instance), NOT `Rails.application.importmap`. The
# engine deliberately keeps its pins out of the host's importmap — see
# `lib/rbrun_ui/engine.rb` for why.
class SidecarImportmapTest < ActiveSupport::TestCase
  test "every component sidecar controller.js is registered in the engine importmap" do
    engine_root = RbrunUi::Engine.root

    components_with_sidecar = Dir[engine_root.join("app/components/rbrun_ui/ui/*/controller.js")].map do |path|
      File.basename(File.dirname(path)) # "popover", "menu", "select", …
    end.sort

    assert_not_empty components_with_sidecar,
                     "expected at least one sidecar at app/components/rbrun_ui/ui/<name>/controller.js"

    imports = JSON.parse(
      RbrunUi.importmap.to_json(resolver: ApplicationController.helpers)
    ).fetch("imports")

    components_with_sidecar.each do |name|
      module_key = "rbrun_ui/components/ui/#{name}/controller"
      asset_url  = imports[module_key]

      assert asset_url.present?,
             <<~MSG.squish
               Engine importmap is missing entry for #{module_key}
               (sidecar at app/components/rbrun_ui/ui/#{name}/controller.js).
               Likely the pin in config/importmap.rb or the asset paths
               in lib/rbrun_ui/engine.rb drifted out of alignment —
               Propshaft couldn't resolve the file and importmap-rails
               silently dropped it. Current keys:
               #{imports.keys.sort.inspect}
             MSG

      assert asset_url.start_with?("/assets/"),
             "Importmap entry for #{module_key} resolved to #{asset_url.inspect}, " \
             "expected an /assets/ URL."
    end
  end
end

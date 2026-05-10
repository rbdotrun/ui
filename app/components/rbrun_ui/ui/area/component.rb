class RbrunUi::Ui::Area::Component < RbrunUi::ApplicationViewComponent
  option(:class_name, optional: true)
  option(:body_class, optional: true)

  renders_one :header
  renders_one :footer

  def root_classes
    TailwindMerge::Merger.new.merge([
      "flex h-full min-h-0 flex-col overflow-hidden",
      class_name
    ].compact.join(" "))
  end

  def body_classes
    TailwindMerge::Merger.new.merge([
      "flex min-h-0 flex-1 flex-col overflow-y-auto px-4 py-3",
      body_class
    ].compact.join(" "))
  end

  erb_template <<~ERB
    <div class="<%= root_classes %>">
      <%= header if header? %>
      <div class="<%= body_classes %>">
        <%= content %>
      </div>
      <%= footer if footer? %>
    </div>
  ERB
end

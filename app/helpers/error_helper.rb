# frozen_string_literal: true

module ErrorHelper
  def field_error_message(resource, field)
    return unless resource.errors[field].any?

    content_tag(:p, resource.errors[field].first, class: "mt-1 text-sm text-red-700")
  end

  def field_icon_color(resource, field)
    resource.errors[field].any? ? 'text-red-400' : 'text-gray-400'
  end
end

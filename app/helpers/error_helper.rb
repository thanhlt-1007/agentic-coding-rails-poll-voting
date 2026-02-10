# frozen_string_literal: true

module ErrorHelper
  def field_error_message(resource, field)
    return unless resource.errors[field].any?

    content_tag(:p, resource.errors[field].first, class: "mt-1 text-sm text-red-700")
  end

  def field_icon_color(resource, field)
    resource.errors[field].any? ? "text-red-400" : "text-gray-400"
  end

  def field_border_classes(resource, field)
    if resource.errors[field].any?
      "border-red-500 focus:border-red-500"
    else
      "border-gray-300 focus:ring-indigo-500 focus:border-transparent focus:ring-2"
    end
  end
end

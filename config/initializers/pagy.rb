# frozen_string_literal: true

# Pagy initializer file
# Customize only what you really need and notice that the core Pagy works also without any of the following lines.

# Default items per page
Pagy::DEFAULT[:limit] = 12

# Better user experience handled automatically
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

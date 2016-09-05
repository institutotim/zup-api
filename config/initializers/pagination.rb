ApiPagination.configure do |config|
  # If you have both gems included, you can choose a paginator.
  config.paginator = :will_paginate # or :kaminari

  # By default, this is set to 'Total'
  config.total_header = 'Total'

  # By default, this is set to 'Per-Page'
  config.per_page_header = 'Per-Page'
end

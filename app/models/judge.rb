class Judge < ActiveRecord::Base
has_many :admissions

filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
        :sorted_by,
        :search_query
    ]
)

end

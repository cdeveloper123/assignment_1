ActiveAdmin.register VotingPhase do
  permit_params :budget_id, :name, :description, :start_date, :end_date, :max_votes_per_user, :position, :active, :rules

  index do
    selectable_column
    id_column
    column :budget
    column :name
    column :start_date
    column :end_date
    column :active
    column :max_votes_per_user
    column :position
    actions
  end

  filter :budget
  filter :name
  filter :active
  filter :start_date
  filter :end_date

  form do |f|
    f.inputs do
      f.input :budget
      f.input :name
      f.input :description
      f.input :start_date, as: :datetime_picker, input_html: { value: f.object.start_date&.strftime('%Y-%m-%dT%H:%M') }
      f.input :end_date, as: :datetime_picker, input_html: { value: f.object.end_date&.strftime('%Y-%m-%dT%H:%M') }
      f.input :max_votes_per_user
      f.input :position
      f.input :active
      f.input :rules
    end
    f.actions
  end
end 
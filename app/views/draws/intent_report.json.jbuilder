json.data @students.each do |student|
  json.extract! student, :id
  json.rowId "student-#{student.id}"
  json.lastName student.last_name
  json.firstName student.name
  json.intent student.intent
  # TODO: figure out proper inline form, left for posterity
  # json.intent simple_form_for(student, url: user_update_intent_path(student)) { |f| f.select :intent, { collection: User.intents.keys },  {}, { class: 'autosubmit' } }
  json.editStr link_to 'Edit', user_edit_intent_path(student)
end

def user_attributes_for(resource)
  resource.user_attributes = {
    email: "#{resource.name.parameterize}@example.com",
    password: 'password',
    password_confirmation: 'password'
  }
end

NAMES = %w(Marco Sara)

NAMES.each do |name|
  commoner = Commoner.find_or_create_by name: name
  User.find_or_create_by email: "#{commoner.name.parameterize}@example.com" do |user|
              user.password = 'password'
              user.meta_id = commoner.id
              user.meta_type = 'Commoner'
  end
  puts "#{name} created"
end

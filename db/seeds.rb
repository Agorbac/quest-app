# Создаем пользователей с информацией
users_data = [

]

users_data.each do |data|
  user = User.create!(
    name: data[:name],
    last_name: data[:last_name],
    role: data[:role]
  )
  
  UserInfo.create!(
    user: user,
    info: data[:info]
  )
end

puts " #{User.count}"
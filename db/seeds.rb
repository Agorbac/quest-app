# Создаем пользователей с информацией
users_data = [
  {
    name: "a2",
    last_name: "b2",
    role: "admin",
    info: "djlkfhgsdnjrg"
  },
  {
    name: "a3",
    last_name: "b3",
    role: "employee",
    info: "dk.gn.kdsnrgkdsrj"
  },
  {
    name: "a4",
    last_name: "b4",
    role: "player",
    info: "Оdrgnjshergn.sker"
  }
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
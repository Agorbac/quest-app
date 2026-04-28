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

admin = User.find_or_initialize_by(email: "agorbacheva874@gmail.com")
admin.name = "Главный"        
admin.last_name = "Админ"     
admin.password = "password123" 
admin.password_confirmation = "password123"
admin.role = :admin        
admin.save!

puts "Главный администратор обновлен и готов к работе!"


ActorSchedule.destroy_all

puts "Создаем актеров..."
actor1 = User.find_or_initialize_by(email: "ivan@quest.com")
actor1.update!(name: "Иван", last_name: "Грозный", password: "password123", role: :actor)

actor2 = User.find_or_initialize_by(email: "petr@quest.com")
actor2.update!(name: "Петр", last_name: "Первый", password: "password123", role: :actor)

actor3 = User.find_or_initialize_by(email: "sergey@quest.com")
actor3.update!(name: "Сергей", last_name: "Есенин", password: "password123", role: :actor)

actors = [actor1, actor2, actor3]

puts "Генерируем скользящее расписание на неделю..."
(0..6).each do |day|
   q1_actor = actors[day % 3]
  ActorSchedule.create!(user: q1_actor, quest_id: 1, day_of_week: day)

  q2_actors = actors - [q1_actor]
  q2_actors.each do |actor|
    ActorSchedule.create!(user: actor, quest_id: 2, day_of_week: day)
  end
end

puts "Актеры и расписание успешно добавлены!"
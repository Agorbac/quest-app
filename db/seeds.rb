ActorTransaction.destroy_all
Report.destroy_all
Game.destroy_all
QuestTag.destroy_all
QuestView.destroy_all
ActorSchedule.destroy_all
Quest.destroy_all
Tag.destroy_all
User.destroy_all

admin = User.new(
  email: "agorbacheva874@gmail.com",
  name: "Главный",
  last_name: "Админ",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)
admin.save!

actor_names = ["Влад", "Лена", "Денис", "Даня", "Алена", "Диана", "Лесана"]
actors = {}

actor_names.each do |name|
  email_prefix = case name
                 when "Влад" then "vlad"
                 when "Лена" then "lena"
                 when "Денис" then "denis"
                 when "Даня" then "danya"
                 when "Алена" then "alena"
                 when "Диана" then "diana"
                 when "Лесана" then "lesana"
                 end
  actors[name] = User.create!(
    email: "#{email_prefix}@quest.com",
    name: name,
    last_name: "Актер",
    password: "password123",
    role: "actor"
  )
end

quests_data = [
  { id: 1, name: "Доска дьявола", info: "Вы – участники городского квеста в жанре мистического триллера. Детский дом «Северное сияние» закрыли более сорока лет назад." },
  { id: 2, name: "Призрачная лечебница", info: "Лечебница Святой веры закрыта почти два десятилетия. Мы пришли сюда как команда журналистов." },
  { id: 3, name: "Не дыши", info: "Попытка ограбления пошла не по плану. Дом оказался ловушкой, а его хозяин – вовсе не беспомощный старик." },
  { id: 4, name: "Звонок в темноте", info: "Проклятая видеозапись казалась просто городской легендой до того момента, как экран погас и старый проводной телефон зазвонил." },
  { id: 5, name: "Заклятие. Изгнание демона", info: "Вы – частные детективы, расследующие таинственное исчезновение человека. Следы привели к зданию в центре города." },
  { id: 6, name: "Обитель порога", info: "В глубине забытых земель стоит древняя обитель – место, где границы между мирами тонки." },
  { id: 7, name: "Последняя молитва", info: "Вас встретили тепло. Спокойные лица, тихие голоса и слабый свет свечей. Здесь не торопят, не принуждают." },
  { id: 8, name: "Проклятие монахини", info: "Дверь захлопнулась за вашей спиной с глухим металлическим звуком. Вы находитесь в подвале старого монастыря." }
]

quests_data.each do |q_data|
  quest = Quest.find_or_initialize_by(id: q_data[:id])
  quest.name = q_data[:name]
  quest.info = q_data[:info]
  quest.save!
end

tags_hash = {
  1 => ["Страшные", "Для большой компании", "Антуражные", "Перформансы", "Мистические", "С контактом", "Головоломки"],
  2 => ["Страшные", "С актерами", "Для новичков", "Психлечебницы", "Расследования", "Призраки"],
  3 => ["Страшные", "Ограбления", "Экшн-игры", "Выживание", "Прятки", "Триллер"],
  4 => ["По фильмам", "Нестандартный формат", "Экшн-игры", "Выживание", "Демоны", "Ритуалы", "Прятки"],
  5 => ["Страшные", "Антуражные", "Детектив", "Перформансы", "Паранормальные явления", "Преступления", "Старинный особняк"],
  6 => ["Фэнтези", "Для детей", "Семейные", "Квесты без актеров", "Приключения", "Магия"],
  7 => ["Страшные", "Сложные", "18+", "С контактом", "Кошмары", "Ритуалы", "Головоломки"],
  8 => ["Страшные", "Антуражные", "Перформансы", "Выживание", "Монахини", "Ритуалы", "Призраки"]
}

all_tags = tags_hash.values.flatten.uniq
tag_objects = {}
all_tags.each { |tag_name| tag_objects[tag_name] = Tag.find_or_create_by!(name: tag_name) }

tags_hash.each do |quest_id, tags|
  quest = Quest.find(quest_id)
  tags.each { |tag_name| QuestTag.find_or_create_by!(quest: quest, tag: tag_objects[tag_name]) }
end

# Расписание: 0 - Вс, 1 - Пн, 2 - Вт, 3 - Ср, 4 - Чт, 5 - Пт, 6 - Сб
schedule = {
  1 => { vorosh: ["Влад"], nansen: ["Денис", "Диана"], stad: ["Алена"] },
  2 => { vorosh: ["Лена"], nansen: ["Денис", "Даня"], stad: ["Диана"] },
  3 => { vorosh: ["Лена"], nansen: ["Денис", "Влад"], stad: ["Диана"] },
  4 => { vorosh: ["Лена"], nansen: ["Даня", "Лесана"], stad: [] },
  5 => { vorosh: ["Влад"], nansen: ["Даня", "Лесана"], stad: ["Алена"] },
  6 => { vorosh: ["Лена"], nansen: ["Денис", "Диана"], stad: ["Лесана"] },
  0 => { vorosh: [], nansen: ["Алена", "Влад"], stad: ["Даня"] }
}

nansen_quests = [1, 2, 3, 4]
vorosh_quests = [5, 6]
stad_quests = [7, 8]

schedule.each do |day, locations|
  locations[:nansen].each do |actor_name|
    nansen_quests.each { |q_id| ActorSchedule.find_or_create_by!(user: actors[actor_name], quest_id: q_id, day_of_week: day) }
  end
  locations[:vorosh].each do |actor_name|
    vorosh_quests.each { |q_id| ActorSchedule.find_or_create_by!(user: actors[actor_name], quest_id: q_id, day_of_week: day) }
  end
  locations[:stad].each do |actor_name|
    stad_quests.each { |q_id| ActorSchedule.find_or_create_by!(user: actors[actor_name], quest_id: q_id, day_of_week: day) }
  end
end

ActiveRecord::Base.connection.reset_pk_sequence!("quests")
ActiveRecord::Base.connection.reset_pk_sequence!("tags")
ActiveRecord::Base.connection.reset_pk_sequence!("users")
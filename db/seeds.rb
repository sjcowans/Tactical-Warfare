User.destroy_all
Game.destroy_all

Game.create!

user = User.find_or_initialize_by(username: "sean")
user.password = "password"
user.password_confirmation = "password"
user.role = :admin
user.save!
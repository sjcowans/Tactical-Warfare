User.destroy_all
Game.destroy_all

game = Game.create!

password = ENV.fetch("TEST_PASSWORD", "password123")

usernames = [
  ENV.fetch("TEST_USERNAME_1", "test_user_1"),
  ENV.fetch("TEST_USERNAME_2", "test_user_2"),
  ENV.fetch("TEST_USERNAME_3", "test_user_3"),
  ENV.fetch("TEST_USERNAME_4", "test_user_4")
]

users = usernames.map do |username|
  User.create!(
    username: username,
    password: password,
    password_confirmation: password
  )
end

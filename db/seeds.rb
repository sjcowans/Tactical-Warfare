# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.destroy_all
Game.destroy_all

@game = Game.create!
@user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
@user1.confirm!

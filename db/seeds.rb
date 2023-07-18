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
@user1 = User.create!(email: ENV['TEST_EMAIL_1'], password: ENV['TEST_PASSWORD'], password_confirmation: ENV['TEST_PASSWORD'])
@user2 = User.create!(email: ENV['TEST_EMAIL_2'], password: ENV['TEST_PASSWORD'], password_confirmation: ENV['TEST_PASSWORD'])
@user3 = User.create!(email: ENV['TEST_EMAIL_3'], password: ENV['TEST_PASSWORD'], password_confirmation: ENV['TEST_PASSWORD'])
@user4 = User.create!(email: ENV['TEST_EMAIL_4'], password: ENV['TEST_PASSWORD'], password_confirmation: ENV['TEST_PASSWORD'])
@user1.confirm!
@user2.confirm!
@user3.confirm!
@user4.confirm!
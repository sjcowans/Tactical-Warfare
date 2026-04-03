# Tactical Warfare

Tactical Warfare is a turn-based strategy game built with Ruby on Rails where players develop and manage their own country over time while competing against other players. The game uses a timed progression system that grants players one turn per minute, enabling asynchronous multiplayer gameplay focused on long-term strategy, resource management, and combat.

## 🚀 Features

- ⏱️ Timed turn system with 1 turn generated per minute
- 🌍 Country-building mechanics with resource and population management
- ⚔️ Combat systems for attacking and competing with other players
- 👥 Asynchronous multiplayer gameplay (no real-time requirement)
- 📈 Persistent player progression and game-state tracking
- 🧠 Strategic decision-making systems for growth and combat

## 🛠️ Tech Stack

- **Language:** Ruby (3.2.3)
- **Framework:** Rails 7.0.4.3
- **Database:** PostgreSQL
- **Web Server:** Puma
- **Frontend:** Hotwire (Turbo + Stimulus), Importmap, jQuery
- **Testing:** RSpec
- **Linting:** RuboCop

## 🧠 System Design Highlights

- Built as a **Rails monolith** to centralize game logic, persistence, and user interactions
- Implemented **time-based progression** using a turn-generation model (1 turn per minute)
- Designed **relational database schemas** to support players, countries, resources, units, and combat
- Created **asynchronous multiplayer systems**, allowing players to interact without being online simultaneously
- Focused on **consistent state management** and long-term progression systems
- Utilized **scheduled job processing concepts** to support recurring turn-based updates

## 📌 Future Improvements

- Improve combat balancing and game mechanics
- Enhance UI/UX for player decision-making
- Add alliance, diplomacy, or ranking systems
- Introduce analytics for player progression and balancing
- Explore AI-driven simulation or decision modeling

## 👤 Author

Sean Cowans  
GitHub: https://github.com/sjcowans

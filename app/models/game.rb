class Game < ApplicationRecord
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  has_many :rooms, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_one :hero, dependent: :destroy
  belongs_to :user
  validates_associated :user
  validates_with BooleanOverStart
  before_save :max_games_number

  MONSTERS = ["Python serpent", "Java owlbear", "C# troll", "PHP-gnoll"]
  BOSS = ["Go Lord"]
  CHOICE = ["bridge", "grail"]
  TREASURES = ["Pair of Climbing Shoes 👟", "MacBook 💻"]
  EMPTY = %w(None) * 6
  UPPER_WALL = [1, 2, 3, 4]
  LOWER_WALL = [13, 14, 15, 16]
  LEFT_WALL  = [1, 5, 9, 13]
  RIGHT_WALL = [4, 8, 12, 16]
  ROOM_MOVEMENT = { "UP" => -4, "DOWN" => 4, "LEFT" => -1, "RIGHT" => 1 }
  MESSAGES = { empty: ["This room is empty - Nothing to see here..."],
               fight_boss: ["You've encountered you Nemesis, the dreadful Go Lord 👹.", "Time to fight!"], 
               victory: ["Congratulations, you won.", "These languages were no match for your Ruby sword, and your Rails armour!"],
               defeat: ["Gravely wounded, you have to retreat.", "But you know you'll be back. Hasta la vista babe."] }
  SCENARII = { bridge: {
                  description: ["You're facing the Bridge of Death 💀.", "A blind guardian asks you: 'There are 10 types of people.", "Which are you ?'"],
                  choices: ["Those who get ternary", "Those who don't", "Those who thought this was going to be a binary joke"],
                  positive_msg: ["You've crossed the bridge.", "The guardian, happy with your answer, gives you a kettlebell.", "You train and earn +5 strength 💪."],
                  negative_msg: ["You've crossed the bridge, but the guardian, unhappy, shot you in the face.", "As he's visually impaired, he got your shield arm.",  "You lost 2 defense  🤢."],
                  valid_choices: ['1', '3'],
                  consequence: { success: { strength: 5 }, failure: { defense: -2} }
                },
                grail: {
                  description: ["You've found 3 full cups 🏺.", "All doors are closed, and you understand that you need to drink from one of them.", " Which one will you choose?"],
                  choices: ['The cup decorated with diamonds', 'The cup decorated with rubies', 'The simple cup'],
                  positive_msg: ["The doors open, and you feel great.", "You've healed and earned 10 health points 🩹."],
                  negative_msg: ["The doors open, but you feel weak.", "You've lost 3 strength 🤢."],
                  valid_choices: ['2'],
                  consequence: { success: { health: 10 }, failure: { strength: -3} }
                }
              }

  def create_rooms
    rooms_content = (MONSTERS + BOSS + CHOICE + TREASURES + EMPTY).shuffle # Shuffle 15 non starting rooms
    rooms_content.each { |content| rooms.create(encounter: content, visited: false) } # Create them
    rooms.create(encounter: "Hero", visited: false) # Populate last room with hero
  end

  def create_hero
    self.hero = Hero.create(alive: true, health: 50, strength: 10, defense: 5, experience: 5, room_number: rooms.last.id)
  end

  def generate_board
    board_array = []
    sorted_board(rooms).each do |room|
      board_array << symbol(room)
    end
    board_array
  end

  def avalaible_commands
    commands = {}
    hero_room_base_16 = hero.room_number -  sorted_board(rooms).first.id + 1

    commands[:up]    = !UPPER_WALL.include?(hero_room_base_16)
    commands[:right] = !RIGHT_WALL.include?(hero_room_base_16)
    commands[:down]  = !LOWER_WALL.include?(hero_room_base_16)
    commands[:left]  = !LEFT_WALL.include?(hero_room_base_16)
    

    commands
  end

  def symbol(room)
    return '  '  if room.encounter == "None" && !room.visited
    return '❌'  if room.encounter == "None" && room.visited
    return '🐺' if MONSTERS.include?(room.encounter)
    return '🔮' if CHOICE.include?(room.encounter)
    return '💰' if TREASURES.include?(room.encounter)
    return '👹'  if BOSS.include?(room.encounter)
    '🦸' # Hero if non empty room with no opponent, choice or treasure
  end

  def start_adventure
    update(start: false)
    Event.new(self, nil).add_message("Move to start your adventure.")
  end

  def clean_hero_room
    former_room = rooms.find(hero.room_number)
    former_room.update(encounter: "None", visited: true)
  end

  def update_hero_room(command)
    new_hero_room = hero.room_number + ROOM_MOVEMENT[command]
    hero.update(room_number: new_hero_room) # Change hero room
    update_event(rooms.find(new_hero_room)) # Deals with encounter
    rooms.find(hero.room_number).update(encounter: "Hero") unless !hero.alive # Add hero symbol to new room unless he died this turn
  end

  def resolve_choice(num)
    Event.new(self, nil, num).choice_consequence
    update(choice: nil) # Deleting this choice
    check_alive
  end

  private

    def sorted_board(rooms)
      rooms.sort_by { |room| room.id }
    end

    def max_games_number
      return if user.games.count < 3
      errors.add :base, "Can't have more than 3 games"
      false
    end

    def is_boolean?(el)
      el.is_a?(TrueClass) || el.is_a?(FalseClass)
    end

    def update_event(room)
      Event.new(self, room).play_event
      check_alive
    end

    def check_alive
      if hero.health <= 0
        hero.update(alive: false)
        Event.new(self).end_game
      end
    end

    class Event
      def initialize(game, room = nil, num = nil)
        @game = game
        @hero = @game.hero
        @encounter = room.encounter if room
        @choice_num = num
        @visited = room.visited if room
      end

      def play_event
        case 
        when (MONSTERS + BOSS).include?(@encounter) then fight
        when (TREASURES).include?(@encounter) then treasure
        when (CHOICE).include?(@encounter) then choice
        else @visited ? visited_room : add_message(MESSAGES[:empty], true)
        end
      end

      def choice_consequence
        scenario = SCENARII[@game.choice.to_sym]
        if scenario[:valid_choices].include?(@choice_num)
          add_message(scenario[:positive_msg], true)
          hash = scenario[:consequence][:success]
        else
          add_message(scenario[:negative_msg], true)
          hash = scenario[:consequence][:failure]
        end

        carac = hash.keys.first # Carac to be modified
        new_value = @hero.send(carac) + hash.values.first # Bonus or malus to carac.

        @hero.update({ hash.keys.first => new_value })
      end

      def add_message(msg, array = false, br = true)
        messages = array ? msg : [msg]
        messages.each { |message| @game.messages.create(body: message) }
        @game.messages.create(body: "br") if br # Skip a line by default after adding series of messages.
      end

      def end_game(defeat = true)
        msg = defeat ? MESSAGES[:defeat] : MESSAGES[:victory]
        add_message(msg, true)
        @game.update(over: true)
      end

      private

        def visited_room
          num = [rand(10) + 1, @hero.health].min # Can't lose more HP than current HP.
          new_health = @hero.health - num
          @hero.update(health: new_health)

          messages = ["You already visited this room.", "A Ruby Dev should know better: Don't Repeat Yourself!", "Ashamed, you lost #{num} health points 🩸."]

          add_message(messages, true)
        end

        def fight
          battle_loop
        end

        def treasure
          carac = ["defense", "strength"].sample
          symbol = carac == "defense" ? '🛡' : '🔪'
          value = rand(10) + 1
          add_message(["You've opened the chest, and found an Epic #{@encounter}.", "Every good Ruby dev needs one.", "You've increased your #{carac} by #{value} #{symbol}."], true)
          carac == "defense" ? @hero.update(defense: @hero.defense + value) : @hero.update(strength: @hero.strength + value)
        end
    
        def choice
          dilemma = SCENARII[@encounter.to_sym]
          @game.update(choice: @encounter)
          add_message(dilemma[:description], true)
          dilemma[:choices].each_with_index do |choice, idx|
            add_message("#{idx + 1}: #{choice}")
          end
        end

        def add_xp(new_xp)
          @hero.update(experience: @hero.experience + new_xp)
        end

        def battle_loop
          fighters = [Fighter.new(@hero), Fighter.new(@encounter)]
          current_fighter = fighters.first
          other_fighter = fighters.last

          str = @encounter == "Go Lord" ? MESSAGES[:fight_boss] : ["You've encountered a #{@encounter} 🐺.", "Time to fight !"]
          add_message(str, true) #Presentation of opponent

          until fighters.any?(&:dead?)
            current_fighter.harm(other_fighter)
            add_message("#{current_fighter.symbol} 🔪 attacks 🛡  #{other_fighter.symbol} (health ❤️  #{[other_fighter.health, 0].max})", false, false)
            other_fighter.actualize_hero_stats if other_fighter.symbol == '🦸'
            current_fighter, other_fighter = other_fighter, current_fighter
          end

          add_message("br", false, false) # Skip a line after combat loop.
          
          if @hero.health > 0 # Hero won the fight
            combat_xp = @encounter == "Go Lord" ? 20 : 5
            add_xp(combat_xp)
            add_message(["You've vanquished the #{@encounter}!", "You've earned #{combat_xp} points of experience ✊."], true)
            end_game(false) if @encounter == "Go Lord" # Over if killed boss
          end
        end
    end

    class Fighter
      attr_reader :health, :strength, :defense, :experience, :symbol
    
      def initialize(fighter)
        if fighter.class == Hero
          @hero = fighter
          create_hero_fighter
        else
          @strength = 10
          @defense = 5
          if fighter == "Go Lord"
            @symbol = '👹'
            @health = 70
            @experience = 20
          else
            @symbol = '🐺'
            @health = 30
            @experience = 5
          end 
        end
      end

      def create_hero_fighter
        @symbol = '🦸'
        @health = @hero.health
        @strength = @hero.strength
        @defense = @hero.defense
        @experience = @hero.experience
      end

      def actualize_hero_stats
        @health = [0, @health].max
        @hero.update(health: @health)
      end
    
      def harm(other)
        other.health -= (strength + experience - other.defense)
      end
    
      def dead?
        @health <= 0
      end
    
      protected
    
      attr_writer :health
    end
end

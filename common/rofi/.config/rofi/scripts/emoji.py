#!/usr/bin/python3
# -*- coding: utf-8 -*-

from subprocess import Popen, PIPE

emojis="""⛑🏻 Helmet With White Cross, Type-1-2
💏🏻 Kiss, Type-1-2
💑🏻 Couple With Heart, Type-1-2
⛷🏻 Skier, Type-1-2
😀 Grinning Face
😁 Beaming Face With Smiling Eyes
😂 Face With Tears of Joy
🤣 Rolling on the Floor Laughing
😃 Grinning Face With Big Eyes
😄 Grinning Face With Smiling Eyes
😅 Grinning Face With Sweat
😆 Grinning Squinting Face
😉 Winking Face
😊 Smiling Face With Smiling Eyes
😋 Face Savoring Food
😎 Smiling Face With Sunglasses
😍 Smiling Face With Heart-Eyes
😘 Face Blowing a Kiss
🥰 Smiling Face With 3 Hearts
😗 Kissing Face
😙 Kissing Face With Smiling Eyes
😚 Kissing Face With Closed Eyes
☺️ Smiling Face
🙂 Slightly Smiling Face
🤗 Hugging Face
🤩 Star-Struck
🤔 Thinking Face
🤨 Face With Raised Eyebrow
😐 Neutral Face
😑 Expressionless Face
😶 Face Without Mouth
🙄 Face With Rolling Eyes
😏 Smirking Face
😣 Persevering Face
😥 Sad but Relieved Face
😮 Face With Open Mouth
🤐 Zipper-Mouth Face
😯 Hushed Face
😪 Sleepy Face
😫 Tired Face
😴 Sleeping Face
😌 Relieved Face
😛 Face With Tongue
😜 Winking Face With Tongue
😝 Squinting Face With Tongue
🤤 Drooling Face
😒 Unamused Face
😓 Downcast Face With Sweat
😔 Pensive Face
😕 Confused Face
🙃 Upside-Down Face
🤑 Money-Mouth Face
😲 Astonished Face
☹️ Frowning Face
🙁 Slightly Frowning Face
😖 Confounded Face
😞 Disappointed Face
😟 Worried Face
😤 Face With Steam From Nose
😢 Crying Face
😭 Loudly Crying Face
😦 Frowning Face With Open Mouth
😧 Anguished Face
😨 Fearful Face
😩 Weary Face
🤯 Exploding Head
😬 Grimacing Face
😰 Anxious Face With Sweat
😱 Face Screaming in Fear
🥵 Hot Face
🥶 Cold Face
😳 Flushed Face
🤪 Zany Face
😵 Dizzy Face
😡 Pouting Face
😠 Angry Face
🤬 Face With Symbols on Mouth
😷 Face With Medical Mask
🤒 Face With Thermometer
🤕 Face With Head-Bandage
🤢 Nauseated Face
🤮 Face Vomiting
🤧 Sneezing Face
😇 Smiling Face With Halo
🤠 Cowboy Hat Face
🤡 Clown Face
🥳 Partying Face
🥴 Woozy Face
🥺 Pleading Face
🤥 Lying Face
🤫 Shushing Face
🤭 Face With Hand Over Mouth
🧐 Face With Monocle
🤓 Nerd Face
😈 Smiling Face With Horns
👿 Angry Face With Horns
👹 Ogre
👺 Goblin
💀 Skull
☠️ Skull and Crossbones
👻 Ghost
👽 Alien
👾 Alien Monster
🤖 Robot Face
💩 Pile of Poo
😺 Grinning Cat Face
😸 Grinning Cat Face With Smiling Eyes
😹 Cat Face With Tears of Joy
😻 Smiling Cat Face With Heart-Eyes
😼 Cat Face With Wry Smile
😽 Kissing Cat Face
🙀 Weary Cat Face
😿 Crying Cat Face
😾 Pouting Cat Face
🙈 See-No-Evil Monkey
🙉 Hear-No-Evil Monkey
🙊 Speak-No-Evil Monkey
👶 Baby
🧒 Child
👦 Boy
👧 Girl
🧑 Adult
👨 Man
👩 Woman
🧓 Older Adult
👴 Old Man
👵 Old Woman
👨‍⚕️ Man Health Worker
👩‍⚕️ Woman Health Worker
👨‍🎓 Man Student
👩‍🎓 Woman Student
👨‍🏫 Man Teacher
👩‍🏫 Woman Teacher
👨‍⚖️ Man Judge
👩‍⚖️ Woman Judge
👨‍🌾 Man Farmer
👩‍🌾 Woman Farmer
👨‍🍳 Man Cook
👩‍🍳 Woman Cook
👨‍🔧 Man Mechanic
👩‍🔧 Woman Mechanic
👨‍🏭 Man Factory Worker
👩‍🏭 Woman Factory Worker
👨‍💼 Man Office Worker
👩‍💼 Woman Office Worker
👨‍🔬 Man Scientist
👩‍🔬 Woman Scientist
👨‍💻 Man Technologist
👩‍💻 Woman Technologist
👨‍🎤 Man Singer
👩‍🎤 Woman Singer
👨‍🎨 Man Artist
👩‍🎨 Woman Artist
👨‍✈️ Man Pilot
👩‍✈️ Woman Pilot
👨‍🚀 Man Astronaut
👩‍🚀 Woman Astronaut
👨‍🚒 Man Firefighter
👩‍🚒 Woman Firefighter
👮 Police Officer
👮‍♂️ Man Police Officer
👮‍♀️ Woman Police Officer
🕵️ Detective
🕵️‍♂️ Man Detective
🕵️‍♀️ Woman Detective
💂 Guard
💂‍♂️ Man Guard
💂‍♀️ Woman Guard
👷 Construction Worker
👷‍♂️ Man Construction Worker
👷‍♀️ Woman Construction Worker
🤴 Prince
👸 Princess
👳 Person Wearing Turban
👳‍♂️ Man Wearing Turban
👳‍♀️ Woman Wearing Turban
👲 Man With Chinese Cap
🧕 Woman With Headscarf
🧔 Bearded Person
👱 Blond-Haired Person
👱‍♂️ Blond-Haired Man
👱‍♀️ Blond-Haired Woman
👨‍🦰 Man, Red Haired
👩‍🦰 Woman, Red Haired
👨‍🦱 Man, Curly Haired
👩‍🦱 Woman, Curly Haired
👨‍🦲 Man, Bald
👩‍🦲 Woman, Bald
👨‍🦳 Man, White Haired
👩‍🦳 Woman, White Haired
🤵 Man in Tuxedo
👰 Bride With Veil
🤰 Pregnant Woman
🤱 Breast-Feeding
👼 Baby Angel
🎅 Santa Claus
🤶 Mrs. Claus
🦸 Superhero
🦸‍♀️ Woman Superhero
🦸‍♂️ Man Superhero
👯🏻 Woman With Bunny Ears, Type-1-2
🦹 Supervillain
👯🏻‍♂️ Men With Bunny Ears Partying, Type-1-2
🦹‍♀️ Woman Supervillain
👯🏻‍♀️ Women With Bunny Ears Partying, Type-1-2
🦹‍♂️ Man Supervillain
👫🏻 Man and Woman Holding Hands, Type-1-2
🧙 Mage
👬🏻 Two Men Holding Hands, Type-1-2
🧙‍♀️ Woman Mage
👭🏻 Two Women Holding Hands, Type-1-2
🧙‍♂️ Man Mage
👪🏻 Family, Type-1-2
🧚 Fairy
🧚‍♀️ Woman Fairy
🧚‍♂️ Man Fairy
🧛 Vampire
🧛‍♀️ Woman Vampire
🧛‍♂️ Man Vampire
🧜 Merperson
🧜‍♀️ Mermaid
🧜‍♂️ Merman
🧝 Elf
🧝‍♀️ Woman Elf
🧝‍♂️ Man Elf
🧞 Genie
🧞‍♀️ Woman Genie
🧞‍♂️ Man Genie
🧟 Zombie
🧟‍♀️ Woman Zombie
🧟‍♂️ Man Zombie
🙍 Person Frowning
🙍‍♂️ Man Frowning
🙍‍♀️ Woman Frowning
🙎 Person Pouting
🙎‍♂️ Man Pouting
🙎‍♀️ Woman Pouting
🙅 Person Gesturing No
🙅‍♂️ Man Gesturing No
🤝🏻 Handshake, Type-1-2
🙅‍♀️ Woman Gesturing No
🙆 Person Gesturing OK
🙆‍♂️ Man Gesturing OK
🙆‍♀️ Woman Gesturing OK
💁 Person Tipping Hand
💁‍♂️ Man Tipping Hand
💁‍♀️ Woman Tipping Hand
🙋 Person Raising Hand
🙋‍♂️ Man Raising Hand
🙋‍♀️ Woman Raising Hand
🙇 Person Bowing
🙇‍♂️ Man Bowing
🙇‍♀️ Woman Bowing
🤦 Person Facepalming
🤦‍♂️ Man Facepalming
🤦‍♀️ Woman Facepalming
🤷 Person Shrugging
🤷‍♂️ Man Shrugging
🤷‍♀️ Woman Shrugging
💆 Person Getting Massage
💆‍♂️ Man Getting Massage
💆‍♀️ Woman Getting Massage
💇 Person Getting Haircut
💇‍♂️ Man Getting Haircut
💇‍♀️ Woman Getting Haircut
🚶 Person Walking
🚶‍♂️ Man Walking
🚶‍♀️ Woman Walking
🏃 Person Running
🏃‍♂️ Man Running
🏃‍♀️ Woman Running
💃 Woman Dancing
🕺 Man Dancing
👯 People With Bunny Ears
👯‍♂️ Men With Bunny Ears
👯‍♀️ Women With Bunny Ears
🧖 Person in Steamy Room
🧖‍♀️ Woman in Steamy Room
🧖‍♂️ Man in Steamy Room
🧗 Person Climbing
🧗‍♀️ Woman Climbing
🧗‍♂️ Man Climbing
🧘 Person in Lotus Position
🧘‍♀️ Woman in Lotus Position
🧘‍♂️ Man in Lotus Position
🛀 Person Taking Bath
🛌 Person in Bed
🕴️ Man in Suit Levitating
🗣️ Speaking Head
👤 Bust in Silhouette
👥 Busts in Silhouette
🤺 Person Fencing
🏇 Horse Racing
⛷️ Skier
🏂 Snowboarder
🏌️ Person Golfing
🏌️‍♂️ Man Golfing
🏌️‍♀️ Woman Golfing
🏄 Person Surfing
🏄‍♂️ Man Surfing
🏄‍♀️ Woman Surfing
🚣 Person Rowing Boat
🚣‍♂️ Man Rowing Boat
🚣‍♀️ Woman Rowing Boat
🏊 Person Swimming
🏊‍♂️ Man Swimming
🏊‍♀️ Woman Swimming
⛹️ Person Bouncing Ball
⛹️‍♂️ Man Bouncing Ball
⛹️‍♀️ Woman Bouncing Ball
🏋️ Person Lifting Weights
🏋️‍♂️ Man Lifting Weights
🏋️‍♀️ Woman Lifting Weights
🚴 Person Biking
🚴‍♂️ Man Biking
🚴‍♀️ Woman Biking
🚵 Person Mountain Biking
🚵‍♂️ Man Mountain Biking
🚵‍♀️ Woman Mountain Biking
🏎️ Racing Car
🏍️ Motorcycle
🤸 Person Cartwheeling
🤼🏻 Wrestlers, Type-1-2
🤸‍♂️ Man Cartwheeling
🤼🏻‍♂️ Men Wrestling, Type-1-2
🤼🏻‍♀️ Women Wrestling, Type-1-2
🤸‍♀️ Woman Cartwheeling
🤼 People Wrestling
🤼‍♂️ Men Wrestling
🤼‍♀️ Women Wrestling
🤽 Person Playing Water Polo
🤽‍♂️ Man Playing Water Polo
🤽‍♀️ Woman Playing Water Polo
🤾 Person Playing Handball
🤾‍♂️ Man Playing Handball
🤾‍♀️ Woman Playing Handball
🤹 Person Juggling
🤹‍♂️ Man Juggling
🤹‍♀️ Woman Juggling
👫 Man and Woman Holding Hands
👬 Two Men Holding Hands
👭 Two Women Holding Hands
💏 Kiss
👩‍❤️‍💋‍👨 Kiss: Woman, Man
👨‍❤️‍💋‍👨 Kiss: Man, Man
👩‍❤️‍💋‍👩 Kiss: Woman, Woman
💑 Couple With Heart
👩‍❤️‍👨 Couple With Heart: Woman, Man
👨‍❤️‍👨 Couple With Heart: Man, Man
👩‍❤️‍👩 Couple With Heart: Woman, Woman
👪 Family
👨‍👩‍👦 Family: Man, Woman, Boy
👨‍👩‍👧 Family: Man, Woman, Girl
👨‍👩‍👧‍👦 Family: Man, Woman, Girl, Boy
👨‍👩‍👦‍👦 Family: Man, Woman, Boy, Boy
👨‍👩‍👧‍👧 Family: Man, Woman, Girl, Girl
👨‍👨‍👦 Family: Man, Man, Boy
👨‍👨‍👧 Family: Man, Man, Girl
👨‍👨‍👧‍👦 Family: Man, Man, Girl, Boy
👨‍👨‍👦‍👦 Family: Man, Man, Boy, Boy
👨‍👨‍👧‍👧 Family: Man, Man, Girl, Girl
👩‍👩‍👦 Family: Woman, Woman, Boy
👩‍👩‍👧 Family: Woman, Woman, Girl
👩‍👩‍👧‍👦 Family: Woman, Woman, Girl, Boy
👩‍👩‍👦‍👦 Family: Woman, Woman, Boy, Boy
👩‍👩‍👧‍👧 Family: Woman, Woman, Girl, Girl
👨‍👦 Family: Man, Boy
👨‍👦‍👦 Family: Man, Boy, Boy
👨‍👧 Family: Man, Girl
👨‍👧‍👦 Family: Man, Girl, Boy
👨‍👧‍👧 Family: Man, Girl, Girl
👩‍👦 Family: Woman, Boy
👩‍👦‍👦 Family: Woman, Boy, Boy
👩‍👧 Family: Woman, Girl
👩‍👧‍👦 Family: Woman, Girl, Boy
👩‍👧‍👧 Family: Woman, Girl, Girl
🤳 Selfie
💪 Flexed Biceps
🦵 Leg
🦶 Foot
👈 Backhand Index Pointing Left
👉 Backhand Index Pointing Right
☝️ Index Pointing Up
👆 Backhand Index Pointing Up
🖕 Middle Finger
👇 Backhand Index Pointing Down
✌️ Victory Hand
🤞 Crossed Fingers
🖖 Vulcan Salute
🤘 Sign of the Horns
🤙 Call Me Hand
🖐️ Hand With Fingers Splayed
✋ Raised Hand
👌 OK Hand
👍 Thumbs Up
👎 Thumbs Down
✊ Raised Fist
👊 Oncoming Fist
🤛 Left-Facing Fist
🤜 Right-Facing Fist
🤚 Raised Back of Hand
👋 Waving Hand
🤟 Love-You Gesture
✍️ Writing Hand
👏 Clapping Hands
👐 Open Hands
🙌 Raising Hands
🤲 Palms Up Together
🙏 Folded Hands
🤝 Handshake
💅 Nail Polish
👂 Ear
👃 Nose
🦰 Emoji Component Red Hair
🦱 Emoji Component Curly Hair
🦲 Emoji Component Bald
🦳 Emoji Component White Hair
👣 Footprints
👀 Eyes
👁️ Eye
👁️‍🗨️ Eye in Speech Bubble
🧠 Brain
🦴 Bone
🦷 Tooth
👅 Tongue
👄 Mouth
💋 Kiss Mark
💘 Heart With Arrow
❤️ Red Heart
💓 Beating Heart
💔 Broken Heart
💕 Two Hearts
💖 Sparkling Heart
💗 Growing Heart
💙 Blue Heart
💚 Green Heart
💛 Yellow Heart
🧡 Orange Heart
💜 Purple Heart
🖤 Black Heart
💝 Heart With Ribbon
💞 Revolving Hearts
💟 Heart Decoration
❣️ Heavy Heart Exclamation
💌 Love Letter
💤 Zzz
💢 Anger Symbol
💣 Bomb
💥 Collision
💦 Sweat Droplets
💨 Dashing Away
💫 Dizzy
💬 Speech Balloon
🗨️ Left Speech Bubble
🗯️ Right Anger Bubble
💭 Thought Balloon
🕳️ Hole
👓 Glasses
🕶️ Sunglasses
🥽 Goggles
🥼 Lab Coat
👔 Necktie
👕 T-Shirt
👖 Jeans
🧣 Scarf
🧤 Gloves
🧥 Coat
🧦 Socks
👗 Dress
👘 Kimono
👙 Bikini
👚 Woman’s Clothes
👛 Purse
👜 Handbag
👝 Clutch Bag
🛍️ Shopping Bags
🎒 School Backpack
👞 Man’s Shoe
👟 Running Shoe
🥾 Hiking Boot
🥿 Flat Shoe
👠 High-Heeled Shoe
👡 Woman’s Sandal
👢 Woman’s Boot
👑 Crown
👒 Woman’s Hat
🎩 Top Hat
🎓 Graduation Cap
🧢 Billed Cap
⛑️ Rescue Worker’s Helmet
📿 Prayer Beads
💄 Lipstick
💍 Ring
💎 Gem Stone
🐵 Monkey Face
🐒 Monkey
🦍 Gorilla
🐶 Dog Face
🐕 Dog
🐩 Poodle
🐺 Wolf Face
🦊 Fox Face
🦝 Raccoon
🐱 Cat Face
🐈 Cat
🦁 Lion Face
🐯 Tiger Face
🐅 Tiger
🐆 Leopard
🐴 Horse Face
🐎 Horse
🦄 Unicorn Face
🦓 Zebra
🦌 Deer
🐮 Cow Face
🐂 Ox
🐃 Water Buffalo
🐄 Cow
🐷 Pig Face
🐖 Pig
🐗 Boar
🐽 Pig Nose
🐏 Ram
🐑 Ewe
🐐 Goat
🐪 Camel
🐫 Two-Hump Camel
🦙 Llama
🦒 Giraffe
🐘 Elephant
🦏 Rhinoceros
🦛 Hippopotamus
🐭 Mouse Face
🐁 Mouse
🐀 Rat
🐹 Hamster Face
🐰 Rabbit Face
🐇 Rabbit
🐿️ Chipmunk
🦔 Hedgehog
🦇 Bat
🐻 Bear Face
🐨 Koala
🐼 Panda Face
🦘 Kangaroo
🦡 Badger
🐾 Paw Prints
🦃 Turkey
🐔 Chicken
🐓 Rooster
🐣 Hatching Chick
🐤 Baby Chick
🐥 Front-Facing Baby Chick
🐦 Bird
🐧 Penguin
🕊️ Dove
🦅 Eagle
🦆 Duck
🦢 Swan
🦉 Owl
🦚 Peacock
🦜 Parrot
🐸 Frog Face
🐊 Crocodile
🐢 Turtle
🦎 Lizard
🐍 Snake
🐲 Dragon Face
🐉 Dragon
🦕 Sauropod
🦖 T-Rex
🐳 Spouting Whale
🐋 Whale
🐬 Dolphin
🐟 Fish
🐠 Tropical Fish
🐡 Blowfish
🦈 Shark
🐙 Octopus
🐚 Spiral Shell
🦀 Crab
🦞 Lobster
🦐 Shrimp
🦑 Squid
🐌 Snail
🦋 Butterfly
🐛 Bug
🐜 Ant
🐝 Honeybee
🐞 Lady Beetle
🦗 Cricket
🕷️ Spider
🕸️ Spider Web
🦂 Scorpion
🦟 Mosquito
🦠 Microbe
💐 Bouquet
🌸 Cherry Blossom
💮 White Flower
🏵️ Rosette
🌹 Rose
🥀 Wilted Flower
🌺 Hibiscus
🌻 Sunflower
🌼 Blossom
🌷 Tulip
🌱 Seedling
🌲 Evergreen Tree
🌳 Deciduous Tree
🌴 Palm Tree
🌵 Cactus
🌾 Sheaf of Rice
🌿 Herb
☘️ Shamrock
🍀 Four Leaf Clover
🍁 Maple Leaf
🍂 Fallen Leaf
🍃 Leaf Fluttering in Wind
🍇 Grapes
🍈 Melon
🍉 Watermelon
🍊 Tangerine
🍋 Lemon
🍌 Banana
🍍 Pineapple
🥭 Mango
🍎 Red Apple
🍏 Green Apple
🍐 Pear
🍑 Peach
🍒 Cherries
🍓 Strawberry
🥝 Kiwi Fruit
🍅 Tomato
🥥 Coconut
🥑 Avocado
🍆 Eggplant
🥔 Potato
🥕 Carrot
🌽 Ear of Corn
🌶️ Hot Pepper
🥒 Cucumber
🥬 Leafy Green
🥦 Broccoli
🍄 Mushroom
🥜 Peanuts
🌰 Chestnut
🍞 Bread
🥐 Croissant
🥖 Baguette Bread
🥨 Pretzel
🥯 Bagel
🥞 Pancakes
🧀 Cheese Wedge
🍖 Meat on Bone
🍗 Poultry Leg
🥩 Cut of Meat
🥓 Bacon
🍔 Hamburger
🍟 French Fries
🍕 Pizza
🌭 Hot Dog
🥪 Sandwich
🌮 Taco
🌯 Burrito
🥙 Stuffed Flatbread
🥚 Egg
🍳 Cooking
🥘 Shallow Pan of Food
🍲 Pot of Food
🥣 Bowl With Spoon
🥗 Green Salad
🍿 Popcorn
🧂 Salt
🥫 Canned Food
🍱 Bento Box
🍘 Rice Cracker
🍙 Rice Ball
🍚 Cooked Rice
🍛 Curry Rice
🍜 Steaming Bowl
🍝 Spaghetti
🍠 Roasted Sweet Potato
🍢 Oden
🍣 Sushi
🍤 Fried Shrimp
🍥 Fish Cake With Swirl
🥮 Moon Cake
🍡 Dango
🥟 Dumpling
🥠 Fortune Cookie
🥡 Takeout Box
🍦 Soft Ice Cream
🍧 Shaved Ice
🍨 Ice Cream
🍩 Doughnut
🍪 Cookie
🎂 Birthday Cake
🍰 Shortcake
🧁 Cupcake
🥧 Pie
🍫 Chocolate Bar
🍬 Candy
🍭 Lollipop
🍮 Custard
🍯 Honey Pot
🍼 Baby Bottle
🥛 Glass of Milk
☕ Hot Beverage
🍵 Teacup Without Handle
🍶 Sake
🍾 Bottle With Popping Cork
🍷 Wine Glass
🍸 Cocktail Glass
🍹 Tropical Drink
🍺 Beer Mug
🍻 Clinking Beer Mugs
🥂 Clinking Glasses
🥃 Tumbler Glass
🥤 Cup With Straw
🥢 Chopsticks
🍽️ Fork and Knife With Plate
🍴 Fork and Knife
🥄 Spoon
🔪 Kitchen Knife
🏺 Amphora
🌍 Globe Showing Europe-Africa
🌎 Globe Showing Americas
🌏 Globe Showing Asia-Australia
🌐 Globe With Meridians
🗺️ World Map
🗾 Map of Japan
🧭 Compass
🏔️ Snow-Capped Mountain
⛰️ Mountain
🌋 Volcano
🗻 Mount Fuji
🏕️ Camping
🏖️ Beach With Umbrella
🏜️ Desert
🏝️ Desert Island
🏞️ National Park
🏟️ Stadium
🏛️ Classical Building
🏗️ Building Construction
🏘️ Houses
🏚️ Derelict House
🏠 House
🏡 House With Garden
🧱 Brick
🏢 Office Building
🏤 Post Office
🏥 Hospital
🏦 Bank
🏨 Hotel
🏩 Love Hotel
🏪 Convenience Store
🏫 School
🏬 Department Store
🏭 Factory
🏰 Castle
💒 Wedding
🗼 Tokyo Tower
🗽 Statue of Liberty
⛪ Church
🕌 Mosque
🕍 Synagogue
⛩️ Shinto Shrine
🕋 Kaaba
⛲ Fountain
⛺ Tent
🌁 Foggy
🌃 Night With Stars
🏙️ Cityscape
🌄 Sunrise Over Mountains
🌅 Sunrise
🌆 Cityscape at Dusk
🌇 Sunset
🌉 Bridge at Night
♨️ Hot Springs
🌌 Milky Way
🎠 Carousel Horse
🎡 Ferris Wheel
🎢 Roller Coaster
💈 Barber Pole
🎪 Circus Tent
🚂 Locomotive
🚃 Railway Car
🚄 High-Speed Train
🚅 Bullet Train
🚆 Train
🚇 Metro
🚈 Light Rail
🚉 Station
🚊 Tram
🚝 Monorail
🚞 Mountain Railway
🚋 Tram Car
🚌 Bus
🚍 Oncoming Bus
🚎 Trolleybus
🚐 Minibus
🚑 Ambulance
🚒 Fire Engine
🚓 Police Car
🚔 Oncoming Police Car
🚕 Taxi
🚖 Oncoming Taxi
🚗 Automobile
🚘 Oncoming Automobile
🚙 Sport Utility Vehicle
🚚 Delivery Truck
🚛 Articulated Lorry
🚜 Tractor
🚲 Bicycle
🛴 Kick Scooter
🛹 Skateboard
🛵 Motor Scooter
🚏 Bus Stop
🛣️ Motorway
🛤️ Railway Track
🛢️ Oil Drum
⛽ Fuel Pump
🚨 Police Car Light
🚥 Horizontal Traffic Light
🚦 Vertical Traffic Light
🛑 Stop Sign
🚧 Construction
⚓ Anchor
⛵ Sailboat
🛶 Canoe
🚤 Speedboat
🛳️ Passenger Ship
⛴️ Ferry
🛥️ Motor Boat
🚢 Ship
✈️ Airplane
🛩️ Small Airplane
🛫 Airplane Departure
🛬 Airplane Arrival
💺 Seat
🚁 Helicopter
🚟 Suspension Railway
🚠 Mountain Cableway
🚡 Aerial Tramway
🛰️ Satellite
🚀 Rocket
🛸 Flying Saucer
🛎️ Bellhop Bell
🧳 Luggage
⌛ Hourglass Done
⏳ Hourglass Not Done
⌚ Watch
⏰ Alarm Clock
⏱️ Stopwatch
⏲️ Timer Clock
🕰️ Mantelpiece Clock
🕛 Twelve O’clock
🕧 Twelve-Thirty
🕐 One O’clock
🕜 One-Thirty
🕑 Two O’clock
🕝 Two-Thirty
🕒 Three O’clock
🕞 Three-Thirty
🕓 Four O’clock
🕟 Four-Thirty
🕔 Five O’clock
🕠 Five-Thirty
🕕 Six O’clock
🕡 Six-Thirty
🕖 Seven O’clock
🕢 Seven-Thirty
🕗 Eight O’clock
🕣 Eight-Thirty
🕘 Nine O’clock
🕤 Nine-Thirty
🕙 Ten O’clock
🕥 Ten-Thirty
🕚 Eleven O’clock
🕦 Eleven-Thirty
🌑 New Moon
🌒 Waxing Crescent Moon
🌓 First Quarter Moon
🌔 Waxing Gibbous Moon
🌕 Full Moon
🌖 Waning Gibbous Moon
🌗 Last Quarter Moon
🌘 Waning Crescent Moon
🌙 Crescent Moon
🌚 New Moon Face
🌛 First Quarter Moon Face
🌜 Last Quarter Moon Face
🌡️ Thermometer
☀️ Sun
🌝 Full Moon Face
🌞 Sun With Face
⭐ White Medium Star
🌟 Glowing Star
🌠 Shooting Star
☁️ Cloud
⛅ Sun Behind Cloud
⛈️ Cloud With Lightning and Rain
🌤️ Sun Behind Small Cloud
🌥️ Sun Behind Large Cloud
🌦️ Sun Behind Rain Cloud
🌧️ Cloud With Rain
🌨️ Cloud With Snow
🌩️ Cloud With Lightning
🌪️ Tornado
🌫️ Fog
🌬️ Wind Face
🌀 Cyclone
🌈 Rainbow
🌂 Closed Umbrella
☂️ Umbrella
☔ Umbrella With Rain Drops
⛱️ Umbrella on Ground
⚡ High Voltage
❄️ Snowflake
☃️ Snowman
⛄ Snowman Without Snow
☄️ Comet
🔥 Fire
💧 Droplet
🌊 Water Wave
🎃 Jack-O-Lantern
🎄 Christmas Tree
🎆 Fireworks
🎇 Sparkler
🧨 Firecracker
✨ Sparkles
🎈 Balloon
🎉 Party Popper
🎊 Confetti Ball
🎋 Tanabata Tree
🎍 Pine Decoration
🎏 Carp Streamer
🎐 Wind Chime
🎑 Moon Viewing Ceremony
🧧 Red Gift Envelope
🎀 Ribbon
🎁 Wrapped Gift
🎗️ Reminder Ribbon
🎟️ Admission Tickets
🎫 Ticket
🎖️ Military Medal
🏆 Trophy
🏅 Sports Medal
🥇 1st Place Medal
🥈 2nd Place Medal
🥉 3rd Place Medal
⚽ Soccer Ball
⚾ Baseball
🥎 Softball
🏀 Basketball
🏐 Volleyball
🏈 American Football
🏉 Rugby Football
🎾 Tennis
🥏 Flying Disc
🎳 Bowling
🏏 Cricket Game
🏑 Field Hockey
🏒 Ice Hockey
🥍 Lacrosse
🏓 Ping Pong
🏸 Badminton
🥊 Boxing Glove
🥋 Martial Arts Uniform
🥅 Goal Net
⛳ Flag in Hole
⛸️ Ice Skate
🎣 Fishing Pole
🎽 Running Shirt
🎿 Skis
🛷 Sled
🥌 Curling Stone
🎯 Direct Hit
🎱 Pool 8 Ball
🔮 Crystal Ball
🧿 Nazar Amulet
🎮 Video Game
🕹️ Joystick
🎰 Slot Machine
🎲 Game Die
🧩 Jigsaw
🧸 Teddy Bear
♠️ Spade Suit
♥️ Heart Suit
♦️ Diamond Suit
♣️ Club Suit
♟️ Chess Pawn
🃏 Joker
🀄 Mahjong Red Dragon
🎴 Flower Playing Cards
🎭 Performing Arts
🖼️ Framed Picture
🎨 Artist Palette
🔇 Muted Speaker
🔈 Speaker Low Volume
🔉 Speaker Medium Volume
🔊 Speaker High Volume
📢 Loudspeaker
📣 Megaphone
📯 Postal Horn
🔔 Bell
🔕 Bell With Slash
🎼 Musical Score
🎵 Musical Note
🎶 Musical Notes
🎙️ Studio Microphone
🎚️ Level Slider
🎛️ Control Knobs
🎤 Microphone
🎧 Headphone
📻 Radio
🎷 Saxophone
🎸 Guitar
🎹 Musical Keyboard
🎺 Trumpet
🎻 Violin
🥁 Drum
📱 Mobile Phone
📲 Mobile Phone With Arrow
☎️ Telephone
📞 Telephone Receiver
📟 Pager
📠 Fax Machine
🔋 Battery
🔌 Electric Plug
💻 Laptop Computer
🖥️ Desktop Computer
🖨️ Printer
⌨️ Keyboard
🖱️ Computer Mouse
🖲️ Trackball
💽 Computer Disk
💾 Floppy Disk
💿 Optical Disk
📀 DVD
🧮 Abacus
🎥 Movie Camera
🎞️ Film Frames
📽️ Film Projector
🎬 Clapper Board
📺 Television
📷 Camera
📸 Camera With Flash
📹 Video Camera
📼 Videocassette
🔍 Magnifying Glass Tilted Left
🔎 Magnifying Glass Tilted Right
🕯️ Candle
💡 Light Bulb
🔦 Flashlight
🏮 Red Paper Lantern
📔 Notebook With Decorative Cover
📕 Closed Book
📖 Open Book
📗 Green Book
📘 Blue Book
📙 Orange Book
📚 Books
📓 Notebook
📒 Ledger
📃 Page With Curl
📜 Scroll
📄 Page Facing Up
📰 Newspaper
🗞️ Rolled-Up Newspaper
📑 Bookmark Tabs
🔖 Bookmark
🏷️ Label
💰 Money Bag
💴 Yen Banknote
💵 Dollar Banknote
💶 Euro Banknote
💷 Pound Banknote
💸 Money With Wings
💳 Credit Card
🧾 Receipt
💹 Chart Increasing With Yen
💱 Currency Exchange
💲 Heavy Dollar Sign
✉️ Envelope
📧 E-Mail
📨 Incoming Envelope
📩 Envelope With Arrow
📤 Outbox Tray
📥 Inbox Tray
📦 Package
📫 Closed Mailbox With Raised Flag
📪 Closed Mailbox With Lowered Flag
📬 Open Mailbox With Raised Flag
📭 Open Mailbox With Lowered Flag
📮 Postbox
🗳️ Ballot Box With Ballot
✏️ Pencil
✒️ Black Nib
🖋️ Fountain Pen
🖊️ Pen
🖌️ Paintbrush
🖍️ Crayon
📝 Memo
💼 Briefcase
📁 File Folder
📂 Open File Folder
🗂️ Card Index Dividers
📅 Calendar
📆 Tear-Off Calendar
🗒️ Spiral Notepad
🗓️ Spiral Calendar
📇 Card Index
📈 Chart Increasing
📉 Chart Decreasing
📊 Bar Chart
📋 Clipboard
📌 Pushpin
📍 Round Pushpin
📎 Paperclip
🖇️ Linked Paperclips
📏 Straight Ruler
📐 Triangular Ruler
✂️ Scissors
🗃️ Card File Box
🗄️ File Cabinet
🗑️ Wastebasket
🔒 Locked
🔓 Unlocked
🔏 Locked With Pen
🔐 Locked With Key
🔑 Key
🗝️ Old Key
🔨 Hammer
⛏️ Pick
⚒️ Hammer and Pick
🛠️ Hammer and Wrench
🗡️ Dagger
⚔️ Crossed Swords
🔫 Pistol
🏹 Bow and Arrow
🛡️ Shield
🔧 Wrench
🔩 Nut and Bolt
⚙️ Gear
🗜️ Clamp
⚖️ Balance Scale
🔗 Link
⛓️ Chains
🧰 Toolbox
🧲 Magnet
⚗️ Alembic
🧪 Test Tube
🧫 Petri Dish
🧬 DNA
🧯 Fire Extinguisher
🔬 Microscope
🔭 Telescope
📡 Satellite Antenna
💉 Syringe
💊 Pill
🚪 Door
🛏️ Bed
🛋️ Couch and Lamp
🚽 Toilet
🚿 Shower
🛁 Bathtub
🧴 Lotion Bottle
🧵 Thread
🧶 Yarn
🧷 Safety Pin
🧹 Broom
🧺 Basket
🧻 Roll of Toilet Paper
🧼 Soap
🧽 Sponge
🛒 Shopping Cart
🚬 Cigarette
⚰️ Coffin
⚱️ Funeral Urn
🗿 Moai
🏧 Atm Sign
🚮 Litter in Bin Sign
🚰 Potable Water
♿ Wheelchair Symbol
🚹 Men’s Room
🚺 Women’s Room
🚻 Restroom
🚼 Baby Symbol
🚾 Water Closet
🛂 Passport Control
🛃 Customs
🛄 Baggage Claim
🛅 Left Luggage
⚠️ Warning
🚸 Children Crossing
⛔ No Entry
🚫 Prohibited
🚳 No Bicycles
🚭 No Smoking
🚯 No Littering
🚱 Non-Potable Water
🚷 No Pedestrians
📵 No Mobile Phones
🔞 No One Under Eighteen
☢️ Radioactive
☣️ Biohazard
⬆️ Up Arrow
↗️ Up-Right Arrow
➡️ Right Arrow
↘️ Down-Right Arrow
⬇️ Down Arrow
↙️ Down-Left Arrow
⬅️ Left Arrow
↖️ Up-Left Arrow
↕️ Up-Down Arrow
↔️ Left-Right Arrow
↩️ Right Arrow Curving Left
↪️ Left Arrow Curving Right
⤴️ Right Arrow Curving Up
⤵️ Right Arrow Curving Down
🔃 Clockwise Vertical Arrows
🔄 Counterclockwise Arrows Button
🔙 Back Arrow
🔚 End Arrow
🔛 On! Arrow
🔜 Soon Arrow
🔝 Top Arrow
🛐 Place of Worship
⚛️ Atom Symbol
♾️ Infinity
🕉️ Om
✡️ Star of David
☸️ Wheel of Dharma
☯️ Yin Yang
✝️ Latin Cross
☦️ Orthodox Cross
☪️ Star and Crescent
☮️ Peace Symbol
🕎 Menorah
🔯 Dotted Six-Pointed Star
♈ Aries
♉ Taurus
♊ Gemini
♋ Cancer
♌ Leo
♍ Virgo
♎ Libra
♏ Scorpio
♐ Sagittarius
♑ Capricorn
♒ Aquarius
♓ Pisces
⛎ Ophiuchus
🔀 Shuffle Tracks Button
🔁 Repeat Button
🔂 Repeat Single Button
▶️ Play Button
⏩ Fast-Forward Button
⏭️ Next Track Button
⏯️ Play or Pause Button
◀️ Reverse Button
⏪ Fast Reverse Button
⏮️ Last Track Button
🔼 Upwards Button
⏫ Fast Up Button
🔽 Downwards Button
⏬ Fast Down Button
⏸️ Pause Button
⏹️ Stop Button
⏺️ Record Button
⏏️ Eject Button
🎦 Cinema
🔅 Dim Button
🔆 Bright Button
📶 Antenna Bars
📳 Vibration Mode
📴 Mobile Phone Off
♀️ Female Sign
♂️ Male Sign
⚕️ Medical Symbol
♻️ Recycling Symbol
⚜️ Fleur-De-Lis
🔱 Trident Emblem
📛 Name Badge
⭕ Heavy Large Circle
✅ White Heavy Check Mark
☑️ Ballot Box With Check
✔️ Heavy Check Mark
✖️ Heavy Multiplication X
❌ Cross Mark
❎ Cross Mark Button
➕ Heavy Plus Sign
➖ Heavy Minus Sign
➗ Heavy Division Sign
➰ Curly Loop
➿ Double Curly Loop
〽️ Part Alternation Mark
✳️ Eight-Spoked Asterisk
✴️ Eight-Pointed Star
❇️ Sparkle
‼️ Double Exclamation Mark
⁉️ Exclamation Question Mark
❓ Question Mark
❔ White Question Mark
❕ White Exclamation Mark
❗ Exclamation Mark
〰️ Wavy Dash
©️ Copyright
®️ Registered
™️ Trade Mark
#️⃣ Keycap Number Sign
*️⃣ Keycap Asterisk
0️⃣ Keycap Digit Zero
1️⃣ Keycap Digit One
2️⃣ Keycap Digit Two
3️⃣ Keycap Digit Three
4️⃣ Keycap Digit Four
5️⃣ Keycap Digit Five
6️⃣ Keycap Digit Six
7️⃣ Keycap Digit Seven
8️⃣ Keycap Digit Eight
9️⃣ Keycap Digit Nine
🔟 Keycap 10
💯 Hundred Points
🔠 Input Latin Uppercase
🔡 Input Latin Lowercase
🔢 Input Numbers
🔣 Input Symbols
🔤 Input Latin Letters
🅰️ A Button (blood Type)
🆎 Ab Button (blood Type)
🅱️ B Button (blood Type)
🆑 CL Button
🆒 Cool Button
🆓 Free Button
ℹ️ Information
🆔 ID Button
Ⓜ️ Circled M
🆕 New Button
🆖 NG Button
🅾️ O Button (blood Type)
🆗 OK Button
🅿️ P Button
🆘 SOS Button
🆙 Up! Button
🆚 Vs Button
▪️ Black Small Square
▫️ White Small Square
◻️ White Medium Square
◼️ Black Medium Square
◽ White Medium-Small Square
◾ Black Medium-Small Square
⬛ Black Large Square
⬜ White Large Square
🔶 Large Orange Diamond
🔷 Large Blue Diamond
🔸 Small Orange Diamond
🔹 Small Blue Diamond
🔺 Red Triangle Pointed Up
🔻 Red Triangle Pointed Down
💠 Diamond With a Dot
🔘 Radio Button
🔲 Black Square Button
🔳 White Square Button
⚪ White Circle
⚫ Black Circle
🔴 Red Circle
🔵 Blue Circle
🏁 Chequered Flag
🚩 Triangular Flag
🎌 Crossed Flags
🏴 Black Flag
🏳️ White Flag
🏳️‍🌈 Rainbow Flag
🏴‍☠️ Pirate Flag
🇦🇨 Ascension Island
🇦🇩 Andorra
🇦🇪 United Arab Emirates
🇦🇫 Afghanistan
🇦🇬 Antigua & Barbuda
🇦🇮 Anguilla
🇦🇱 Albania
🇦🇲 Armenia
🇦🇴 Angola
🇦🇶 Antarctica
🇦🇷 Argentina
🇦🇸 American Samoa
🇦🇹 Austria
🇦🇺 Australia
🇦🇼 Aruba
🇦🇽 Åland Islands
🇦🇿 Azerbaijan
🇧🇦 Bosnia & Herzegovina
🇧🇧 Barbados
🇧🇩 Bangladesh
🇧🇪 Belgium
🇧🇫 Burkina Faso
🇧🇬 Bulgaria
🇧🇭 Bahrain
🇧🇮 Burundi
🇧🇯 Benin
🇧🇱 St. Barthélemy
🇧🇲 Bermuda
🇧🇳 Brunei
🇧🇴 Bolivia
🇧🇶 Caribbean Netherlands
🇧🇷 Brazil
🇧🇸 Bahamas
🇧🇹 Bhutan
🇧🇻 Bouvet Island
🇧🇼 Botswana
🇧🇾 Belarus
🇧🇿 Belize
🇨🇦 Canada
🇨🇨 Cocos (Keeling) Islands
🇨🇩 Congo - Kinshasa
🇨🇫 Central African Republic
🇨🇬 Congo - Brazzaville
🇨🇭 Switzerland
🇨🇮 Côte D’Ivoire
🇨🇰 Cook Islands
🇨🇱 Chile
🇨🇲 Cameroon
🇨🇳 China
🇨🇴 Colombia
🇨🇵 Clipperton Island
🇨🇷 Costa Rica
🇨🇺 Cuba
🇨🇻 Cape Verde
🇨🇼 Curaçao
🇨🇽 Christmas Island
🇨🇾 Cyprus
🇨🇿 Czechia
🇩🇪 Germany
🇩🇬 Diego Garcia
🇩🇯 Djibouti
🇩🇰 Denmark
🇩🇲 Dominica
🇩🇴 Dominican Republic
🇩🇿 Algeria
🇪🇦 Ceuta & Melilla
🇪🇨 Ecuador
🇪🇪 Estonia
🇪🇬 Egypt
🇪🇭 Western Sahara
🇪🇷 Eritrea
🇪🇸 Spain
🇪🇹 Ethiopia
🇪🇺 European Union
🇫🇮 Finland
🇫🇯 Fiji
🇫🇰 Falkland Islands
🇫🇲 Micronesia
🇫🇴 Faroe Islands
🇫🇷 France
🇬🇦 Gabon
🇬🇧 United Kingdom
🇬🇩 Grenada
🇬🇪 Georgia
🇬🇫 French Guiana
🇬🇬 Guernsey
🇬🇭 Ghana
🇬🇮 Gibraltar
🇬🇱 Greenland
🇬🇲 Gambia
🇬🇳 Guinea
🇬🇵 Guadeloupe
🇬🇶 Equatorial Guinea
🇬🇷 Greece
🇬🇸 South Georgia & South Sandwich Islands
🇬🇹 Guatemala
🇬🇺 Guam
🇬🇼 Guinea-Bissau
🇬🇾 Guyana
🇭🇰 Hong Kong SAR China
🇭🇲 Heard & McDonald Islands
🇭🇳 Honduras
🇭🇷 Croatia
🇭🇹 Haiti
🇭🇺 Hungary
🇮🇨 Canary Islands
🇮🇩 Indonesia
🇮🇪 Ireland
🇮🇱 Israel
🇮🇲 Isle of Man
🇮🇳 India
🇮🇴 British Indian Ocean Territory
🇮🇶 Iraq
🇮🇷 Iran
🇮🇸 Iceland
🇮🇹 Italy
🇯🇪 Jersey
🇯🇲 Jamaica
🇯🇴 Jordan
🇯🇵 Japan
🇰🇪 Kenya
🇰🇬 Kyrgyzstan
🇰🇭 Cambodia
🇰🇮 Kiribati
🇰🇲 Comoros
🇰🇳 St. Kitts & Nevis
🇰🇵 North Korea
🇰🇷 South Korea
🇰🇼 Kuwait
🇰🇾 Cayman Islands
🇰🇿 Kazakhstan
🇱🇦 Laos
🇱🇧 Lebanon
🇱🇨 St. Lucia
🇱🇮 Liechtenstein
🇱🇰 Sri Lanka
🇱🇷 Liberia
🇱🇸 Lesotho
🇱🇹 Lithuania
🇱🇺 Luxembourg
🇱🇻 Latvia
🇱🇾 Libya
🇲🇦 Morocco
🇲🇨 Monaco
🇲🇩 Moldova
🇲🇪 Montenegro
🇲🇫 St. Martin
🇲🇬 Madagascar
🇲🇭 Marshall Islands
🇲🇰 Macedonia
🇲🇱 Mali
🇲🇲 Myanmar (Burma)
🇲🇳 Mongolia
🇲🇴 Macau SAR China
🇲🇵 Northern Mariana Islands
🇲🇶 Martinique
🇲🇷 Mauritania
🇲🇸 Montserrat
🇲🇹 Malta
🇲🇺 Mauritius
🇲🇻 Maldives
🇲🇼 Malawi
🇲🇽 Mexico
🇲🇾 Malaysia
🇲🇿 Mozambique
🇳🇦 Namibia
🇳🇨 New Caledonia
🇳🇪 Niger
🇳🇫 Norfolk Island
🇳🇬 Nigeria
🇳🇮 Nicaragua
🇳🇱 Netherlands
🇳🇴 Norway
🇳🇵 Nepal
🇳🇷 Nauru
🇳🇺 Niue
🇳🇿 New Zealand
🇴🇲 Oman
🇵🇦 Panama
🇵🇪 Peru
🇵🇫 French Polynesia
🇵🇬 Papua New Guinea
🇵🇭 Philippines
🇵🇰 Pakistan
🇵🇱 Poland
🇵🇲 St. Pierre & Miquelon
🇵🇳 Pitcairn Islands
🇵🇷 Puerto Rico
🇵🇸 Palestinian Territories
🇵🇹 Portugal
🇵🇼 Palau
🇵🇾 Paraguay
🇶🇦 Qatar
🇷🇪 Réunion
🇷🇴 Romania
🇷🇸 Serbia
🇷🇺 Russia
🇷🇼 Rwanda
🇸🇦 Saudi Arabia
🇸🇧 Solomon Islands
🇸🇨 Seychelles
🇸🇩 Sudan
🇸🇪 Sweden
🇸🇬 Singapore
🇸🇭 St. Helena
🇸🇮 Slovenia
🇸🇯 Svalbard & Jan Mayen
🇸🇰 Slovakia
🇸🇱 Sierra Leone
🇸🇲 San Marino
🇸🇳 Senegal
🇸🇴 Somalia
🇸🇷 Suriname
🇸🇸 South Sudan
🇸🇹 São Tomé & Príncipe
🇸🇻 El Salvador
🇸🇽 Sint Maarten
🇸🇾 Syria
🇸🇿 Swaziland
🇹🇦 Tristan Da Cunha
🇹🇨 Turks & Caicos Islands
🇹🇩 Chad
🇹🇫 French Southern Territories
🇹🇬 Togo
🇹🇭 Thailand
🇹🇯 Tajikistan
🇹🇰 Tokelau
🇹🇱 Timor-Leste
🇹🇲 Turkmenistan
🇹🇳 Tunisia
🇹🇴 Tonga
🇹🇷 Turkey
🇹🇹 Trinidad & Tobago
🇹🇻 Tuvalu
🇹🇼 Taiwan
🇹🇿 Tanzania
🇺🇦 Ukraine
🇺🇬 Uganda
🇺🇲 U.S. Outlying Islands
🇺🇳 United Nations
🇺🇸 United States
🇺🇾 Uruguay
🇺🇿 Uzbekistan
🇻🇦 Vatican City
🇻🇨 St. Vincent & Grenadines
🇻🇪 Venezuela
🇻🇬 British Virgin Islands
🇻🇮 U.S. Virgin Islands
🇻🇳 Vietnam
🇻🇺 Vanuatu
🇼🇫 Wallis & Futuna
🇼🇸 Samoa
🇽🇰 Kosovo
🇾🇪 Yemen
🇾🇹 Mayotte
🇿🇦 South Africa
🇿🇲 Zambia
🇿🇼 Zimbabwe
🏴󠁧󠁢󠁥󠁮󠁧󠁿 England
🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland
🏴󠁧󠁢󠁷󠁬󠁳󠁿 Wales
🥆 Rifle
🤻 Modern Pentathlon
🇦 Regional Indicator Symbol Letter A
🇧 Regional Indicator Symbol Letter B
🇨 Regional Indicator Symbol Letter C
🇩 Regional Indicator Symbol Letter D
🇪 Regional Indicator Symbol Letter E
🇫 Regional Indicator Symbol Letter F
🇬 Regional Indicator Symbol Letter G
🇭 Regional Indicator Symbol Letter H
🇮 Regional Indicator Symbol Letter I
🇯 Regional Indicator Symbol Letter J
🇰 Regional Indicator Symbol Letter K
🇱 Regional Indicator Symbol Letter L
🇲 Regional Indicator Symbol Letter M
🇳 Regional Indicator Symbol Letter N
🇴 Regional Indicator Symbol Letter O
🇵 Regional Indicator Symbol Letter P
🇶 Regional Indicator Symbol Letter Q
🇷 Regional Indicator Symbol Letter R
🇸 Regional Indicator Symbol Letter S
🇹 Regional Indicator Symbol Letter T
🇺 Regional Indicator Symbol Letter U
🇻 Regional Indicator Symbol Letter V
🇼 Regional Indicator Symbol Letter W
🇽 Regional Indicator Symbol Letter X
🇾 Regional Indicator Symbol Letter Y
🇿 Regional Indicator Symbol Letter Z
🐱‍🏍 Stunt Cat
🐱‍🚀 Astro Cat
🐱‍🐉 Dino Cat
🐱‍💻 Hacker Cat
🐱‍👤 Ninja Cat
🐱‍👓 Hipster Cat
◯‍◯‍◯‍◯‍◯ Olympic Rings
♴ Recycling Symbol for Type-2 Plastics
🖹 Document with Text
󠁨 Tag Latin Small Letter H
⚮ Divorce Symbol
⛶ Square Four Corners
󠁗 Tag Latin Capital Letter W
⚌ Digram for Greater Yang
🛆 Triangle with Rounded Corners
⚄ Die Face-5
🛦 Up-Pointing Military Airplane
⚆ White Circle with Dot Right
👩‍👦‍👶 Family: Woman, Boy, Baby
⚁ Die Face-2
⚐ White Flag
☗ Black Shogi Piece
👨‍👩‍👶‍👶 Family: Man, Woman, Baby, Baby
⚃ Die Face-4
☈ Thunderstorm
🀥 Mahjong Tile Chrysanthemum
⚂ Die Face-3
👨‍👩‍👧‍👶 Family: Man, Woman, Girl, Baby
⚬ Medium Small White Circle
☴ Trigram for Wind
⛛ Heavy White Down-Pointing Triangle
♳ Recycling Symbol for Type-1 Plastics
👨‍👨‍👶‍👦 Family: Man, Man, Baby, Boy
⛟ Black Truck
⚟ Three Lines Converging Left
♡ White Heart Suit
󠀫 Tag Plus Sign
☱ Trigram for Lake
♩ Quarter Note
⚅ Die Face-6
♱ East Syriac Cross
⚏ Digram for Greater Yin
♙ White Chess Pawn
👩‍👩‍👦‍👶 Family: Woman, Woman, Boy, Baby
♆ Neptune
♚ Black Chess King
⚞ Three Lines Converging Right
♇ Pluto
󠀥 Tag Percent Sign
♖ White Chess Rook
♕ White Chess Queen
👩‍👩‍👶‍👧 Family: Woman, Woman, Baby, Girl
߷ NKo Symbol Gbakurunen
󠁇 Tag Latin Capital Letter G
󠁡 Tag Latin Small Letter a
🎔 Heart with Tip On the Left
♁ Earth
󠁉 Tag Latin Capital Letter I
󠁬 Tag Latin Small Letter L
🎝 Beamed Descending Musical Notes
♄ Saturn
☖ White Shogi Piece
👨‍👨‍👧‍👶 Family: Man, Man, Girl, Baby
🕴️‍♀️ Woman in Business Suit Levitating
♅ Uranus
☵ Trigram for Water
⚝ Outlined White Star
☙ Reversed Rotated Floral Heart Bullet
⛮ Gear with Handles
󠁛 Tag Left Square Bracket
⛯ Map Symbol for Lighthouse
☤ Caduceus
🕾 White Touchtone Telephone
☡ Caution Sign
♪ Eighth Note
󠀻 Tag Semicolon
☨ Cross of Lorraine
☲ Trigram for Fire
☧ Chi Rho
⛋ White Diamond In Square
󠁘 Tag Latin Capital Letter X
☐ Ballot Box
🀚 Mahjong Tile Two of Circles
🖠 Sideways Black Up Pointing Index
★ Black Star
⛦ Left-Handed Interlaced Pentagram
♝ Black Chess Bishop
🕮 Book
👨‍👨‍👶 Family: Man, Man, Baby
󠁮 Tag Latin Small Letter N
👩‍👨‍👦‍👶 Family: Woman, Man, Boy, Baby
👨‍👦‍👶 Family: Man, Boy, Baby
♽ Partially-Recycled Paper Symbol
👩‍👶‍👧 Family: Woman, Baby, Girl
🖛 Sideways Black Right Pointing Index
󠀢 Tag Quotation Mark
⚎ Digram for Lesser Yang
⚊ Monogram for Yang
👨‍👧‍👶 Family: Man, Girl, Baby
⛒ Circled Crossing Lanes
󠁁 Tag Latin Capital Letter a
♼ Recycled Paper Symbol
⚍ Digram for Lesser Yin
🕄 Notched Right Semicircle with Three Dots
🖀 Telephone On Top of Modem
☒ Ballot Box with X
♭ Music Flat Sign
👩‍👨‍👦‍👦 Family: Woman, Man, Boy, Boy
2️ Digit Two
󠁐 Tag Latin Capital Letter P
♮ Music Natural Sign
♬ Beamed Sixteenth Notes
👩‍👩‍👶‍👦 Family: Woman, Woman, Baby, Boy
⚨ Vertical Male with Stroke Sign
👩‍👨‍👶‍👶 Family: Woman, Man, Baby, Baby
₿ Bitcoin Sign
🖡 Sideways Black Down Pointing Index
👩‍👨‍👧 Family: Woman, Man, Girl
☏ White Telephone
♔ White Chess King
 Beats 1 Logo
☽ First Quarter Moon
🀈 Mahjong Tile Two of Characters
☛ Black Right Pointing Index
♛ Black Chess Queen
󠁖 Tag Latin Capital Letter V
👩‍👨‍👧‍👶 Family: Woman, Man, Girl, Baby
⚢ Doubled Female Sign
☻ Black Smiling Face
☚ Black Left Pointing Index
☭ Hammer and Sickle
☾ Last Quarter Moon
⛧ Inverted Pentagram
🎕 Bouquet of Flowers
⛼ Headstone Graveyard Symbol
⛆ Rain
👨‍❤️‍👩 Couple With Heart - Man, Woman
☍ Opposition
👩‍👨‍👧‍👦 Family: Woman, Man, Girl, Boy
☫ Farsi Symbol
☌ Conjunction
☊ Ascending Node
☋ Descending Node
⛣ Heavy Circle with Stroke and Two Dots Above
👨‍👨‍👦‍👧 Family: Man, Man, Boy, Girl
🀢 Mahjong Tile Plum
⛬ Historic Site
‍ Zero Width Joiner
󠀲 Tag Digit Two
⛡ Restricted Left Entry-2
🛱 Oncoming Fire Engine
🖈 Black Pushpin
󠀠 Tag Space
👩‍👶‍👦 Family: Woman, Baby, Boy
♞ Black Chess Knight
🖫 White Hard Shell Floppy Disk
🗭 Right Thought Bubble
🖗 White Down Pointing Left Hand Index
🛨 Up-Pointing Small Airplane
⛫ Castle
☇ Lightning
☉ Sun
👨‍❤️‍💋‍👩 Kiss - Man, Woman
⚳ Ceres
🖑 Reversed Raised Hand with Fingers Splayed
⛤ Pentagram
🀁 Mahjong Tile South Wind
⛨ Black Cross On Shield
󠁼 Tag Vertical Line
⛉ Turned White Shogi Piece
󠁅 Tag Latin Capital Letter E
⛘ Black Left Lane Merge
⚦ Male with Stroke Sign
👩‍👨‍👦‍👧 Family: Woman, Man, Boy, Girl
⚹ Sextile
󠁓 Tag Latin Capital Letter S
⛠ Restricted Left Entry-1
⛜ Left Closed Entry
󠁃 Tag Latin Capital Letter C
⛌ Crossing Lanes
👩‍👶 Family: Woman, Baby
⚴ Pallas
🗩 Right Speech Bubble
⛝ Squared Saltire
♢ White Diamond Suit
⛂ Black Draughts Man
⛚ Drive Slow Sign
🕽 Right Hand Telephone Receiver
🀤 Mahjong Tile Bamboo
⛙ White Left Lane Merge
⚣ Doubled Male Sign
⛃ Black Draughts King
⛇ Black Snowman
0️ Digit Zero
3️ Digit Three
⛢ Astronomical Symbol for Uranus
󠁽 Tag Right Curly Bracket
⚼ Sesquiquadrate
☼ White Sun with Rays
󠀧 Tag Apostrophe
⛁ White Draughts King
⛀ White Draughts Man
⚿ Squared Key
⚸ Black Moon Lilith
⚤ Interlocked Female and Male Sign
⚲ Neuter
⚻ Quincunx
󠁏 Tag Latin Capital Letter O
⚺ Semisextile
♲ Universal Recycling Symbol
⚵ Juno
🀒 Mahjong Tile Three of Bamboos
󠁆 Tag Latin Capital Letter F
⚶ Vesta
⚩ Horizontal Male with Stroke Sign
👩‍👦‍👧 Family: Woman, Boy, Girl
󠁾 Tag Tilde
🖃 Stamped Envelope
🀫 Mahjong Tile Back
󠀤 Tag Dollar Sign
🔿 Upper Right Shadowed White Circle
󠀭 Tag Hyphen-Minus
⚧ Male with Stroke and Male and Female Sign
🀉 Mahjong Tile Three of Characters
󠁠 Tag Grave Accent
⚭ Marriage Symbol
󠁕 Tag Latin Capital Letter U
󠁀 Tag Commercial at
👨‍👶‍👦 Family: Man, Baby, Boy
󠁶 Tag Latin Small Letter V
🕂 Cross Pommee
󠀮 Tag Full Stop
🛪 Northeast-Pointing Airplane
🖅 Flying Envelope
🕱 Black Skull and Crossbones
🗶 Ballot Bold Script X
󠁫 Tag Latin Small Letter K
󠁝 Tag Right Square Bracket
󠁋 Tag Latin Capital Letter K
🖘 Sideways White Left Pointing Index
🖁 Clamshell Mobile Phone
🖏 Turned Ok Hand Sign
󠁎 Tag Latin Capital Letter N
🀂 Mahjong Tile West Wind
󠁟 Tag Low Line
🗴 Ballot Script X
6️ Digit Six
🕈 Celtic Cross
🕻 Left Hand Telephone Receiver
🕅 Symbol for Marks Chapter
❥ Rotated Heavy Black Heart Bullet
󠀿 Tag Question Mark
󠀬 Tag Comma
🖒 Reversed Thumbs Up Sign
󠁌 Tag Latin Capital Letter L
󠁄 Tag Latin Capital Letter D
🀠 Mahjong Tile Eight of Circles
󠁸 Tag Latin Small Letter X
🕲 No Piracy
️ Variation Selector-16
♹ Recycling Symbol for Type-7 Plastics
🕀 Circled Cross Pommee
☥ Ankh
🎘 Musical Keyboard with Jacks
👨‍👩‍👦‍👧 Family: Man, Woman, Boy, Girl
👨‍👶‍👧 Family: Man, Baby, Girl
󠀰 Tag Digit Zero
🀨 Mahjong Tile Autumn
󠁹 Tag Latin Small Letter Y
⚷ Chiron
󠀺 Tag Colon
🌢 Black Droplet
🖟 Sideways White Down Pointing Index
🕿 Black Touchtone Telephone
🖞 Sideways White Up Pointing Index
🖚 Sideways Black Left Pointing Index
🀕 Mahjong Tile Six of Bamboos
󠁂 Tag Latin Capital Letter B
🖉 Lower Left Pencil
⛍ Disabled Car
🀆 Mahjong Tile White Dragon
🎜 Beamed Ascending Musical Notes
👩‍👨‍👶‍👦 Family: Woman, Man, Baby, Boy
5️ Digit Five
🖶 Printer Icon
👩‍👨‍👶 Family: Woman, Man, Baby
8️ Digit Eight
🗲 Lightning Mood
👨‍👨‍👦‍👶 Family: Man, Man, Boy, Baby
🖴 Hard Disk
🖮 Wired Keyboard
🗫 Three Speech Bubbles
󠁪 Tag Latin Small Letter J
⛖ Black Two-Way Left Way Traffic
👨‍👩‍👦‍👶 Family: Man, Woman, Boy, Baby
󠁙 Tag Latin Capital Letter Y
🕪 Right Speaker with Three Sound Waves
🕫 Bullhorn
🗋 Empty Document
🕇 Heavy Latin Cross
👩‍👨‍👶‍👧 Family: Woman, Man, Baby, Girl
󠁺 Tag Latin Small Letter Z
🀖 Mahjong Tile Seven of Bamboos
🀡 Mahjong Tile Nine of Circles
🕩 Right Speaker with One Sound Wave
🀩 Mahjong Tile Winter
🔾 Lower Right Shadowed White Circle
🀙 Mahjong Tile One of Circles
🗰 Mood Bubble
🀘 Mahjong Tile Nine of Bamboos
🀧 Mahjong Tile Summer
🀔 Mahjong Tile Five of Bamboos
🀦 Mahjong Tile Spring
󠁈 Tag Latin Capital Letter H
🗹 Ballot Box with Bold Check
🀗 Mahjong Tile Eight of Bamboos
🀣 Mahjong Tile Orchid
⚯ Unmarried Partnership Symbol
🖝 Black Right Pointing Backhand Index
🀊 Mahjong Tile Four of Characters
🏶 Black Rosette
󠀽 Tag Equals Sign
󠁢 Tag Latin Small Letter B
🀓 Mahjong Tile Four of Bamboos
🀑 Mahjong Tile Two of Bamboos
🕆 White Latin Cross
🗱 Lightning Mood Bubble
󠁻 Tag Left Curly Bracket
1️ Digit One
👩‍👧‍👶 Family: Woman, Girl, Baby
👩‍👨‍👦 Family: Woman, Man, Boy
󠀶 Tag Digit Six
🖺 Document with Text and Picture
󠁤 Tag Latin Small Letter D
🗙 Cancellation X
📾 Portable Stereo
🖣 Black Down Pointing Backhand Index
🀋 Mahjong Tile Five of Characters
🗛 Decrease Font Size Symbol
🛉 Boys Symbol
☬ Adi Shakti
🗁 Open Folder
👨‍👨‍👶‍👧 Family: Man, Man, Baby, Girl
🀪 Mahjong Tile Joker
🗸 Light Check Mark
🛈 Circled Information Source
🛊 Girls Symbol
🖾 Frame with an X
⛾ Cup On Black Square
🗍 Empty Pages
🗐 Pages
🖽 Frame with Tiles
🀝 Mahjong Tile Five of Circles
🗅 Empty Note
☶ Trigram for Mountain
⛞ Falling Diagonal In White Circle In Black Square
🗠 Stock Chart
󠁴 Tag Latin Small Letter T
👩‍👩‍👶 Family: Woman, Woman, Baby
󠁔 Tag Latin Capital Letter T
👩‍👩‍👶‍👶 Family: Woman, Woman, Baby, Baby
🗖 Maximize
🗮 Left Anger Bubble
👨‍👩‍👶 Family: Man, Woman, Baby
🗧 Three Rays Right
🗦 Three Rays Left
🗔 Desktop Window
󠁳 Tag Latin Small Letter S
🗏 Page
🧕‍♀️ Woman With Headscarf
🗗 Overlap
 Apple Logo
🗥 Three Rays Below
🖔 Reversed Victory Hand
🗤 Three Rays Above
🖸 Optical Disc Icon
🗚 Increase Font Size Symbol
🖵 Screen
󠀨 Tag Left Parenthesis
🀀 Mahjong Tile East Wind
🗉 Note Page
🗕 Minimize
󠀪 Tag Asterisk
🏲 Black Pennant
🗌 Empty Page
🗈 Note
󠁥 Tag Latin Small Letter E
🖷 Fax Icon
🗎 Document
󠁰 Tag Latin Small Letter P
🀌 Mahjong Tile Six of Characters
󠀳 Tag Digit Three
󠀵 Tag Digit Five
⛥ Right-Handed Interlaced Pentagram
🗆 Empty Note Page
⚉ Black Circle with Two White Dots
󠀣 Tag Number Sign
🗀 Folder
󠁞 Tag Circumflex Accent
🀛 Mahjong Tile Three of Circles
👨‍👶 Family: Man, Baby
󠁱 Tag Latin Small Letter Q
󠁒 Tag Latin Capital Letter R
🗷 Ballot Box with Bold Script X
🖻 Document with Picture
👩‍👩‍👧‍👶 Family: Woman, Woman, Girl, Baby
🤵‍♀️ Woman in Tuxedo
👨‍👩‍👶‍👧 Family: Man, Woman, Baby, Girl
🕬 Bullhorn with Sound Waves
󠁯 Tag Latin Small Letter O
☟ White Down Pointing Index
⛗ White Two-Way Left Way Traffic
󠀷 Tag Digit Seven
7️ Digit Seven
󠀹 Tag Digit Nine
🖭 Tape Cartridge
*️ Asterisk
🖯 One Button Mouse
🖪 Black Hard Shell Floppy Disk
🖳 Old Personal Computer
⚑ Black Flag
󠁍 Tag Latin Capital Letter M
🕃 Notched Left Semicircle with Three Dots
🀍 Mahjong Tile Seven of Characters
🖰 Two Button Mouse
󠀾 Tag Greater-Than Sign
󠁭 Tag Latin Small Letter M
🖧 Three Networked Computers
🗇 Empty Note Pad
♜ Black Chess Rook
♘ White Chess Knight
🀇 Mahjong Tile One of Characters
⛭ Gear Without Hub
⚀ Die Face-1
🖩 Pocket Calculator
☳ Trigram for Thunder
👩‍👨‍👧‍👧 Family: Woman, Man, Girl, Girl
󠀦 Tag Ampersand
👩‍👶‍👶 Family: Woman, Baby, Baby
☓ Saltire
󠀯 Tag Solidus
🀎 Mahjong Tile Eight of Characters
🖙 Sideways White Right Pointing Index
🛲 Diesel Locomotive
♯ Music Sharp Sign
󠀼 Tag Less-Than Sign
󠁜 Tag Reverse Solidus
󠁑 Tag Latin Capital Letter Q
♧ White Club Suit
♺ Recycling Symbol for Generic Materials
👨‍👩‍👶‍👦 Family: Man, Woman, Baby, Boy
🖆 Pen Over Stamped Envelope
👨‍👨‍👶‍👶 Family: Man, Man, Baby, Baby
󠁧 Tag Latin Small Letter G
🗵 Ballot Box with Script X
☩ Cross of Jerusalem
♤ White Spade Suit
🀐 Mahjong Tile One of Bamboos
⚥ Male and Female Sign
♰ West Syriac Cross
🗊 Note Pad
⚈ Black Circle with White Dot Right
⚋ Monogram for Yin
⚚ Staff of Hermes
 Shibuya
🖄 Envelope with Lightning
♃ Jupiter
🗢 Lips
🗘 Clockwise Right and Left Semicircle Arrows
🖢 Black Up Pointing Backhand Index
🖦 Keyboard and Mouse
⛿ White Flag with Horizontal Middle Black Stripe
9️ Digit Nine
🖿 Black Folder
🕨 Right Speaker
⚇ White Circle with Two Dots
⃣ Combining Enclosing Keycap
󠁷 Tag Latin Small Letter W
4️ Digit Four
#️ Number Sign
󠁵 Tag Latin Small Letter U
🀟 Mahjong Tile Seven of Circles
🏱 White Pennant
🖂 Back of Envelope
🀃 Mahjong Tile North Wind
👩‍👩‍👦‍👧 Family: Woman, Woman, Boy, Girl
🌣 White Sun
🕁 Cross Pommee with Half-Circle Below
👨‍👦‍👧 Family: Man, Boy, Girl
󠁦 Tag Latin Small Letter F
👨‍👶‍👶 Family: Man, Baby, Baby
󠀸 Tag Digit Eight
✐ Upper Right Pencil
✎ Lower Right Pencil
🖜 Black Left Pointing Backhand Index
🀜 Mahjong Tile Four of Circles
🀞 Mahjong Tile Six of Circles
☷ Trigram for Earth
󠁊 Tag Latin Capital Letter J
󠀩 Tag Right Parenthesis
🗟 Page with Circled Text
🖓 Reversed Thumbs Down Sign
🗪 Two Speech Bubbles
☿️ Mercury
☰ Trigram for Heaven
⚘ Flower
󠁿 Cancel Tag
󠀱 Tag Digit One
󠀴 Tag Digit Four
🖬 Soft Shell Floppy Disk
♫ Beamed Eighth Notes
🛇 Prohibited Sign
󠁚 Tag Latin Capital Letter Z
⛐ Car Sliding
⛊ Turned Black Shogi Piece
🀅 Mahjong Tile Green Dragon
󠁣 Tag Latin Small Letter C
🀏 Mahjong Tile Nine of Characters
⛕ Alternate One-Way Left Way Traffic
☜ White Left Pointing Index
🧕‍♂️ Man With Headscarf
🕭 Ringing Bell
󠀡 Tag Exclamation Mark
🗬 Left Thought Bubble
󠁩 Tag Latin Small Letter I
♗ White Chess Bishop
🛧 Up-Pointing Airplane
🕼 Telephone Receiver with Page
☞ White Right Pointing Index
🖎 Left Writing Hand
󠁲 Tag Latin Small Letter R
☛🏻 Black Right Pointing Index + Emoji Modifier Fitzpatrick Type-1-2
☞🏻 White Right Pointing Index + Emoji Modifier Fitzpatrick Type-1-2
☟🏻 White Down Pointing Index + Emoji Modifier Fitzpatrick Type-1-2
🖑🏻 Reversed Raised Hand with Fingers Splayed + Emoji Modifier Fitzpatrick Type-1-2
☚🏻 Black Left Pointing Index + Emoji Modifier Fitzpatrick Type-1-2
🖎🏻 Left Writing Hand + Emoji Modifier Fitzpatrick Type-1-2
🖓🏻 Reversed Thumbs Down Sign + Emoji Modifier Fitzpatrick Type-1-2
🖔🏻 Reversed Victory Hand + Emoji Modifier Fitzpatrick Type-1-2
🖒🏻 Reversed Thumbs Up Sign + Emoji Modifier Fitzpatrick Type-1-2
☜🏻 White Left Pointing Index + Emoji Modifier Fitzpatrick Type-1-2
"""

rofi = Popen(
    args=[
        'rofi',
        '-dmenu',
        '-i',
        '-multi-select',
        '-p',
        ' 😀   ',
        '-kb-custom-1',
        'Alt+c'
    ],
    stdin=PIPE,
    stdout=PIPE
)
(stdout, stderr) = rofi.communicate(input=emojis.encode('utf-8'))

if rofi.returncode == 1:
    exit()
else:
    for line in stdout.splitlines():
        emoji = line.split()[0]
        if rofi.returncode == 0:
            Popen(
                args=[
                    'xdotool',
                    'type',
                    '--clearmodifiers',
                    emoji.decode('utf-8')
                ]
            )
        elif rofi.returncode == 10:
            xsel = Popen(
                args=[
                    'xsel',
                    '-i',
                    '-b'
                ],
                stdin=PIPE
            )
            xsel.communicate(input=emoji)

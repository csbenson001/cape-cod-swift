import Foundation

// MARK: - Mom Tip Data

/// Curated tips for the Mom's Must-Have Guide.
enum MomTipData {

    // MARK: - Beach Day Prep

    static let beachDayTips: [MomTip] = [
        MomTip(
            icon: "sun.max.fill",
            title: "Arrive before 9 AM",
            detail: "Beach parking fills up fast in summer. Nauset and Coast Guard lots are usually full by 10 AM."
        ),
        MomTip(
            icon: "umbrella.fill",
            title: "Bring a beach tent",
            detail: "Umbrellas blow away in Cape wind. A pop-up tent keeps little ones shaded and sand-free during nap time."
        ),
        MomTip(
            icon: "drop.fill",
            title: "Pack frozen water bottles",
            detail: "They double as ice packs for snacks and provide ice-cold water as they melt throughout the day."
        ),
        MomTip(
            icon: "shoe.fill",
            title: "Water shoes are a must",
            detail: "The sand gets scorching hot and some beaches have rocky areas. Water shoes save tiny feet."
        ),
        MomTip(
            icon: "cross.case.fill",
            title: "Baby powder removes sand",
            detail: "Sprinkle it on sandy skin before getting in the car. It absorbs moisture and sand falls right off."
        ),
        MomTip(
            icon: "leaf.fill",
            title: "Check tide times",
            detail: "Low tide creates amazing tide pools for kids to explore. Use the app's tide feature to plan your visit."
        ),
        MomTip(
            icon: "cart.fill",
            title: "Use a beach wagon",
            detail: "Between towels, toys, snacks, and chairs, a collapsible wagon is a game-changer for beach hauls."
        )
    ]

    // MARK: - Rainy Day Plans

    static let rainyDayTips: [MomTip] = [
        MomTip(
            icon: "building.columns.fill",
            title: "Cape Cod Museum of Natural History",
            detail: "Interactive exhibits kids love, plus nature trails. Located in Brewster with indoor and outdoor activities."
        ),
        MomTip(
            icon: "fish.fill",
            title: "Woods Hole Science Aquarium",
            detail: "Free admission! Small but fascinating aquarium with touch tanks that kids adore."
        ),
        MomTip(
            icon: "paintpalette.fill",
            title: "Creative Arts Center",
            detail: "Drop-in art classes for kids in Chatham. Perfect rainy afternoon activity for ages 4+."
        ),
        MomTip(
            icon: "theatermasks.fill",
            title: "Cape Cinema",
            detail: "Historic art deco movie theater in Dennis. The ceiling mural alone is worth the visit."
        ),
        MomTip(
            icon: "cup.and.saucer.fill",
            title: "Hot Chocolate Sparrow",
            detail: "Famous coffee shop in Orleans with incredible hot chocolate. Kids love the cozy atmosphere."
        ),
        MomTip(
            icon: "book.fill",
            title: "Library Story Time",
            detail: "Most Cape libraries offer free story time programs. Check Chatham, Wellfleet, or Brewster libraries."
        ),
        MomTip(
            icon: "puzzlepiece.fill",
            title: "Game Room at resorts",
            detail: "Many Cape resorts and hotels have game rooms. The Cape Codder in Hyannis has a great indoor pool too."
        ),
        MomTip(
            icon: "cart.fill",
            title: "Chatham Candy Manor",
            detail: "Watch candy being made and sample treats. A sweet rainy day pit stop the whole family enjoys."
        )
    ]

    // MARK: - Kid-Friendly Dining

    static let kidFriendlyDiningTips: [MomTip] = [
        MomTip(
            icon: "fork.knife",
            title: "Arnold's Lobster & Clam Bar",
            detail: "Eastham classic with outdoor seating, mini golf nearby, and a kids menu. The ice cream is incredible."
        ),
        MomTip(
            icon: "fish.fill",
            title: "The Lobster Pot",
            detail: "Provincetown waterfront dining. Yes it's touristy, but kids love watching boats and the food is legit."
        ),
        MomTip(
            icon: "flame.fill",
            title: "Seafood Sam's",
            detail: "Multiple locations, casual atmosphere, generous portions. Perfect for sandy, sunburned kids."
        ),
        MomTip(
            icon: "takeoutbag.and.cup.and.straw.fill",
            title: "Box Lunch",
            detail: "Famous pita rollwiches in multiple towns. Quick, affordable, and easy to eat at the beach."
        ),
        MomTip(
            icon: "birthday.cake.fill",
            title: "Sundae School",
            detail: "Best ice cream on the Cape with locations in Dennis and Orleans. The homemade waffle cones are heaven."
        ),
        MomTip(
            icon: "clock.fill",
            title: "Eat early",
            detail: "Cape restaurants get packed after 6 PM in summer. Aim for 5 PM dinner to avoid waits and cranky kids."
        )
    ]

    // MARK: - Packing Essentials

    static let packingTips: [MomTip] = [
        MomTip(
            icon: "tshirt.fill",
            title: "Layers, layers, layers",
            detail: "Cape weather changes fast. Pack light sweaters even in August - evenings get cool near the water."
        ),
        MomTip(
            icon: "bandage.fill",
            title: "First aid kit + Benadryl",
            detail: "Jellyfish stings, bug bites, and sunburn happen. Pack vinegar spray for jellyfish and aloe for burns."
        ),
        MomTip(
            icon: "drop.fill",
            title: "Reef-safe sunscreen",
            detail: "Protect the ocean and your kids. Reapply every 2 hours and after swimming."
        ),
        MomTip(
            icon: "flashlight.on.fill",
            title: "Flashlights for night walks",
            detail: "Evening beach walks are magical. Headlamps keep hands free for collecting shells."
        ),
        MomTip(
            icon: "washer.fill",
            title: "Mesh laundry bag",
            detail: "Perfect for collecting shells and shaking out sandy beach toys. Saves your car from the sand invasion."
        ),
        MomTip(
            icon: "iphone.gen1",
            title: "Waterproof phone pouch",
            detail: "You'll want photos at the beach without worrying about water damage. A $10 pouch saves your phone."
        ),
        MomTip(
            icon: "ant.fill",
            title: "Bug spray for evenings",
            detail: "Mosquitoes come out at dusk near marshes. DEET-free options work well for kids."
        )
    ]

    // MARK: - Hidden Gems for Families

    static let hiddenGemsTips: [MomTip] = [
        MomTip(
            icon: "pawprint.fill",
            title: "Wellfleet Bay Wildlife Sanctuary",
            detail: "Audubon sanctuary with easy trails, salt marsh boardwalks, and nature programs for kids."
        ),
        MomTip(
            icon: "sailboat.fill",
            title: "Aselton Park in Hyannis",
            detail: "Playground right on the harbor. Kids play while you watch ferries come and go. Free!"
        ),
        MomTip(
            icon: "bicycle",
            title: "Cape Cod Rail Trail",
            detail: "Paved 25-mile bike path. Do a short section with kids - the Nickerson State Park area is flattest."
        ),
        MomTip(
            icon: "seal.fill",
            title: "Chatham Fish Pier",
            detail: "Watch fishermen unload their catch around 2-3 PM. Seals often hang around the pier too!"
        ),
        MomTip(
            icon: "star.fill",
            title: "First Encounter Beach at sunset",
            detail: "Eastham's gorgeous bay beach. Shallow water, stunning sunsets, and historical significance."
        ),
        MomTip(
            icon: "leaf.fill",
            title: "Nickerson State Park",
            detail: "Freshwater ponds perfect for toddlers - no waves, no salt, warm water. Flax Pond is the best."
        ),
        MomTip(
            icon: "binoculars.fill",
            title: "Fort Hill in Eastham",
            detail: "Easy walk with incredible views. The Red Maple Swamp trail is stroller-friendly and beautiful."
        ),
        MomTip(
            icon: "tortoise.fill",
            title: "Cape Cod Museum of Art",
            detail: "Free family art activities on select Saturdays. Beautiful grounds for kids to run around."
        )
    ]
}

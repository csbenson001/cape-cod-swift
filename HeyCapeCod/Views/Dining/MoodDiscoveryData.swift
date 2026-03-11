import Foundation

// swiftlint:disable type_body_length file_length

// MARK: - Cape Cod Region

enum CapeCodRegion: String, CaseIterable, Identifiable {
    case upperCape = "Upper Cape"
    case midCape = "Mid Cape"
    case lowerCape = "Lower Cape"
    case outerCape = "Outer Cape"

    var id: String { rawValue }

    var towns: [String] {
        switch self {
        case .upperCape: ["Sandwich", "Bourne", "Falmouth", "Mashpee"]
        case .midCape: ["Barnstable", "Hyannis", "Dennis", "Yarmouth"]
        case .lowerCape: ["Harwich", "Chatham", "Brewster", "Orleans"]
        case .outerCape: ["Eastham", "Wellfleet", "Truro", "Provincetown"]
        }
    }

    var icon: String {
        switch self {
        case .upperCape: "arrow.triangle.branch"
        case .midCape: "building.2.fill"
        case .lowerCape: "sailboat.fill"
        case .outerCape: "sun.horizon.fill"
        }
    }
}

// MARK: - Mood Category

enum MoodCategory: String, CaseIterable, Identifiable {
    case iceCream = "iceCream"
    case lobsterRoll = "lobsterRoll"
    case friedClams = "friedClams"
    case cocktails = "cocktails"
    case beachBar = "beachBar"
    case pizza = "pizza"
    case breakfast = "breakfast"
    case coffee = "coffee"
    case oysters = "oysters"
    case tacos = "tacos"
    case chowder = "chowder"
    case fineDining = "fineDining"
    case bakery = "bakery"
    case seafoodShack = "seafoodShack"
    case burgers = "burgers"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .iceCream: "Ice Cream"
        case .lobsterRoll: "Lobster Roll"
        case .friedClams: "Fried Clams"
        case .cocktails: "Cocktails"
        case .beachBar: "Beach Bar"
        case .pizza: "Pizza"
        case .breakfast: "Breakfast"
        case .coffee: "Coffee"
        case .oysters: "Oysters"
        case .tacos: "Tacos"
        case .chowder: "Chowder"
        case .fineDining: "Fine Dining"
        case .bakery: "Bakery"
        case .seafoodShack: "Seafood Shack"
        case .burgers: "Burgers"
        }
    }

    var icon: String {
        switch self {
        case .iceCream: "snowflake"
        case .lobsterRoll: "fork.knife"
        case .friedClams: "flame.fill"
        case .cocktails: "wineglass.fill"
        case .beachBar: "sun.max.fill"
        case .pizza: "circle.grid.cross.fill"
        case .breakfast: "sunrise.fill"
        case .coffee: "cup.and.saucer.fill"
        case .oysters: "drop.fill"
        case .tacos: "leaf.fill"
        case .chowder: "cloud.fog.fill"
        case .fineDining: "star.fill"
        case .bakery: "gift.fill"
        case .seafoodShack: "water.waves"
        case .burgers: "flame"
        }
    }

    var color: String {
        switch self {
        case .iceCream: "seafoam"
        case .lobsterRoll: "lobsterRed"
        case .friedClams: "sandbarYellow"
        case .cocktails: "sunsetOrange"
        case .beachBar: "oceanBlue"
        case .pizza: "cranberry"
        case .breakfast: "sandbarYellow"
        case .coffee: "driftwood"
        case .oysters: "seafoam"
        case .tacos: "duneGrass"
        case .chowder: "sand"
        case .fineDining: "deepNavy"
        case .bakery: "sunsetOrange"
        case .seafoodShack: "oceanBlue"
        case .burgers: "lobsterRed"
        }
    }

    /// Number of spots to visit to complete the quest for this mood.
    var questGoal: Int {
        switch self {
        case .iceCream: 5
        case .lobsterRoll: 5
        case .friedClams: 4
        case .cocktails: 4
        case .beachBar: 3
        case .pizza: 4
        case .breakfast: 4
        case .coffee: 5
        case .oysters: 3
        case .tacos: 3
        case .chowder: 5
        case .fineDining: 3
        case .bakery: 3
        case .seafoodShack: 4
        case .burgers: 4
        }
    }

    var questTitle: String {
        "\(displayName) Quest"
    }

    var questSubtitle: String {
        "Try \(questGoal) \(displayName.lowercased()) spots!"
    }
}

// MARK: - Mood Spot

struct MoodSpot: Identifiable {
    let id: String
    let name: String
    let town: String
    let region: CapeCodRegion
    let categories: [MoodCategory]
    let rating: Double
    let priceLevel: Int
    let bestFor: String
    let topItems: [String: String]
    let description: String
}

// MARK: - Mood Spots Data

enum MoodDiscoveryData {

    static let allSpots: [MoodSpot] = [

        // MARK: - Upper Cape

        MoodSpot(
            id: "mood-pickle-jar", name: "Pickle Jar Kitchen", town: "Falmouth", region: .upperCape,
            categories: [.breakfast, .bakery, .coffee],
            rating: 4.7, priceLevel: 2, bestFor: "Best brunch on the Upper Cape",
            topItems: [
                MoodCategory.breakfast.rawValue: "Lobster Benedict",
                MoodCategory.bakery.rawValue: "Blueberry Scone",
                MoodCategory.coffee.rawValue: "Lavender Latte",
            ],
            description: "Farm-to-table brunch spot with creative twists on classics."),

        MoodSpot(
            id: "mood-clam-shack-falmouth", name: "The Clam Shack", town: "Falmouth", region: .upperCape,
            categories: [.friedClams, .lobsterRoll, .seafoodShack, .chowder],
            rating: 4.5, priceLevel: 2, bestFor: "Harborside fried seafood",
            topItems: [
                MoodCategory.friedClams.rawValue: "Whole Belly Clam Plate",
                MoodCategory.lobsterRoll.rawValue: "Classic Lobster Roll",
                MoodCategory.seafoodShack.rawValue: "Fish & Chips",
                MoodCategory.chowder.rawValue: "New England Clam Chowder",
            ],
            description: "Iconic harborside takeout with the freshest fried seafood around."),

        MoodSpot(
            id: "mood-glass-onion", name: "Glass Onion", town: "Falmouth", region: .upperCape,
            categories: [.fineDining, .cocktails],
            rating: 4.4, priceLevel: 3, bestFor: "Creative farm-to-table",
            topItems: [
                MoodCategory.fineDining.rawValue: "Pan-Seared Scallops",
                MoodCategory.cocktails.rawValue: "Seasonal Craft Cocktail",
            ],
            description: "American bistro with seasonal menus and creative cocktails."),

        MoodSpot(
            id: "mood-pie-in-the-sky", name: "Pie in the Sky Bakery", town: "Falmouth", region: .upperCape,
            categories: [.bakery, .coffee, .breakfast],
            rating: 4.6, priceLevel: 1, bestFor: "Morning pastries by the harbor",
            topItems: [
                MoodCategory.bakery.rawValue: "Cranberry Walnut Muffin",
                MoodCategory.coffee.rawValue: "House Drip Coffee",
                MoodCategory.breakfast.rawValue: "Egg Sandwich",
            ],
            description: "Beloved Woods Hole bakery with harbor views and fresh-baked everything."),

        MoodSpot(
            id: "mood-seafood-sams", name: "Seafood Sam's", town: "Sandwich", region: .upperCape,
            categories: [.friedClams, .lobsterRoll, .seafoodShack, .burgers],
            rating: 4.2, priceLevel: 1, bestFor: "Family-friendly seafood",
            topItems: [
                MoodCategory.friedClams.rawValue: "Clam Strip Basket",
                MoodCategory.lobsterRoll.rawValue: "Lobster Roll",
                MoodCategory.seafoodShack.rawValue: "Fish & Chips",
                MoodCategory.burgers.rawValue: "Classic Cheeseburger",
            ],
            description: "Family favorite near the canal with generous portions and fair prices."),

        MoodSpot(
            id: "mood-belfry-bistro", name: "Belfry Inn & Bistro", town: "Sandwich", region: .upperCape,
            categories: [.fineDining, .cocktails],
            rating: 4.6, priceLevel: 4, bestFor: "Dining in a restored church",
            topItems: [
                MoodCategory.fineDining.rawValue: "Duck Breast",
                MoodCategory.cocktails.rawValue: "Belfry Martini",
            ],
            description: "Fine dining beneath stained glass in a beautifully restored church."),

        MoodSpot(
            id: "mood-mashpee-commons-pizza", name: "Blaze Pizza", town: "Mashpee", region: .upperCape,
            categories: [.pizza],
            rating: 4.1, priceLevel: 1, bestFor: "Quick custom pies",
            topItems: [
                MoodCategory.pizza.rawValue: "Build-Your-Own Pizza",
            ],
            description: "Fast-casual custom pizzas at Mashpee Commons."),

        MoodSpot(
            id: "mood-ice-cream-sandwich", name: "Ice Cream Sandwich", town: "Sandwich", region: .upperCape,
            categories: [.iceCream],
            rating: 4.5, priceLevel: 1, bestFor: "Boardwalk ice cream stop",
            topItems: [
                MoodCategory.iceCream.rawValue: "Cookie Monster Sundae",
            ],
            description: "Charming shop near the boardwalk with homemade flavors."),

        MoodSpot(
            id: "mood-courtyard-bourne", name: "The Courtyard Restaurant", town: "Bourne", region: .upperCape,
            categories: [.breakfast, .burgers, .chowder],
            rating: 4.3, priceLevel: 2, bestFor: "Canal-side comfort food",
            topItems: [
                MoodCategory.breakfast.rawValue: "Eggs Benedict",
                MoodCategory.burgers.rawValue: "Canal Burger",
                MoodCategory.chowder.rawValue: "Quahog Chowder",
            ],
            description: "Casual dining near the Cape Cod Canal with hearty comfort food."),

        // MARK: - Mid Cape

        MoodSpot(
            id: "mood-pain-davignon", name: "Pain D'Avignon", town: "Hyannis", region: .midCape,
            categories: [.bakery, .breakfast, .coffee],
            rating: 4.6, priceLevel: 2, bestFor: "Artisan French bakery",
            topItems: [
                MoodCategory.bakery.rawValue: "Almond Croissant",
                MoodCategory.breakfast.rawValue: "Croque Monsieur",
                MoodCategory.coffee.rawValue: "Café Au Lait",
            ],
            description: "Award-winning French bakery with bistro dining and impeccable pastries."),

        MoodSpot(
            id: "mood-baxters", name: "Baxter's Boathouse Club", town: "Hyannis", region: .midCape,
            categories: [.beachBar, .cocktails, .lobsterRoll, .friedClams],
            rating: 4.4, priceLevel: 2, bestFor: "Dockside drinks & live music",
            topItems: [
                MoodCategory.beachBar.rawValue: "Frozen Rum Punch",
                MoodCategory.cocktails.rawValue: "Baxter's Margarita",
                MoodCategory.lobsterRoll.rawValue: "Lobster Roll",
                MoodCategory.friedClams.rawValue: "Fried Clam Plate",
            ],
            description: "Iconic harbor-front spot with casual dining and live summer entertainment."),

        MoodSpot(
            id: "mood-brazilian-grill", name: "Brazilian Grill", town: "Hyannis", region: .midCape,
            categories: [.fineDining, .cocktails],
            rating: 4.5, priceLevel: 3, bestFor: "Authentic rodizio experience",
            topItems: [
                MoodCategory.fineDining.rawValue: "Picanha (Top Sirloin)",
                MoodCategory.cocktails.rawValue: "Caipirinha",
            ],
            description: "All-you-can-eat Brazilian steakhouse with tableside carved meats."),

        MoodSpot(
            id: "mood-four-seas", name: "Four Seas Ice Cream", town: "Barnstable", region: .midCape,
            categories: [.iceCream],
            rating: 4.8, priceLevel: 1, bestFor: "Cape Cod's most beloved scoop",
            topItems: [
                MoodCategory.iceCream.rawValue: "Peach Ice Cream",
            ],
            description: "Since 1934 — the Cape's oldest and arguably best ice cream shop."),

        MoodSpot(
            id: "mood-captain-frostys", name: "Captain Frosty's", town: "Dennis", region: .midCape,
            categories: [.friedClams, .seafoodShack, .iceCream, .lobsterRoll],
            rating: 4.6, priceLevel: 1, bestFor: "Best fried clams on the mid-Cape",
            topItems: [
                MoodCategory.friedClams.rawValue: "Whole Belly Fried Clams",
                MoodCategory.seafoodShack.rawValue: "Fish & Chips",
                MoodCategory.iceCream.rawValue: "Soft Serve Twist",
                MoodCategory.lobsterRoll.rawValue: "Lobster Roll",
            ],
            description: "Order at the window, eat at picnic tables. Generations love this spot."),

        MoodSpot(
            id: "mood-skipper", name: "Skipper Restaurant", town: "Yarmouth", region: .midCape,
            categories: [.seafoodShack, .chowder, .cocktails],
            rating: 4.3, priceLevel: 2, bestFor: "Oceanfront sunsets since 1936",
            topItems: [
                MoodCategory.seafoodShack.rawValue: "Baked Stuffed Lobster",
                MoodCategory.chowder.rawValue: "Award-Winning Chowder",
                MoodCategory.cocktails.rawValue: "Sunset Cocktail",
            ],
            description: "Classic Cape Cod oceanfront dining on Nantucket Sound."),

        MoodSpot(
            id: "mood-sam-diego-dennis", name: "Sam Diego's", town: "Hyannis", region: .midCape,
            categories: [.tacos, .cocktails, .burgers],
            rating: 4.2, priceLevel: 2, bestFor: "Tex-Mex on Main Street",
            topItems: [
                MoodCategory.tacos.rawValue: "Fish Tacos",
                MoodCategory.cocktails.rawValue: "Frozen Margarita",
                MoodCategory.burgers.rawValue: "Southwest Burger",
            ],
            description: "Fun Tex-Mex with great margaritas in downtown Hyannis."),

        MoodSpot(
            id: "mood-pizza-barbone", name: "Pizza Barbone", town: "Hyannis", region: .midCape,
            categories: [.pizza],
            rating: 4.6, priceLevel: 2, bestFor: "Neapolitan pizza perfection",
            topItems: [
                MoodCategory.pizza.rawValue: "Margherita D.O.P.",
            ],
            description: "Wood-fired Neapolitan pizza with imported Italian ingredients."),

        MoodSpot(
            id: "mood-keltic-kitchen", name: "Keltic Kitchen", town: "Yarmouth", region: .midCape,
            categories: [.breakfast],
            rating: 4.5, priceLevel: 1, bestFor: "Legendary Cape breakfast",
            topItems: [
                MoodCategory.breakfast.rawValue: "Irish Benedict",
            ],
            description: "Huge portions and an Irish twist make this a breakfast institution."),

        MoodSpot(
            id: "mood-snowy-owl", name: "Snowy Owl Coffee Roasters", town: "Barnstable", region: .midCape,
            categories: [.coffee, .bakery],
            rating: 4.7, priceLevel: 2, bestFor: "Small-batch roasted perfection",
            topItems: [
                MoodCategory.coffee.rawValue: "Pour Over Single Origin",
                MoodCategory.bakery.rawValue: "Morning Bun",
            ],
            description: "Cape Cod's premier coffee roaster with a gorgeous cafe space."),

        // MARK: - Lower Cape

        MoodSpot(
            id: "mood-chatham-bars-inn", name: "Chatham Bars Inn", town: "Chatham", region: .lowerCape,
            categories: [.fineDining, .cocktails, .oysters],
            rating: 4.7, priceLevel: 4, bestFor: "Oceanfront elegance",
            topItems: [
                MoodCategory.fineDining.rawValue: "Pan-Seared Scallops",
                MoodCategory.cocktails.rawValue: "Signature Martini",
                MoodCategory.oysters.rawValue: "Local Oyster Platter",
            ],
            description: "Upscale oceanfront dining with farm-to-table menu and impeccable service."),

        MoodSpot(
            id: "mood-chatham-pier-fish", name: "Chatham Pier Fish Market", town: "Chatham", region: .lowerCape,
            categories: [.lobsterRoll, .friedClams, .seafoodShack, .chowder],
            rating: 4.6, priceLevel: 2, bestFor: "Fresh off the fishing boats",
            topItems: [
                MoodCategory.lobsterRoll.rawValue: "Classic Lobster Roll",
                MoodCategory.friedClams.rawValue: "Fried Clam Plate",
                MoodCategory.seafoodShack.rawValue: "Fish & Chips",
                MoodCategory.chowder.rawValue: "Clam Chowder",
            ],
            description: "Watch fishing boats unload while you eat the freshest seafood on the Cape."),

        MoodSpot(
            id: "mood-chatham-squire", name: "The Chatham Squire", town: "Chatham", region: .lowerCape,
            categories: [.burgers, .chowder, .beachBar],
            rating: 4.3, priceLevel: 2, bestFor: "Classic Cape pub since 1968",
            topItems: [
                MoodCategory.burgers.rawValue: "Squire Burger",
                MoodCategory.chowder.rawValue: "Award-Winning Chowder",
                MoodCategory.beachBar.rawValue: "Draft Beer",
            ],
            description: "A Chatham institution with classic pub atmosphere and great chowder."),

        MoodSpot(
            id: "mood-brewster-fish", name: "Brewster Fish House", town: "Brewster", region: .lowerCape,
            categories: [.fineDining, .seafoodShack],
            rating: 4.7, priceLevel: 3, bestFor: "Best-kept seafood secret",
            topItems: [
                MoodCategory.fineDining.rawValue: "Pan-Seared Scallops",
                MoodCategory.seafoodShack.rawValue: "Grilled Bluefish",
            ],
            description: "Tiny, beloved restaurant. No reservations — arrive early or wait."),

        MoodSpot(
            id: "mood-cobies", name: "Cobie's", town: "Brewster", region: .lowerCape,
            categories: [.friedClams, .lobsterRoll, .seafoodShack, .iceCream],
            rating: 4.5, priceLevel: 1, bestFor: "Classic Route 6A clam shack",
            topItems: [
                MoodCategory.friedClams.rawValue: "Fried Clam Plate",
                MoodCategory.lobsterRoll.rawValue: "Lobster Roll",
                MoodCategory.seafoodShack.rawValue: "Onion Rings",
                MoodCategory.iceCream.rawValue: "Soft Serve Cone",
            ],
            description: "Generations of families have been coming to this roadside gem since 1948."),

        MoodSpot(
            id: "mood-sundae-school", name: "Sundae School", town: "Orleans", region: .lowerCape,
            categories: [.iceCream],
            rating: 4.8, priceLevel: 1, bestFor: "Iconic homemade scoops",
            topItems: [
                MoodCategory.iceCream.rawValue: "Cookie Monster",
            ],
            description: "Cape Cod ice cream legend with generous scoops and homemade flavors since 1976."),

        MoodSpot(
            id: "mood-rock-harbor", name: "Rock Harbor Grill", town: "Orleans", region: .lowerCape,
            categories: [.seafoodShack, .cocktails, .lobsterRoll, .tacos],
            rating: 4.6, priceLevel: 2, bestFor: "Waterfront dining at sunset",
            topItems: [
                MoodCategory.seafoodShack.rawValue: "Grilled Local Catch",
                MoodCategory.cocktails.rawValue: "Harbor Sunset Cocktail",
                MoodCategory.lobsterRoll.rawValue: "Warm Butter Lobster Roll",
                MoodCategory.tacos.rawValue: "Fish Tacos",
            ],
            description: "Casual harbor-side spot with stunning sunset views and fresh catch."),

        MoodSpot(
            id: "mood-nauset-beach-club", name: "Nauset Beach Club", town: "Orleans", region: .lowerCape,
            categories: [.fineDining, .cocktails, .pizza],
            rating: 4.5, priceLevel: 3, bestFor: "Italian-Mediterranean elegance",
            topItems: [
                MoodCategory.fineDining.rawValue: "Lobster Fra Diavolo",
                MoodCategory.cocktails.rawValue: "Negroni",
                MoodCategory.pizza.rawValue: "Wood-Fired Margherita",
            ],
            description: "Italian-Mediterranean meets Cape Cod seafood in an elegant setting."),

        MoodSpot(
            id: "mood-brax-landing", name: "Brax Landing", town: "Harwich", region: .lowerCape,
            categories: [.seafoodShack, .cocktails, .chowder],
            rating: 4.4, priceLevel: 2, bestFor: "Harbor dining with boat views",
            topItems: [
                MoodCategory.seafoodShack.rawValue: "Grilled Swordfish",
                MoodCategory.cocktails.rawValue: "Harborside G&T",
                MoodCategory.chowder.rawValue: "Stuffed Quahog Chowder",
            ],
            description: "Waterfront dining on Saquatucket Harbor — watch the boats come and go."),

        MoodSpot(
            id: "mood-hot-chocolate-sparrow", name: "Hot Chocolate Sparrow", town: "Orleans", region: .lowerCape,
            categories: [.coffee, .bakery, .iceCream],
            rating: 4.7, priceLevel: 1, bestFor: "World-class hot chocolate",
            topItems: [
                MoodCategory.coffee.rawValue: "Mexican Hot Chocolate",
                MoodCategory.bakery.rawValue: "Chocolate Truffle",
                MoodCategory.iceCream.rawValue: "Homemade Ice Cream",
            ],
            description: "Legendary chocolate cafe with handmade truffles and the best hot cocoa."),

        MoodSpot(
            id: "mood-impudent-oyster", name: "The Impudent Oyster", town: "Chatham", region: .lowerCape,
            categories: [.oysters, .fineDining, .seafoodShack],
            rating: 4.5, priceLevel: 3, bestFor: "Creative global seafood",
            topItems: [
                MoodCategory.oysters.rawValue: "Oysters Rockefeller",
                MoodCategory.fineDining.rawValue: "Bouillabaisse",
                MoodCategory.seafoodShack.rawValue: "Shrimp Curry",
            ],
            description: "Global seafood in a cozy downtown setting with international flair."),

        // MARK: - Outer Cape

        MoodSpot(
            id: "mood-lobster-pot", name: "The Lobster Pot", town: "Provincetown", region: .outerCape,
            categories: [.lobsterRoll, .chowder, .seafoodShack, .fineDining],
            rating: 4.6, priceLevel: 3, bestFor: "Cape Cod's legendary bisque",
            topItems: [
                MoodCategory.lobsterRoll.rawValue: "Baked Stuffed Lobster",
                MoodCategory.chowder.rawValue: "Lobster Bisque",
                MoodCategory.seafoodShack.rawValue: "Raw Bar Platter",
                MoodCategory.fineDining.rawValue: "Baked Stuffed Lobster",
            ],
            description: "Legendary Provincetown seafood. The bisque is widely considered the Cape's best."),

        MoodSpot(
            id: "mood-canteen", name: "The Canteen", town: "Provincetown", region: .outerCape,
            categories: [.tacos, .seafoodShack, .iceCream, .cocktails],
            rating: 4.5, priceLevel: 2, bestFor: "Creative casual by the water",
            topItems: [
                MoodCategory.tacos.rawValue: "Lobster Tacos",
                MoodCategory.seafoodShack.rawValue: "Fried Oyster Po'Boy",
                MoodCategory.iceCream.rawValue: "Soft Serve Twist",
                MoodCategory.cocktails.rawValue: "Rosé on Tap",
            ],
            description: "Farm-to-table casual spot with creative takes on New England classics."),

        MoodSpot(
            id: "mood-macs-seafood", name: "Mac's Seafood", town: "Provincetown", region: .outerCape,
            categories: [.oysters, .seafoodShack, .tacos],
            rating: 4.4, priceLevel: 2, bestFor: "Sushi & raw bar heaven",
            topItems: [
                MoodCategory.oysters.rawValue: "Oysters on the Half Shell",
                MoodCategory.seafoodShack.rawValue: "Poke Bowl",
                MoodCategory.tacos.rawValue: "Baja Fish Tacos",
            ],
            description: "Fresh sushi and seafood market. Raw, fried, or grilled — all exceptional."),

        MoodSpot(
            id: "mood-beachcomber", name: "The Beachcomber", town: "Wellfleet", region: .outerCape,
            categories: [.beachBar, .cocktails, .tacos, .burgers],
            rating: 4.3, priceLevel: 2, bestFor: "Ultimate Cape Cod beach bar",
            topItems: [
                MoodCategory.beachBar.rawValue: "Rum Punch",
                MoodCategory.cocktails.rawValue: "Frozen Margarita",
                MoodCategory.tacos.rawValue: "Fish Tacos",
                MoodCategory.burgers.rawValue: "Beach Burger",
            ],
            description: "Beach bar in a former lifesaving station. Live music, cocktails, and ocean views."),

        MoodSpot(
            id: "mood-pb-boulangerie", name: "PB Boulangerie", town: "Wellfleet", region: .outerCape,
            categories: [.bakery, .breakfast, .fineDining, .coffee],
            rating: 4.8, priceLevel: 3, bestFor: "Award-winning French pastries",
            topItems: [
                MoodCategory.bakery.rawValue: "Pain au Chocolat",
                MoodCategory.breakfast.rawValue: "Almond Croissant & Café",
                MoodCategory.fineDining.rawValue: "Duck Confit",
                MoodCategory.coffee.rawValue: "French Press",
            ],
            description: "World-class French bakery. Award-winning pastries and bistro dinners."),

        MoodSpot(
            id: "mood-moby-dicks", name: "Moby Dick's", town: "Wellfleet", region: .outerCape,
            categories: [.friedClams, .lobsterRoll, .seafoodShack],
            rating: 4.4, priceLevel: 2, bestFor: "BYOB seafood shack",
            topItems: [
                MoodCategory.friedClams.rawValue: "Whole Belly Fried Clams",
                MoodCategory.lobsterRoll.rawValue: "Lobster Dinner",
                MoodCategory.seafoodShack.rawValue: "Fish & Chips",
            ],
            description: "BYOB seafood shack with huge portions, paper plates, and the freshest clams."),

        MoodSpot(
            id: "mood-arnolds", name: "Arnold's Lobster & Clam Bar", town: "Eastham", region: .outerCape,
            categories: [.lobsterRoll, .friedClams, .seafoodShack, .iceCream],
            rating: 4.5, priceLevel: 2, bestFor: "Cape Cod's busiest clam bar",
            topItems: [
                MoodCategory.lobsterRoll.rawValue: "Lobster Roll",
                MoodCategory.friedClams.rawValue: "Fried Clams",
                MoodCategory.seafoodShack.rawValue: "Raw Bar Platter",
                MoodCategory.iceCream.rawValue: "Homemade Ice Cream",
            ],
            description: "The Cape's busiest clam bar. Mini golf next door keeps kids happy while you wait."),

        MoodSpot(
            id: "mood-blackfish", name: "Blackfish", town: "Truro", region: .outerCape,
            categories: [.fineDining, .cocktails, .oysters],
            rating: 4.7, priceLevel: 3, bestFor: "Upscale comfort in a blacksmith shop",
            topItems: [
                MoodCategory.fineDining.rawValue: "Pan-Roasted Cod",
                MoodCategory.cocktails.rawValue: "Seasonal Old Fashioned",
                MoodCategory.oysters.rawValue: "Oyster Stew",
            ],
            description: "Upscale comfort food in a restored blacksmith shop with outstanding wine."),

        MoodSpot(
            id: "mood-hole-in-one", name: "Hole in One Bakery", town: "Eastham", region: .outerCape,
            categories: [.bakery, .breakfast, .coffee],
            rating: 4.6, priceLevel: 1, bestFor: "Legendary donuts since the 1970s",
            topItems: [
                MoodCategory.bakery.rawValue: "Apple Fritter",
                MoodCategory.breakfast.rawValue: "Breakfast Sandwich",
                MoodCategory.coffee.rawValue: "Regular Coffee",
            ],
            description: "Famous for their donuts. Locals line up every morning — get there early."),

        MoodSpot(
            id: "mood-joon-bar", name: "Joon Bar", town: "Provincetown", region: .outerCape,
            categories: [.cocktails, .fineDining],
            rating: 4.6, priceLevel: 3, bestFor: "Stylish cocktails & small plates",
            topItems: [
                MoodCategory.cocktails.rawValue: "House Negroni",
                MoodCategory.fineDining.rawValue: "Tuna Crudo",
            ],
            description: "Chic cocktail bar with inventive drinks and elevated small plates."),

        MoodSpot(
            id: "mood-provincetown-pizza", name: "Twisted Pizza", town: "Provincetown", region: .outerCape,
            categories: [.pizza, .burgers],
            rating: 4.3, priceLevel: 1, bestFor: "Late-night Commercial Street slices",
            topItems: [
                MoodCategory.pizza.rawValue: "Pepperoni Slice",
                MoodCategory.burgers.rawValue: "Twisted Burger",
            ],
            description: "Go-to late-night spot on Commercial Street for slices and burgers."),
    ]

    /// Returns spots matching a given mood category.
    static func spots(for mood: MoodCategory) -> [MoodSpot] {
        allSpots.filter { $0.categories.contains(mood) }
    }

    /// Returns spots in a given region matching a mood.
    static func spots(for mood: MoodCategory, in region: CapeCodRegion) -> [MoodSpot] {
        allSpots.filter { $0.categories.contains(mood) && $0.region == region }
    }
}

// swiftlint:enable type_body_length file_length

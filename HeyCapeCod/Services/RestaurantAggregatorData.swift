import Foundation

// MARK: - Hardcoded Aggregated Restaurant Data

enum RestaurantAggregatorData {

    // MARK: - Date Helper

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d
        return Calendar.current.date(from: c) ?? .now
    }

    // MARK: - All Restaurants

    // swiftlint:disable function_body_length
    static let allRestaurants: [AggregatedRestaurant] = [
        lobsterPot, arnolds, chathamBarsInn, mobyDicks, captainFrostys,
        pbBoulangerie, macsOnThePier, beachcomber, cookesSeafood, kreamNKone,
        redInn, ceraldi, sesuitHarborCafe, theKnack, sirCrickets
    ]
    // swiftlint:enable function_body_length

    // MARK: - 1. The Lobster Pot

    static let lobsterPot = AggregatedRestaurant(
        id: "lobster-pot",
        name: "The Lobster Pot",
        town: "Provincetown",
        cuisine: "Seafood",
        priceLevel: 3,
        reviews: [
            AggregatedReview(id: "lp-r1", source: .google, rating: 4.6, text: "The lobster bisque is the best I've ever had. Creamy, rich, and packed with lobster meat. Worth every penny.", author: "Sarah M.", date: date(2025, 8, 15), helpful: 42),
            AggregatedReview(id: "lp-r2", source: .yelp, rating: 4.5, text: "Baked stuffed lobster was incredible. The staff were friendly and the harbor view is unbeatable. Long wait on weekends though.", author: "Mike T.", date: date(2025, 7, 22), helpful: 28),
            AggregatedReview(id: "lp-r3", source: .tripadvisor, rating: 4.8, text: "A Provincetown institution! We've been coming here for 20 years and the quality never drops. Lobster bisque is legendary.", author: "Cape Lover", date: date(2025, 9, 3), helpful: 55),
            AggregatedReview(id: "lp-r4", source: .heycapecod, rating: 4.9, text: "Skip the boiled lobster and go straight for the baked stuffed. The cracker crumb topping is perfection. Late lunch avoids the crowd.", author: "Local Foodie", date: date(2025, 8, 28), helpful: 67),
            AggregatedReview(id: "lp-r5", source: .google, rating: 4.3, text: "Great seafood but expect a wait during peak season. The clam chowder is also very good. Parking is tough in P-town.", author: "David R.", date: date(2025, 7, 10), helpful: 15),
            AggregatedReview(id: "lp-r6", source: .yelp, rating: 4.7, text: "Everything on the menu is fresh and well-prepared. The raw bar is excellent. Service can be slow when busy but worth it.", author: "Jenna K.", date: date(2025, 8, 5), helpful: 31),
        ],
        overallRating: 4.6,
        popularDishes: [
            PopularDish(id: "lp-d1", name: "Lobster Bisque", mentions: 89, sentiment: 0.95, avgPrice: "$14"),
            PopularDish(id: "lp-d2", name: "Baked Stuffed Lobster", mentions: 72, sentiment: 0.92, avgPrice: "$42"),
            PopularDish(id: "lp-d3", name: "Clam Chowder", mentions: 45, sentiment: 0.88, avgPrice: "$12"),
            PopularDish(id: "lp-d4", name: "Raw Bar Platter", mentions: 33, sentiment: 0.85, avgPrice: "$38"),
        ],
        bestTimeToVisit: "Late lunch (2-4 PM) to avoid dinner rush",
        aiSummary: "Known for their legendary lobster bisque, consistently rated among the best on the Cape. Best visited for a late lunch to avoid the dinner rush. Locals recommend the baked stuffed lobster over the standard boiled.",
        sources: ReviewSource.allCases
    )

    // MARK: - 2. Arnold's Lobster & Clam Bar

    static let arnolds = AggregatedRestaurant(
        id: "arnolds",
        name: "Arnold's Lobster & Clam Bar",
        town: "Eastham",
        cuisine: "Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "ar-r1", source: .google, rating: 4.5, text: "Best fried clams on the Cape, hands down. The whole belly clams are perfectly crispy. Great outdoor seating.", author: "Tom B.", date: date(2025, 7, 18), helpful: 38),
            AggregatedReview(id: "ar-r2", source: .yelp, rating: 4.4, text: "Lobster roll is loaded with meat and lightly dressed. The onion rings are also amazing. Cash only - be prepared!", author: "Lisa P.", date: date(2025, 8, 2), helpful: 22),
            AggregatedReview(id: "ar-r3", source: .tripadvisor, rating: 4.7, text: "Classic Cape Cod clam shack. The fried seafood platter is enormous. Don't skip the ice cream next door!", author: "Beach Bum", date: date(2025, 8, 20), helpful: 44),
            AggregatedReview(id: "ar-r4", source: .heycapecod, rating: 4.8, text: "The raw bar here is underrated. Great oysters and the lobster roll rivals any on the Cape. Arrive before noon to beat lines.", author: "Eastham Regular", date: date(2025, 9, 1), helpful: 51),
            AggregatedReview(id: "ar-r5", source: .google, rating: 4.2, text: "Solid fried seafood. Lines can be long in summer but it moves fast. Good value for the portions you get.", author: "Jim W.", date: date(2025, 7, 29), helpful: 12),
            AggregatedReview(id: "ar-r6", source: .yelp, rating: 4.6, text: "We come here every summer. Fried clams and lobster roll are must-haves. Kids love the outdoor picnic tables.", author: "Family Fun", date: date(2025, 8, 12), helpful: 19),
        ],
        overallRating: 4.5,
        popularDishes: [
            PopularDish(id: "ar-d1", name: "Fried Clams", mentions: 95, sentiment: 0.94, avgPrice: "$24"),
            PopularDish(id: "ar-d2", name: "Lobster Roll", mentions: 78, sentiment: 0.91, avgPrice: "$28"),
            PopularDish(id: "ar-d3", name: "Onion Rings", mentions: 41, sentiment: 0.87, avgPrice: "$10"),
            PopularDish(id: "ar-d4", name: "Seafood Platter", mentions: 36, sentiment: 0.89, avgPrice: "$32"),
        ],
        bestTimeToVisit: "Early lunch (11 AM) to beat the crowds",
        aiSummary: "The gold standard for Cape Cod fried clams. Arnold's whole belly clams are crispy perfection. Arrive by 11 AM to skip summer lines. The lobster roll is generously filled and a strong contender for best on the Outer Cape.",
        sources: ReviewSource.allCases
    )

    // MARK: - 3. Chatham Bars Inn

    static let chathamBarsInn = AggregatedRestaurant(
        id: "chatham-bars-inn",
        name: "Chatham Bars Inn",
        town: "Chatham",
        cuisine: "Fine Dining",
        priceLevel: 4,
        reviews: [
            AggregatedReview(id: "cb-r1", source: .google, rating: 4.7, text: "Exquisite dining with an ocean view that can't be beat. The tasting menu is a culinary journey. Impeccable service.", author: "Gourmet George", date: date(2025, 8, 10), helpful: 36),
            AggregatedReview(id: "cb-r2", source: .yelp, rating: 4.3, text: "Beautiful setting and excellent food. Pricey but it's a special occasion place. The pan-seared scallops were divine.", author: "Rachel D.", date: date(2025, 7, 25), helpful: 20),
            AggregatedReview(id: "cb-r3", source: .tripadvisor, rating: 4.8, text: "Worth every dollar. The sunset over the ocean paired with world-class cuisine makes this unforgettable. Reserve early.", author: "Luxury Travel", date: date(2025, 9, 5), helpful: 48),
            AggregatedReview(id: "cb-r4", source: .heycapecod, rating: 4.9, text: "The STARS restaurant here is Cape Cod's finest. Farm-to-table approach with their own garden. Request a window table.", author: "Fine Dining Fan", date: date(2025, 8, 22), helpful: 59),
            AggregatedReview(id: "cb-r5", source: .google, rating: 4.5, text: "Elegant atmosphere, creative menu. The lobster thermidor is outstanding. Perfect for anniversaries or celebrations.", author: "Anna S.", date: date(2025, 7, 14), helpful: 25),
        ],
        overallRating: 4.6,
        popularDishes: [
            PopularDish(id: "cb-d1", name: "Pan-Seared Scallops", mentions: 62, sentiment: 0.96, avgPrice: "$42"),
            PopularDish(id: "cb-d2", name: "Lobster Thermidor", mentions: 48, sentiment: 0.93, avgPrice: "$55"),
            PopularDish(id: "cb-d3", name: "Tasting Menu", mentions: 39, sentiment: 0.95, avgPrice: "$125"),
            PopularDish(id: "cb-d4", name: "Crudo Platter", mentions: 28, sentiment: 0.90, avgPrice: "$32"),
        ],
        bestTimeToVisit: "Sunset dinner (6-7 PM) for the best views",
        aiSummary: "Cape Cod's premier fine dining destination. The STARS restaurant offers a farm-to-table experience with produce from their own garden. Request a window table at sunset for the full experience. The tasting menu is exceptional.",
        sources: ReviewSource.allCases
    )

    // MARK: - 4. Moby Dick's

    static let mobyDicks = AggregatedRestaurant(
        id: "moby-dicks",
        name: "Moby Dick's",
        town: "Wellfleet",
        cuisine: "Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "md-r1", source: .google, rating: 4.4, text: "BYOB is genius! Bring your own wine and enjoy massive seafood platters. The fried fish is always fresh.", author: "Wine Lover", date: date(2025, 7, 20), helpful: 33),
            AggregatedReview(id: "md-r2", source: .yelp, rating: 4.3, text: "Classic Cape Cod seafood shack. The clam chowder is thick and creamy. Love the BYOB policy.", author: "Clam Fan", date: date(2025, 8, 8), helpful: 18),
            AggregatedReview(id: "md-r3", source: .tripadvisor, rating: 4.6, text: "Great value for fresh seafood. The combo platters feed two easily. Casual, fun atmosphere with picnic tables.", author: "Budget Foodie", date: date(2025, 8, 25), helpful: 41),
            AggregatedReview(id: "md-r4", source: .heycapecod, rating: 4.7, text: "Bring a bottle of Sancerre, get the seafood platter for two, and enjoy. One of the best deals on the Outer Cape.", author: "Wellfleet Local", date: date(2025, 9, 2), helpful: 53),
            AggregatedReview(id: "md-r5", source: .google, rating: 4.1, text: "Solid fried seafood. Nothing fancy but that's the charm. Lines move quickly.", author: "Pete H.", date: date(2025, 7, 15), helpful: 9),
            AggregatedReview(id: "md-r6", source: .yelp, rating: 4.5, text: "The seafood platter is legendary. Fried clams, scallops, shrimp, and fish - all perfectly cooked. Huge portions.", author: "Hungry Hiker", date: date(2025, 8, 18), helpful: 27),
        ],
        overallRating: 4.4,
        popularDishes: [
            PopularDish(id: "md-d1", name: "Seafood Platter", mentions: 82, sentiment: 0.91, avgPrice: "$34"),
            PopularDish(id: "md-d2", name: "Clam Chowder", mentions: 55, sentiment: 0.87, avgPrice: "$10"),
            PopularDish(id: "md-d3", name: "Fried Clams", mentions: 48, sentiment: 0.89, avgPrice: "$22"),
            PopularDish(id: "md-d4", name: "Fish & Chips", mentions: 35, sentiment: 0.85, avgPrice: "$18"),
        ],
        bestTimeToVisit: "Early dinner (5 PM), bring your own wine",
        aiSummary: "The ultimate BYOB seafood experience on the Outer Cape. Bring a good bottle of wine and share the seafood platter for two. Casual picnic-table dining with generous portions and honest prices. A Wellfleet institution.",
        sources: ReviewSource.allCases
    )

    // MARK: - 5. Captain Frosty's

    static let captainFrostys = AggregatedRestaurant(
        id: "captain-frostys",
        name: "Captain Frosty's",
        town: "Dennis",
        cuisine: "Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "cf-r1", source: .google, rating: 4.5, text: "Best fish and chips on the Cape! The batter is light and crispy. Great roadside stop.", author: "Road Tripper", date: date(2025, 7, 12), helpful: 29),
            AggregatedReview(id: "cf-r2", source: .yelp, rating: 4.4, text: "Classic clam shack. The fried scallops are sweet and tender. Don't forget the soft serve for dessert!", author: "Sweet Tooth", date: date(2025, 8, 1), helpful: 17),
            AggregatedReview(id: "cf-r3", source: .tripadvisor, rating: 4.6, text: "Consistent quality year after year. Fish is always fresh, batter is never greasy. A must-stop in Dennis.", author: "Repeat Visitor", date: date(2025, 8, 15), helpful: 35),
            AggregatedReview(id: "cf-r4", source: .heycapecod, rating: 4.7, text: "Locals know this is the spot. Skip the tourist traps and come here for honest fried seafood at fair prices.", author: "Dennis Native", date: date(2025, 8, 30), helpful: 46),
            AggregatedReview(id: "cf-r5", source: .yelp, rating: 4.3, text: "Solid fried seafood. The combo plate with clams and fish is the way to go. Cash only!", author: "Quick Bite", date: date(2025, 7, 28), helpful: 11),
        ],
        overallRating: 4.5,
        popularDishes: [
            PopularDish(id: "cf-d1", name: "Fish & Chips", mentions: 76, sentiment: 0.93, avgPrice: "$16"),
            PopularDish(id: "cf-d2", name: "Fried Scallops", mentions: 52, sentiment: 0.90, avgPrice: "$24"),
            PopularDish(id: "cf-d3", name: "Clam Strips", mentions: 38, sentiment: 0.86, avgPrice: "$14"),
            PopularDish(id: "cf-d4", name: "Soft Serve Ice Cream", mentions: 29, sentiment: 0.92, avgPrice: "$6"),
        ],
        bestTimeToVisit: "Lunch (11:30 AM - 1 PM)",
        aiSummary: "A beloved Dennis roadside clam shack that locals swear by. The fish and chips feature a light, crispy batter that's never greasy. The fried scallops are exceptionally sweet. End with soft serve ice cream.",
        sources: ReviewSource.allCases
    )

    // MARK: - 6. PB Boulangerie

    static let pbBoulangerie = AggregatedRestaurant(
        id: "pb-boulangerie",
        name: "PB Boulangerie",
        town: "Wellfleet",
        cuisine: "French Bakery",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "pb-r1", source: .google, rating: 4.8, text: "The croissants are Paris-quality. Flaky, buttery perfection. I can't believe this bakery is on Cape Cod.", author: "Pastry Snob", date: date(2025, 7, 25), helpful: 52),
            AggregatedReview(id: "pb-r2", source: .yelp, rating: 4.7, text: "Everything here is incredible. The pain au chocolat melts in your mouth. Get there early - they sell out!", author: "Morning Person", date: date(2025, 8, 5), helpful: 38),
            AggregatedReview(id: "pb-r3", source: .tripadvisor, rating: 4.9, text: "A hidden gem in Wellfleet. French-trained baker creating masterpieces daily. The baguettes are crusty perfection.", author: "Euro Traveler", date: date(2025, 8, 22), helpful: 61),
            AggregatedReview(id: "pb-r4", source: .heycapecod, rating: 5.0, text: "This is the best bakery on the entire Cape, no contest. Come at 7 AM for warm croissants. The bistro dinners are a secret treasure.", author: "Wellfleet Insider", date: date(2025, 9, 4), helpful: 74),
            AggregatedReview(id: "pb-r5", source: .google, rating: 4.6, text: "Exceptional pastries. The quiche is also wonderful. Small space so plan to take things to go.", author: "Amy L.", date: date(2025, 7, 30), helpful: 21),
        ],
        overallRating: 4.8,
        popularDishes: [
            PopularDish(id: "pb-d1", name: "Croissants", mentions: 98, sentiment: 0.97, avgPrice: "$5"),
            PopularDish(id: "pb-d2", name: "Pain au Chocolat", mentions: 71, sentiment: 0.96, avgPrice: "$5"),
            PopularDish(id: "pb-d3", name: "Baguette", mentions: 44, sentiment: 0.93, avgPrice: "$6"),
            PopularDish(id: "pb-d4", name: "Quiche Lorraine", mentions: 32, sentiment: 0.91, avgPrice: "$8"),
        ],
        bestTimeToVisit: "Early morning (7-8 AM) for fresh pastries",
        aiSummary: "Paris-quality pastries in the heart of Wellfleet. The croissants are flaky, buttery perfection from a French-trained baker. Arrive by 7 AM for the best selection - popular items sell out by noon. The secret bistro dinners are exceptional.",
        sources: ReviewSource.allCases
    )

    // MARK: - 7. Mac's on the Pier

    static let macsOnThePier = AggregatedRestaurant(
        id: "macs-on-pier",
        name: "Mac's on the Pier",
        town: "Wellfleet",
        cuisine: "Raw Bar",
        priceLevel: 3,
        reviews: [
            AggregatedReview(id: "mc-r1", source: .google, rating: 4.5, text: "Freshest oysters I've ever had. Literally pulled from the harbor that morning. The setting is magical.", author: "Oyster Dan", date: date(2025, 8, 8), helpful: 40),
            AggregatedReview(id: "mc-r2", source: .yelp, rating: 4.4, text: "Incredible raw bar right on Wellfleet Harbor. The oysters are briny and perfect. Great wine list too.", author: "Wine & Dine", date: date(2025, 7, 22), helpful: 26),
            AggregatedReview(id: "mc-r3", source: .tripadvisor, rating: 4.7, text: "Can't get fresher than this. Watching the sunset while shucking oysters is peak Cape Cod. A must-visit.", author: "Sunset Chaser", date: date(2025, 8, 30), helpful: 49),
            AggregatedReview(id: "mc-r4", source: .heycapecod, rating: 4.8, text: "Order a dozen Wellfleet oysters and a glass of Muscadet. Sit on the pier at sunset. This is why you came to Cape Cod.", author: "Harbor Rat", date: date(2025, 9, 1), helpful: 62),
            AggregatedReview(id: "mc-r5", source: .google, rating: 4.3, text: "Amazing location and super fresh seafood. Can get crowded and pricey but the quality justifies it.", author: "Kevin M.", date: date(2025, 7, 18), helpful: 14),
            AggregatedReview(id: "mc-r6", source: .tripadvisor, rating: 4.6, text: "The ceviche is outstanding and the littleneck clams are sweet as candy. Perfect casual seafood spot.", author: "Raw Bar Fan", date: date(2025, 8, 14), helpful: 33),
        ],
        overallRating: 4.6,
        popularDishes: [
            PopularDish(id: "mc-d1", name: "Wellfleet Oysters", mentions: 104, sentiment: 0.96, avgPrice: "$18/dozen"),
            PopularDish(id: "mc-d2", name: "Littleneck Clams", mentions: 45, sentiment: 0.90, avgPrice: "$14"),
            PopularDish(id: "mc-d3", name: "Ceviche", mentions: 38, sentiment: 0.92, avgPrice: "$16"),
            PopularDish(id: "mc-d4", name: "Lobster Roll", mentions: 29, sentiment: 0.88, avgPrice: "$26"),
        ],
        bestTimeToVisit: "Late afternoon (4-6 PM) for sunset oysters",
        aiSummary: "The ultimate raw bar experience on Cape Cod. Wellfleet oysters harvested that morning, enjoyed on the pier at sunset. Pair with a crisp Muscadet. The ceviche is a hidden standout. Arrive by 4 PM for waterfront seating.",
        sources: ReviewSource.allCases
    )

    // MARK: - 8. The Beachcomber

    static let beachcomber = AggregatedRestaurant(
        id: "beachcomber",
        name: "The Beachcomber",
        town: "Wellfleet",
        cuisine: "Beach Bar & Grill",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "bc-r1", source: .google, rating: 4.3, text: "Great beach bar vibes with live music. Food is solid bar fare. The fish tacos are surprisingly good.", author: "Beach Party", date: date(2025, 7, 15), helpful: 25),
            AggregatedReview(id: "bc-r2", source: .yelp, rating: 4.2, text: "More about the atmosphere than the food, but both deliver. Watching the sunset with a frozen drink is perfection.", author: "Sunset Sipper", date: date(2025, 8, 3), helpful: 19),
            AggregatedReview(id: "bc-r3", source: .tripadvisor, rating: 4.5, text: "One of the best beach bars in New England. Live music, ocean views, cold drinks. The fish tacos are a must.", author: "Bar Hopper", date: date(2025, 8, 20), helpful: 37),
            AggregatedReview(id: "bc-r4", source: .heycapecod, rating: 4.6, text: "The vibe here is unmatched. Live reggae, toes in the sand, cold beer. Come for the atmosphere, stay for the fish tacos.", author: "Wellfleet Regular", date: date(2025, 8, 28), helpful: 44),
            AggregatedReview(id: "bc-r5", source: .google, rating: 4.0, text: "Fun spot but expect crowds in summer. The walk down to the beach is part of the experience. Bring cash.", author: "First Timer", date: date(2025, 7, 28), helpful: 10),
        ],
        overallRating: 4.3,
        popularDishes: [
            PopularDish(id: "bc-d1", name: "Fish Tacos", mentions: 68, sentiment: 0.89, avgPrice: "$16"),
            PopularDish(id: "bc-d2", name: "Frozen Margarita", mentions: 52, sentiment: 0.91, avgPrice: "$14"),
            PopularDish(id: "bc-d3", name: "Nachos", mentions: 34, sentiment: 0.82, avgPrice: "$14"),
            PopularDish(id: "bc-d4", name: "Lobster Roll", mentions: 28, sentiment: 0.85, avgPrice: "$26"),
        ],
        bestTimeToVisit: "Late afternoon for sunset and live music",
        aiSummary: "Cape Cod's iconic beach bar. Less about fine dining and more about the experience: live reggae, ocean views, and toes in the sand. The fish tacos are genuinely excellent. Arrive mid-afternoon for the best spots.",
        sources: ReviewSource.allCases
    )

    // MARK: - 9. Cooke's Seafood

    static let cookesSeafood = AggregatedRestaurant(
        id: "cookes-seafood",
        name: "Cooke's Seafood",
        town: "Orleans",
        cuisine: "Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "ck-r1", source: .google, rating: 4.3, text: "Reliable fried seafood at good prices. The clam strips are perfectly crispy. Fast service.", author: "Quick Lunch", date: date(2025, 7, 20), helpful: 18),
            AggregatedReview(id: "ck-r2", source: .yelp, rating: 4.1, text: "Good honest seafood. Nothing fancy but everything is fresh and well-cooked. Great for families.", author: "Family Dinner", date: date(2025, 8, 6), helpful: 12),
            AggregatedReview(id: "ck-r3", source: .tripadvisor, rating: 4.4, text: "Multiple locations means you're never far from good fried seafood. Orleans location has the best chowder.", author: "Chowder Fan", date: date(2025, 8, 18), helpful: 24),
            AggregatedReview(id: "ck-r4", source: .heycapecod, rating: 4.5, text: "The go-to takeout spot for locals. Fried clam plate with coleslaw hits different. Best value on Route 6A.", author: "Route 6A Regular", date: date(2025, 8, 25), helpful: 31),
            AggregatedReview(id: "ck-r5", source: .google, rating: 4.2, text: "Consistently good fried seafood. The combo platter feeds two. Indoor and outdoor seating available.", author: "Combo King", date: date(2025, 7, 14), helpful: 8),
        ],
        overallRating: 4.3,
        popularDishes: [
            PopularDish(id: "ck-d1", name: "Fried Clam Plate", mentions: 58, sentiment: 0.88, avgPrice: "$22"),
            PopularDish(id: "ck-d2", name: "Clam Chowder", mentions: 42, sentiment: 0.86, avgPrice: "$9"),
            PopularDish(id: "ck-d3", name: "Fish & Chips", mentions: 39, sentiment: 0.84, avgPrice: "$16"),
            PopularDish(id: "ck-d4", name: "Combo Platter", mentions: 31, sentiment: 0.87, avgPrice: "$28"),
        ],
        bestTimeToVisit: "Lunch or early dinner to avoid lines",
        aiSummary: "Reliable, honest fried seafood with multiple Cape locations. The Orleans spot is the best of the bunch. Great value for generous portions. Perfect for a quick, satisfying seafood fix without the wait at fancier spots.",
        sources: ReviewSource.allCases
    )

    // MARK: - 10. Kream 'N Kone

    static let kreamNKone = AggregatedRestaurant(
        id: "kream-n-kone",
        name: "Kream 'N Kone",
        town: "Dennis",
        cuisine: "Seafood & Ice Cream",
        priceLevel: 1,
        reviews: [
            AggregatedReview(id: "kk-r1", source: .google, rating: 4.4, text: "The soft serve is iconic. After a beach day, nothing beats a twist cone. The fried seafood is solid too.", author: "Ice Cream Fan", date: date(2025, 7, 10), helpful: 22),
            AggregatedReview(id: "kk-r2", source: .yelp, rating: 4.3, text: "Classic roadside spot. Fried clams and ice cream - what more do you need? Kids love this place.", author: "Mom of Three", date: date(2025, 8, 2), helpful: 16),
            AggregatedReview(id: "kk-r3", source: .tripadvisor, rating: 4.5, text: "Been coming here since I was a kid. The ice cream sundaes are huge. Fried food is consistently good.", author: "Nostalgia", date: date(2025, 8, 15), helpful: 30),
            AggregatedReview(id: "kk-r4", source: .heycapecod, rating: 4.6, text: "The Cape Cod childhood experience. Get a fried clam plate then a sundae. Best value ice cream around.", author: "Dennis Kid", date: date(2025, 8, 28), helpful: 39),
            AggregatedReview(id: "kk-r5", source: .yelp, rating: 4.2, text: "Great ice cream and decent fried seafood. Perfect after-beach stop. Reasonable prices.", author: "Budget Beach", date: date(2025, 7, 22), helpful: 9),
        ],
        overallRating: 4.4,
        popularDishes: [
            PopularDish(id: "kk-d1", name: "Soft Serve Twist", mentions: 72, sentiment: 0.93, avgPrice: "$5"),
            PopularDish(id: "kk-d2", name: "Ice Cream Sundae", mentions: 55, sentiment: 0.91, avgPrice: "$8"),
            PopularDish(id: "kk-d3", name: "Fried Clams", mentions: 40, sentiment: 0.85, avgPrice: "$20"),
            PopularDish(id: "kk-d4", name: "Onion Rings", mentions: 28, sentiment: 0.83, avgPrice: "$8"),
        ],
        bestTimeToVisit: "After the beach (3-5 PM)",
        aiSummary: "A nostalgic Cape Cod institution perfect for families. Come for the ice cream (the twist cone is legendary) and stay for surprisingly good fried seafood. Best value ice cream on Route 28. A must-stop after a beach day.",
        sources: ReviewSource.allCases
    )

    // MARK: - 11. The Red Inn

    static let redInn = AggregatedRestaurant(
        id: "red-inn",
        name: "The Red Inn",
        town: "Provincetown",
        cuisine: "Fine Dining",
        priceLevel: 4,
        reviews: [
            AggregatedReview(id: "ri-r1", source: .google, rating: 4.7, text: "The most romantic dinner spot in Provincetown. Sunset views over the harbor are breathtaking. Food matches the setting.", author: "Romantic Rachel", date: date(2025, 8, 12), helpful: 41),
            AggregatedReview(id: "ri-r2", source: .yelp, rating: 4.5, text: "Elegant waterfront dining. The seared duck breast was perfectly cooked. Wine list is excellent and well-curated.", author: "Wine Expert", date: date(2025, 7, 28), helpful: 28),
            AggregatedReview(id: "ri-r3", source: .tripadvisor, rating: 4.8, text: "Simply stunning. Arrived for sunset and stayed for an incredible meal. The lobster risotto was the best I've ever had.", author: "Travel & Taste", date: date(2025, 9, 2), helpful: 53),
            AggregatedReview(id: "ri-r4", source: .heycapecod, rating: 4.9, text: "Reserve a harbor-facing table at sunset. Order the lobster risotto and a bottle of Chablis. Thank me later.", author: "P-town Insider", date: date(2025, 8, 25), helpful: 66),
            AggregatedReview(id: "ri-r5", source: .google, rating: 4.4, text: "Beautiful setting and wonderful service. Pricey but appropriate for the quality. Brunch is also excellent.", author: "Sunday Brunch", date: date(2025, 7, 19), helpful: 17),
        ],
        overallRating: 4.7,
        popularDishes: [
            PopularDish(id: "ri-d1", name: "Lobster Risotto", mentions: 68, sentiment: 0.96, avgPrice: "$44"),
            PopularDish(id: "ri-d2", name: "Seared Duck Breast", mentions: 42, sentiment: 0.92, avgPrice: "$38"),
            PopularDish(id: "ri-d3", name: "Pan-Seared Scallops", mentions: 35, sentiment: 0.94, avgPrice: "$40"),
            PopularDish(id: "ri-d4", name: "Brunch Prix Fixe", mentions: 28, sentiment: 0.90, avgPrice: "$45"),
        ],
        bestTimeToVisit: "Sunset dinner, reserve well in advance",
        aiSummary: "Provincetown's most romantic dining experience. The harbor-facing tables at sunset are magical. The lobster risotto is the signature dish and worth every penny. Reserve at least a week ahead in summer. Brunch is also outstanding.",
        sources: ReviewSource.allCases
    )

    // MARK: - 12. Ceraldi

    static let ceraldi = AggregatedRestaurant(
        id: "ceraldi",
        name: "Ceraldi",
        town: "Wellfleet",
        cuisine: "Farm-to-Table",
        priceLevel: 4,
        reviews: [
            AggregatedReview(id: "ce-r1", source: .google, rating: 4.9, text: "The most creative cuisine on Cape Cod. The tasting menu changes weekly and always surprises. Culinary art.", author: "Foodie First", date: date(2025, 8, 15), helpful: 48),
            AggregatedReview(id: "ce-r2", source: .yelp, rating: 4.7, text: "Intimate, innovative, incredible. Every course tells a story. The foraged ingredients make each visit unique.", author: "Tasting Menu Fan", date: date(2025, 7, 30), helpful: 35),
            AggregatedReview(id: "ce-r3", source: .tripadvisor, rating: 4.9, text: "Worth the drive from Boston. Chef Ceraldi is a genius. The wood-fired dishes are extraordinary. Book months ahead.", author: "Boston Gourmet", date: date(2025, 9, 5), helpful: 59),
            AggregatedReview(id: "ce-r4", source: .heycapecod, rating: 5.0, text: "Cape Cod's best-kept culinary secret. Farm-to-table done right with ingredients from local farms. The tasting menu is a journey.", author: "Outer Cape Chef", date: date(2025, 8, 22), helpful: 71),
            AggregatedReview(id: "ce-r5", source: .yelp, rating: 4.8, text: "Intimate space, incredible food. Each dish is a work of art. The wine pairings are perfectly chosen.", author: "Wine Pair", date: date(2025, 8, 8), helpful: 29),
        ],
        overallRating: 4.9,
        popularDishes: [
            PopularDish(id: "ce-d1", name: "Tasting Menu", mentions: 82, sentiment: 0.98, avgPrice: "$135"),
            PopularDish(id: "ce-d2", name: "Wood-Fired Dishes", mentions: 55, sentiment: 0.95, avgPrice: nil),
            PopularDish(id: "ce-d3", name: "Foraged Salad", mentions: 38, sentiment: 0.93, avgPrice: nil),
            PopularDish(id: "ce-d4", name: "Wine Pairing", mentions: 31, sentiment: 0.96, avgPrice: "$75"),
        ],
        bestTimeToVisit: "Any night - book 2+ months ahead",
        aiSummary: "Cape Cod's most acclaimed restaurant. Chef Michael Ceraldi creates extraordinary farm-to-table tasting menus with locally foraged ingredients. The intimate space only seats a few dozen. Book at least two months in advance. Worth every dollar.",
        sources: ReviewSource.allCases
    )

    // MARK: - 13. Sesuit Harbor Cafe

    static let sesuitHarborCafe = AggregatedRestaurant(
        id: "sesuit-harbor-cafe",
        name: "Sesuit Harbor Cafe",
        town: "Dennis",
        cuisine: "Breakfast & Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "sh-r1", source: .google, rating: 4.5, text: "Best waterfront breakfast on the Cape. The lobster omelet is decadent. Watching boats come in while you eat is perfect.", author: "Morning Sailor", date: date(2025, 7, 18), helpful: 34),
            AggregatedReview(id: "sh-r2", source: .yelp, rating: 4.4, text: "Casual, delicious, waterfront. The blueberry pancakes are fluffy and loaded with berries. Great lunch too.", author: "Pancake Fan", date: date(2025, 8, 5), helpful: 22),
            AggregatedReview(id: "sh-r3", source: .tripadvisor, rating: 4.6, text: "A hidden gem at Sesuit Harbor. Fresh seafood for lunch, amazing breakfast. The lobster roll at lunch is top-tier.", author: "Harbor Discovery", date: date(2025, 8, 22), helpful: 40),
            AggregatedReview(id: "sh-r4", source: .heycapecod, rating: 4.7, text: "Locals' favorite breakfast spot. Get the lobster omelet and sit on the deck. Come early on weekends.", author: "Dennis Early Bird", date: date(2025, 8, 30), helpful: 52),
            AggregatedReview(id: "sh-r5", source: .google, rating: 4.3, text: "Charming waterfront cafe. Breakfast is the star. Lines on weekends but moves reasonably fast.", author: "Weekend Bruncher", date: date(2025, 7, 25), helpful: 15),
        ],
        overallRating: 4.5,
        popularDishes: [
            PopularDish(id: "sh-d1", name: "Lobster Omelet", mentions: 65, sentiment: 0.94, avgPrice: "$18"),
            PopularDish(id: "sh-d2", name: "Blueberry Pancakes", mentions: 48, sentiment: 0.91, avgPrice: "$14"),
            PopularDish(id: "sh-d3", name: "Lobster Roll", mentions: 39, sentiment: 0.90, avgPrice: "$26"),
            PopularDish(id: "sh-d4", name: "Eggs Benedict", mentions: 28, sentiment: 0.88, avgPrice: "$16"),
        ],
        bestTimeToVisit: "Weekday breakfast (8-9 AM)",
        aiSummary: "Dennis's best-kept breakfast secret, right on Sesuit Harbor. The lobster omelet is legendary among locals. Sit on the deck and watch fishing boats return with the morning catch. Come early on weekends to avoid the wait.",
        sources: ReviewSource.allCases
    )

    // MARK: - 14. The Knack

    static let theKnack = AggregatedRestaurant(
        id: "the-knack",
        name: "The Knack",
        town: "Orleans",
        cuisine: "Seafood",
        priceLevel: 2,
        reviews: [
            AggregatedReview(id: "tk-r1", source: .google, rating: 4.4, text: "The lobster roll here is loaded and buttery. Great casual spot in Orleans. Good selection of local beers.", author: "Lobster Lover", date: date(2025, 7, 22), helpful: 26),
            AggregatedReview(id: "tk-r2", source: .yelp, rating: 4.3, text: "Laid-back atmosphere with excellent seafood. The fish tacos are fresh and flavorful. Nice outdoor seating.", author: "Taco Tuesday", date: date(2025, 8, 8), helpful: 18),
            AggregatedReview(id: "tk-r3", source: .tripadvisor, rating: 4.5, text: "Best lobster roll in Orleans. Generous portions and fair prices. The staff is friendly and the beer selection is great.", author: "Beer & Bites", date: date(2025, 8, 20), helpful: 32),
            AggregatedReview(id: "tk-r4", source: .heycapecod, rating: 4.6, text: "The hot buttered lobster roll is the move. Pair it with a Wellfleet oyster stout from local brewery. Perfect combo.", author: "Orleans Local", date: date(2025, 9, 1), helpful: 41),
            AggregatedReview(id: "tk-r5", source: .google, rating: 4.2, text: "Good casual seafood. The clam chowder is chunky and flavorful. Nice patio for warm evenings.", author: "Patio Pete", date: date(2025, 7, 15), helpful: 11),
            AggregatedReview(id: "tk-r6", source: .yelp, rating: 4.5, text: "Everything on the menu is good but the lobster roll is the star. Love the casual, welcoming vibe.", author: "Roll Ranker", date: date(2025, 8, 14), helpful: 23),
        ],
        overallRating: 4.4,
        popularDishes: [
            PopularDish(id: "tk-d1", name: "Lobster Roll", mentions: 74, sentiment: 0.93, avgPrice: "$26"),
            PopularDish(id: "tk-d2", name: "Fish Tacos", mentions: 42, sentiment: 0.88, avgPrice: "$16"),
            PopularDish(id: "tk-d3", name: "Clam Chowder", mentions: 35, sentiment: 0.86, avgPrice: "$10"),
            PopularDish(id: "tk-d4", name: "Fried Clam Plate", mentions: 28, sentiment: 0.85, avgPrice: "$22"),
        ],
        bestTimeToVisit: "Lunch or early dinner",
        aiSummary: "Orleans' go-to for a stellar lobster roll. The hot buttered version is packed with tender lobster meat. Great craft beer selection from local breweries. Casual, welcoming atmosphere perfect for a relaxed Cape Cod meal.",
        sources: ReviewSource.allCases
    )

    // MARK: - 15. Sir Cricket's Fish & Chips

    static let sirCrickets = AggregatedRestaurant(
        id: "sir-crickets",
        name: "Sir Cricket's Fish & Chips",
        town: "Orleans",
        cuisine: "Seafood",
        priceLevel: 1,
        reviews: [
            AggregatedReview(id: "sc-r1", source: .google, rating: 4.3, text: "No-frills fish and chips done right. The haddock is fresh and the batter is light. Best value in Orleans.", author: "Value Seeker", date: date(2025, 7, 12), helpful: 20),
            AggregatedReview(id: "sc-r2", source: .yelp, rating: 4.2, text: "Classic takeout fish and chips. Nothing fancy but consistently good. The fried clams are also worth trying.", author: "Takeout Tim", date: date(2025, 8, 1), helpful: 14),
            AggregatedReview(id: "sc-r3", source: .tripadvisor, rating: 4.4, text: "A local favorite for good reason. Fresh fish, crispy batter, generous portions. Affordable and delicious.", author: "Fish Fan", date: date(2025, 8, 18), helpful: 28),
            AggregatedReview(id: "sc-r4", source: .heycapecod, rating: 4.5, text: "Skip the tourist spots and come here. Best fish and chips in Orleans at half the price. Locals only know.", author: "Orleans Native", date: date(2025, 8, 28), helpful: 36),
            AggregatedReview(id: "sc-r5", source: .google, rating: 4.1, text: "Good fish and chips for a quick meal. Counter service is fast. Great for a casual lunch.", author: "Quick Bite Q.", date: date(2025, 7, 25), helpful: 7),
        ],
        overallRating: 4.3,
        popularDishes: [
            PopularDish(id: "sc-d1", name: "Fish & Chips", mentions: 82, sentiment: 0.91, avgPrice: "$14"),
            PopularDish(id: "sc-d2", name: "Fried Clams", mentions: 38, sentiment: 0.86, avgPrice: "$20"),
            PopularDish(id: "sc-d3", name: "Clam Chowder", mentions: 25, sentiment: 0.84, avgPrice: "$8"),
        ],
        bestTimeToVisit: "Lunch (11:30 AM - 1 PM)",
        aiSummary: "Orleans' best-kept secret for affordable, honest fish and chips. Fresh haddock in a light, crispy batter at prices that won't break the bank. No frills, no fuss - just excellent takeout seafood the way Cape Cod intended.",
        sources: ReviewSource.allCases
    )
}

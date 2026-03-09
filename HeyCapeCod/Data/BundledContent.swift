import CoreLocation

/// Bundled offline fallback data: 15+ Cape Cod Points of Interest with GPS coordinates,
/// geofence radii, story variants (adult/kids/family), quick facts,
/// and insider tips.
///
/// Used as immediate content on first launch and as a fallback when the API is unreachable.
/// The app shows bundled data immediately, then replaces with live API data once loaded.
enum BundledContent {

    static let allPOIs: [PointOfInterest] = [

        // MARK: - Outer Cape

        PointOfInterest(
            id: "whydah-museum",
            name: "Whydah Pirate Museum",
            coordinate: CLLocationCoordinate2D(latitude: 41.7585, longitude: -70.0637),
            geofenceRadius: 200,
            category: .museum,
            town: .yarmouth,
            description: "Home to the only authenticated pirate shipwreck ever discovered. Over 200,000 artifacts from the 1717 wreck of the Whydah Gally.",
            stories: [
                StoryVariant(
                    title: "Black Sam Bellamy and the Whydah",
                    mode: .adult,
                    script: "In 1717, the pirate ship Whydah went down in a fierce nor'easter off Wellfleet. Its captain, 'Black Sam' Bellamy, was just 28 years old and already the wealthiest pirate in recorded history. Bellamy was no ordinary buccaneer. Born in Devon, England, he came to Cape Cod seeking fortune and fell in love with a local girl named Maria Hallett. When her family rejected the penniless sailor, Bellamy turned to piracy, vowing to return rich enough to claim her hand. In just over a year, he captured more than 50 ships. The Whydah itself was a slave ship he seized off the coast of Cuba, converting it into his flagship. On April 26, 1717, Bellamy was sailing north to reunite with Maria when a violent storm drove the Whydah onto a sandbar. Of the 146 men aboard, only two survived. The wreck lay undiscovered for over 260 years until Barry Clifford found it in 1984."
                ),
                StoryVariant(
                    title: "The Pirate's Treasure!",
                    mode: .kids,
                    script: "Arrr! Gather round, me hearties! Long ago, a pirate named Sam sailed these very waters with a ship FULL of treasure. His ship was called the Whydah, and it was the fastest ship on the seven seas! Captain Sam was different from other pirates though. He was kind to his crew and shared his treasure fairly. But one stormy night, the waves got so big they were taller than a house! The Whydah crashed right here near Cape Cod. For hundreds of years, people searched for the treasure. Then one day, a man named Barry went diving and found gold coins, a cannon, and even a pirate bell! You can see the real pirate treasure right here in this museum!"
                ),
                StoryVariant(
                    title: "The Whydah: A Family Adventure",
                    mode: .family,
                    script: "You're approaching one of the most incredible museums on Cape Cod. Inside, you'll find real treasure from a real pirate ship! The Whydah sank in 1717 during a terrible storm. Its captain, Sam Bellamy, was only 28 years old. For over 260 years, the ship sat on the ocean floor until an explorer named Barry Clifford found it in 1984. Since then, divers have brought up over 200,000 artifacts including gold coins, weapons, and the ship's bell. Fun fact for the kids: the Whydah is the only pirate shipwreck that's ever been proven to be real! Keep an eye out for the gold dust and the pistol that belonged to Captain Bellamy himself."
                )
            ],
            facts: [
                "The Whydah is the only authenticated pirate shipwreck ever discovered",
                "Over 200,000 artifacts have been recovered since 1984",
                "Captain Sam Bellamy captured 53 ships in just over one year",
                "The ship's bell, inscribed 'THE WHYDAH GALLY 1716', confirmed the wreck's identity"
            ],
            tips: [
                "Visit on a weekday morning to avoid crowds",
                "The gift shop has great pirate costumes for kids",
                "Ask about the seasonal 'Real Pirates' exhibit for extra artifacts"
            ],
            imageSystemName: "flag.filled.and.flag.crossed"
        ),

        PointOfInterest(
            id: "pilgrim-monument",
            name: "Pilgrim Monument & Museum",
            coordinate: CLLocationCoordinate2D(latitude: 42.0541, longitude: -70.1862),
            geofenceRadius: 250,
            category: .historic,
            town: .provincetown,
            description: "The tallest all-granite structure in the United States, commemorating the Mayflower Pilgrims' first landing in the New World.",
            stories: [
                StoryVariant(
                    title: "The Pilgrims' Forgotten First Landing",
                    mode: .adult,
                    script: "Most Americans believe the Pilgrims landed at Plymouth Rock. But history tells a different story. On November 11, 1620, the Mayflower first dropped anchor right here in Provincetown Harbor. The Pilgrims spent five weeks exploring Cape Cod before deciding to move on to Plymouth. During those five weeks, they signed the Mayflower Compact — the first governing document of the Plymouth Colony and a cornerstone of American democracy. This monument, standing 252 feet tall, was built between 1907 and 1910 to correct the historical record. President Theodore Roosevelt laid the cornerstone himself. Climb the 116 steps and 60 ramps to the top for a panoramic view spanning from the tip of Cape Cod all the way to Boston on a clear day."
                ),
                StoryVariant(
                    title: "The Tallest Tower on Cape Cod!",
                    mode: .kids,
                    script: "Look up! Way, way up! See that giant tower? It's the tallest stone tower in the whole United States! A very long time ago, a big ship called the Mayflower sailed across the ocean with families looking for a new home. And guess where they stopped first? Right here! Before they went to Plymouth, they came to this very spot. The tower has 116 steps inside. If you climb all the way to the top, you can see SO far — you might even spot whales in the ocean! Are you ready to count the steps?"
                )
            ],
            facts: [
                "At 252 feet, it's the tallest all-granite structure in the US",
                "The Mayflower spent 5 weeks in Provincetown before sailing to Plymouth",
                "President Theodore Roosevelt laid the cornerstone in 1907",
                "You can see Boston from the top on clear days"
            ],
            tips: [
                "Go at sunset for the best photos from the top",
                "The museum downstairs is included with admission",
                "Wear comfortable shoes for the 116 steps"
            ],
            imageSystemName: "building.columns.fill"
        ),

        PointOfInterest(
            id: "race-point-beach",
            name: "Race Point Beach",
            coordinate: CLLocationCoordinate2D(latitude: 42.0784, longitude: -70.2087),
            geofenceRadius: 300,
            category: .beach,
            town: .provincetown,
            description: "Wild, windswept beach at the tip of Cape Cod. Famous for whale watching, stunning sunsets, and its untamed Atlantic surf.",
            stories: [
                StoryVariant(
                    title: "Where Two Oceans Meet",
                    mode: .adult,
                    script: "You're standing at one of the most geologically remarkable places on the Atlantic coast. Race Point is where the cold Labrador Current collides with the warm Gulf Stream, creating one of the richest marine ecosystems on Earth. This convergence is why humpback whales migrate here every summer — the churning waters create a feast of sand lance and herring. The 'Race' in Race Point refers to the racing tidal currents that have wrecked more than 3,000 ships over the centuries. The Peaked Hill Bars, just offshore, were so deadly that the US Life-Saving Service built one of its first stations here in 1872. Today, this beach is part of the Cape Cod National Seashore, preserved by President Kennedy in 1961. On a clear evening, you can watch the sun set directly into the ocean — unusual for the East Coast — because the Cape curls back on itself here."
                ),
                StoryVariant(
                    title: "Whale Watch Beach!",
                    mode: .kids,
                    script: "Welcome to one of the coolest beaches on Cape Cod! This is Race Point, and it's a very special place. Do you know why? Because WHALES come here to eat dinner! Big humpback whales swim all the way from the Caribbean just to munch on tiny fish in these waters. Sometimes you can see them right from the beach, jumping out of the water and making a huge splash! And here's something really cool — at this beach, you can watch the sun set INTO the ocean, even though we're on the East Coast. That's because Cape Cod curves around like a giant hook!"
                )
            ],
            facts: [
                "Over 3,000 shipwrecks have occurred in the waters off Provincetown",
                "The sunset here is over the ocean, rare for the East Coast",
                "Part of the Cape Cod National Seashore since 1961",
                "Humpback whales feed just offshore from April through October"
            ],
            tips: [
                "Bring a windbreaker — it's always breezy at the tip",
                "Best whale-watching from shore in late July and August",
                "The Old Harbor Life-Saving Station nearby has free demonstrations in summer"
            ],
            imageSystemName: "water.waves"
        ),

        PointOfInterest(
            id: "highland-light",
            name: "Highland Lighthouse",
            coordinate: CLLocationCoordinate2D(latitude: 42.0389, longitude: -70.0622),
            geofenceRadius: 200,
            category: .lighthouse,
            town: .truro,
            description: "Cape Cod's oldest and tallest lighthouse, first illuminated in 1797. Moved 450 feet inland in 1996 to save it from eroding cliffs.",
            stories: [
                StoryVariant(
                    title: "The Light That Moved",
                    mode: .adult,
                    script: "Highland Light has been guarding this stretch of coast since 1797, when it was the first lighthouse on Cape Cod. The original tower was built by order of George Washington himself. But the real story here is about the relentless power of erosion. When the lighthouse was built, it stood 500 feet from the cliff edge. By 1990, the Atlantic had chewed away so much of the 120-foot clay bluffs that the lighthouse was just 100 feet from the edge. In 1996, engineers undertook an extraordinary rescue: they moved the entire 430-ton lighthouse 450 feet inland on steel rails. The move took 18 days. The light here is visible for 23 miles out to sea, and standing on these cliffs, you can feel exactly why Thoreau called the outer Cape 'the bared and bended arm of Massachusetts.'"
                ),
                StoryVariant(
                    title: "The Lighthouse That Walked!",
                    mode: .kids,
                    script: "Can you imagine picking up a whole lighthouse and moving it? That's exactly what happened here! This lighthouse is VERY old — it was built over 200 years ago. But the ocean kept eating away at the cliff it sat on, getting closer and closer. The waves were like a hungry monster, nibbling at the ground! So some very clever engineers put the entire lighthouse on special rails and slid it 450 feet back from the edge. It took 18 days, and the lighthouse weighs as much as 100 elephants! Pretty amazing, right?"
                )
            ],
            facts: [
                "First lighthouse on Cape Cod, commissioned by George Washington",
                "Moved 450 feet inland in 1996 to escape erosion",
                "The light is visible 23 miles out to sea",
                "Henry David Thoreau visited and wrote about it in 'Cape Cod'"
            ],
            tips: [
                "Summer tours let you climb to the top — check the schedule",
                "The Highland House Museum next door is worth a visit",
                "Best views of the eroding cliffs are from the golf course side"
            ],
            imageSystemName: "light.beacon.max.fill"
        ),

        PointOfInterest(
            id: "marconi-beach",
            name: "Marconi Beach & Station",
            coordinate: CLLocationCoordinate2D(latitude: 41.8900, longitude: -69.9600),
            geofenceRadius: 250,
            category: .historic,
            town: .wellfleet,
            description: "Site of the first transatlantic wireless communication in 1903. Dramatic 60-foot clay cliffs overlook the open Atlantic.",
            stories: [
                StoryVariant(
                    title: "The Message That Changed the World",
                    mode: .adult,
                    script: "On January 18, 1903, President Theodore Roosevelt stood in the White House and sent a wireless message to King Edward VII of England. The signal traveled from right here on this bluff, bounced into the ionosphere, and was received in Cornwall, England. It was the first transatlantic wireless communication between heads of state. Guglielmo Marconi chose this spot carefully — the high clay cliffs gave his antenna towers the elevation they needed. His four wooden towers, each 210 feet tall, stood in a diamond pattern where you see the interpretive markers today. Within years, wireless telegraphy would transform maritime safety, and within decades, Marconi's work would evolve into the radio, television, and wireless technology we use today. Every time you send a text or stream music, you're building on what started right here on a windy bluff in Wellfleet."
                ),
                StoryVariant(
                    title: "The World's First Text Message!",
                    mode: .kids,
                    script: "You know how you can send messages to people far away with a phone? Well, someone had to invent that! And it kind of started RIGHT HERE! A very smart inventor named Marconi built huge towers on this cliff — taller than a 20-story building! He used them to send the very first wireless message across the whole Atlantic Ocean, all the way to England! The President of the United States sent a message to the King of England, and it worked! That was over 120 years ago. So next time you use a phone or tablet, remember — it all started on this beach in Cape Cod!"
                )
            ],
            facts: [
                "First transatlantic wireless message from the US was sent here on January 18, 1903",
                "Marconi's four towers were each 210 feet tall",
                "The original station site has eroded — it was closer to the cliff edge",
                "The beach below has some of the most dramatic cliffs on Cape Cod"
            ],
            tips: [
                "The beach requires a steep staircase — not ideal for mobility issues",
                "Visit the interpretive shelter at the old station site first",
                "Great for body surfing when the waves cooperate"
            ],
            imageSystemName: "antenna.radiowaves.left.and.right"
        ),

        // MARK: - Lower Cape

        PointOfInterest(
            id: "nauset-light",
            name: "Nauset Lighthouse",
            coordinate: CLLocationCoordinate2D(latitude: 41.8583, longitude: -69.9514),
            geofenceRadius: 200,
            category: .lighthouse,
            town: .eastham,
            description: "The iconic red and white lighthouse from the Cape Cod potato chip bags. One of the most photographed landmarks on Cape Cod.",
            stories: [
                StoryVariant(
                    title: "The Most Famous Lighthouse on Your Snack Bag",
                    mode: .adult,
                    script: "If you've ever eaten Cape Cod potato chips, you've seen this lighthouse. Nauset Light's distinctive red and white bands have graced the company's packaging since 1985, making it one of the most recognized lighthouses in America — even by people who've never been to Cape Cod. The lighthouse has had a remarkable journey. It was originally one of the Three Sisters of Nauset — a trio of brick lighthouses built in 1838. This cast-iron tower was actually moved here from Chatham in 1923 to replace them. Then in 1996, like its neighbor Highland Light, it was moved back from the eroding cliff — 300 feet inland to safety. The red and white daymark bands were added so mariners could distinguish it from Highland Light to the north."
                ),
                StoryVariant(
                    title: "The Chip Bag Lighthouse!",
                    mode: .kids,
                    script: "Have you ever seen Cape Cod potato chips? Look at the bag next time — you'll see THIS lighthouse! This is the most famous lighthouse on all of Cape Cod because it's on millions and millions of chip bags! It has red and white stripes so that boats can tell it apart from other lighthouses. And guess what? This lighthouse had to be picked up and moved, just like a big toy, because the cliff was falling into the ocean!"
                )
            ],
            facts: [
                "Featured on Cape Cod potato chip packaging since 1985",
                "Originally moved from Chatham in 1923",
                "Moved 300 feet back from the eroding cliff in 1996",
                "One of the most photographed lighthouses in New England"
            ],
            tips: [
                "Free tours on Sunday evenings in summer (check schedule)",
                "The Three Sisters lighthouses are a short walk through the woods",
                "Nauset Light Beach below has excellent swimming"
            ],
            imageSystemName: "light.beacon.max.fill"
        ),

        PointOfInterest(
            id: "chatham-fish-pier",
            name: "Chatham Fish Pier",
            coordinate: CLLocationCoordinate2D(latitude: 41.6713, longitude: -69.9510),
            geofenceRadius: 150,
            category: .marina,
            town: .chatham,
            description: "Watch fishermen unload the day's catch at this working pier. Home to a thriving seal colony just offshore.",
            stories: [
                StoryVariant(
                    title: "Chatham's Working Waterfront",
                    mode: .adult,
                    script: "You're standing at the heart of one of New England's last great fishing ports. Chatham Fish Pier has been a working waterfront since the town's founding in 1712. Every afternoon, the fleet returns with cod, haddock, flounder, and the prized Chatham day-boat scallops — considered some of the finest in the world because they're harvested and sold the same day. But look out into the harbor and you'll notice something else: seals. Hundreds of grey and harbor seals have taken up residence on the outer bars. Their population has exploded since the Marine Mammal Protection Act of 1972, growing from a few dozen to over 15,000 on Cape Cod. The seals, in turn, have attracted great white sharks to these waters, fundamentally changing the Cape's relationship with the ocean."
                ),
                StoryVariant(
                    title: "Seals and Fish and Boats, Oh My!",
                    mode: .kids,
                    script: "Welcome to the coolest pier on Cape Cod! See those boats coming in? They've been out on the ocean all day catching fish! If you watch carefully, you can see the fishermen unload their catch. And look out there in the water — can you see the seals? There are HUNDREDS of them! They love to hang out on the sand bars and play in the waves. The seals eat lots of fish too, and sometimes they even swim right up to the boats to try to steal a snack!"
                )
            ],
            facts: [
                "Chatham has been a fishing village since 1712",
                "Over 15,000 seals now live around Cape Cod",
                "Chatham day-boat scallops are considered world-class",
                "The seal population has attracted great white sharks to the area"
            ],
            tips: [
                "Arrive around 2-3 PM to watch the fleet unload",
                "Bring binoculars for seal watching from the observation deck",
                "Chatham Pier Fish Market sells the freshest fish you'll ever taste"
            ],
            imageSystemName: "sailboat.fill"
        ),

        PointOfInterest(
            id: "nickerson-state-park",
            name: "Nickerson State Park",
            coordinate: CLLocationCoordinate2D(latitude: 41.7650, longitude: -70.0224),
            geofenceRadius: 400,
            category: .nature,
            town: .brewster,
            description: "1,900 acres of pine forests, kettle ponds, and trails. Home to some of the clearest freshwater swimming on Cape Cod.",
            stories: [
                StoryVariant(
                    title: "The Kettle Ponds of Nickerson",
                    mode: .adult,
                    script: "The crystal-clear ponds hidden in these pine forests were created 15,000 years ago by the last ice age. They're called kettle ponds because of how they formed: enormous chunks of glacial ice broke off and were buried in sand and gravel. When the ice melted, it left behind these perfect, bowl-shaped depressions that filled with groundwater. Cliff Pond, the largest, is 90 feet deep and so clear you can see the sandy bottom in the shallows. These ponds have no streams flowing in or out — they're fed entirely by the Cape's underground aquifer, one of the purest water sources in the eastern United States. The park itself was once the estate of Roland Nickerson, a railroad magnate whose family donated the land in 1934."
                ),
                StoryVariant(
                    title: "Secret Ponds and Ice Age Giants!",
                    mode: .kids,
                    script: "Thousands and thousands of years ago, this whole place was covered in a GIANT glacier — that's a mountain of ice bigger than anything you've ever seen! When the glacier started to melt, huge chunks of ice got buried underground. When those chunks finally melted, they left behind these beautiful ponds! That's why they're called kettle ponds — because they look like big kettles or bowls scooped out of the ground! The water is so clean and clear you can see the bottom. Want to go for a swim? The ponds here are some of the best swimming spots on Cape Cod!"
                )
            ],
            facts: [
                "1,900 acres of protected forest and ponds",
                "Kettle ponds were formed by glacial ice chunks 15,000 years ago",
                "Cliff Pond is 90 feet deep with exceptional clarity",
                "The park offers 8 miles of paved bike trails connected to the Cape Cod Rail Trail"
            ],
            tips: [
                "Cliff Pond and Flax Pond have the best swimming",
                "Rent a kayak at Jack's Boat Rental on Flax Pond",
                "The park connects to the Cape Cod Rail Trail for biking"
            ],
            imageSystemName: "leaf.fill"
        ),

        // MARK: - Mid Cape

        PointOfInterest(
            id: "jfk-museum",
            name: "JFK Hyannis Museum",
            coordinate: CLLocationCoordinate2D(latitude: 41.6528, longitude: -70.2889),
            geofenceRadius: 200,
            category: .museum,
            town: .barnstable,
            description: "Celebrates President Kennedy's deep connection to Cape Cod through photographs, memorabilia, and oral histories.",
            stories: [
                StoryVariant(
                    title: "The Kennedys and Cape Cod",
                    mode: .adult,
                    script: "For the Kennedy family, Cape Cod wasn't just a vacation spot — it was home. Joseph Kennedy Sr. first rented a cottage in Hyannis Port in 1926, and by 1928 he'd bought the large white clapboard house on Marchant Avenue that would become the Kennedy Compound. It was here that John F. Kennedy spent every summer of his life. He sailed these waters, played touch football on the lawn, and in 1960, used the compound as his presidential campaign headquarters. On election night, JFK watched the returns from the Hyannis Armory down the street. The next morning, he walked to the Armory as President-elect. Throughout his presidency, JFK returned to Hyannis Port whenever he could. It was his place of restoration. And it was from here that he championed the creation of the Cape Cod National Seashore in 1961, preserving 40 miles of pristine coastline for future generations."
                ),
                StoryVariant(
                    title: "The President Who Loved the Beach!",
                    mode: .kids,
                    script: "Did you know that a President of the United States used to play on Cape Cod beaches just like you? President Kennedy LOVED Cape Cod! He came here every single summer since he was a little kid. He sailed boats, played football on his lawn, and swam in the ocean. When he became President, he still came back every chance he got. And because he loved Cape Cod so much, he made sure that many of the beaches would be protected forever so that kids like you could always come and play on them!"
                )
            ],
            facts: [
                "The Kennedy family has been in Hyannis Port since 1926",
                "JFK used the compound as his 1960 presidential campaign HQ",
                "Kennedy signed the Cape Cod National Seashore Act in 1961",
                "The museum contains over 80,000 photographs"
            ],
            tips: [
                "The museum is on Main Street in Hyannis — easy walking",
                "Combine with a walk down Main Street for shops and dining",
                "The Kennedy Compound is not open to the public but visible from the harbor"
            ],
            imageSystemName: "building.columns.fill"
        ),

        PointOfInterest(
            id: "kalmus-beach",
            name: "Kalmus Beach",
            coordinate: CLLocationCoordinate2D(latitude: 41.6295, longitude: -70.2793),
            geofenceRadius: 250,
            category: .beach,
            town: .barnstable,
            description: "Popular beach on Nantucket Sound with calm, warm waters. One of the best windsurfing and kiteboarding spots on the East Coast.",
            stories: [
                StoryVariant(
                    title: "The Warm Side of Cape Cod",
                    mode: .adult,
                    script: "Cape Cod has a secret that experienced visitors know well: the south-facing beaches on Nantucket Sound are an entirely different experience from the wild Atlantic beaches to the north. Here at Kalmus Beach, the water is sheltered and significantly warmer — often 10 to 15 degrees warmer than the ocean side. The prevailing southwest winds make this one of the premier windsurfing and kiteboarding destinations on the East Coast. On any summer afternoon, you'll see dozens of colorful kites dancing above the water. The beach is named after Herbert Kalmus, who invented Technicolor — the color film process that transformed Hollywood. He had an estate nearby, and the beach was named in his honor."
                ),
                StoryVariant(
                    title: "The Warm Water Beach!",
                    mode: .kids,
                    script: "This beach has a secret superpower — the water is WARM! While the ocean on the other side of Cape Cod can be really cold, this side is nice and cozy for swimming. And look up in the sky! See those colorful kites flying over the water? Those aren't regular kites — they're attached to people on surfboards! It's called kiteboarding, and Kalmus Beach is one of the best places in the whole country to do it!"
                )
            ],
            facts: [
                "Named after Herbert Kalmus, inventor of Technicolor",
                "Water is 10-15 degrees warmer than the ocean side",
                "Premier East Coast destination for windsurfing and kiteboarding",
                "Faces Nantucket Sound with views of the islands on clear days"
            ],
            tips: [
                "The east end of the beach is designated for windsports",
                "Parking fills early in summer — arrive by 9 AM",
                "Great for families with small children due to calm, warm water"
            ],
            imageSystemName: "wind"
        ),

        // MARK: - Upper Cape

        PointOfInterest(
            id: "sandwich-boardwalk",
            name: "Sandwich Boardwalk",
            coordinate: CLLocationCoordinate2D(latitude: 41.7488, longitude: -70.4853),
            geofenceRadius: 200,
            category: .nature,
            town: .sandwich,
            description: "A 1,350-foot boardwalk stretching across Mill Creek marsh to Town Neck Beach. Each plank is sponsored and inscribed with personal messages.",
            stories: [
                StoryVariant(
                    title: "1,350 Feet of Cape Cod Stories",
                    mode: .adult,
                    script: "Look down as you walk. Every plank beneath your feet tells a story. After a devastating nor'easter destroyed the original boardwalk in 1991, the town of Sandwich devised a brilliant rebuilding plan: they sold each plank for a donation, and the buyers could inscribe them with personal messages. Walk slowly and you'll read declarations of love, memorials to the departed, anniversary celebrations, and inside jokes spanning decades. The boardwalk stretches 1,350 feet across a salt marsh ecosystem that teems with life. Fiddler crabs scuttle below, osprey nest on the platforms above, and the marsh grass filters and cleans the tidal water twice a day. At the end, Town Neck Beach opens up with views of the Cape Cod Canal and, on clear days, Plymouth across the bay."
                ),
                StoryVariant(
                    title: "The Boardwalk of Messages!",
                    mode: .kids,
                    script: "As you walk on this boardwalk, look down at the boards under your feet. See those words carved into them? Each board was bought by a real person who got to write their own special message! Some say 'I love you,' some are birthday wishes, and some remember people who are missed. A big storm wrecked the old boardwalk, so the whole town worked together to build this new one. Now look around — can you spot any crabs? The little fiddler crabs love to play in the mud below! And keep walking all the way to the end to find the beach!"
                )
            ],
            facts: [
                "1,350 feet long across a salt marsh",
                "Rebuilt in 1991 after a nor'easter using sponsored planks",
                "Each plank can be inscribed with a personal message",
                "Sandwich is the oldest town on Cape Cod, founded in 1637"
            ],
            tips: [
                "Read the planks as you walk — some are incredibly touching",
                "Best at sunset when the marsh glows golden",
                "Free parking at the boardwalk lot, but it fills up in peak summer"
            ],
            imageSystemName: "figure.walk"
        ),

        PointOfInterest(
            id: "canal-bike-path",
            name: "Cape Cod Canal Bikeway",
            coordinate: CLLocationCoordinate2D(latitude: 41.7419, longitude: -70.5687),
            geofenceRadius: 300,
            category: .nature,
            town: .bourne,
            description: "A 6.5-mile paved path along the Cape Cod Canal with views of massive ships, the Bourne and Sagamore bridges, and excellent fishing.",
            stories: [
                StoryVariant(
                    title: "The Ditch That Divides a Peninsula",
                    mode: .adult,
                    script: "The Cape Cod Canal is one of the great engineering achievements of the 20th century, and it fundamentally changed what Cape Cod is. Before the canal, Cape Cod was a peninsula. After its completion in 1914, it became technically an island. The idea for a canal dated back to Miles Standish in 1623. George Washington commissioned a survey in 1776. But it took a New York financier named August Belmont Jr. to finally build it, spending his personal fortune on the project. The original canal was narrow and treacherous. The Army Corps of Engineers took it over in 1928, widening it to its current 480 feet and eliminating the dangerous currents. Today, ships carrying everything from oil to automobiles transit the canal daily. The tidal current here can reach 5 knots, making it one of the strongest tidal flows on the East Coast."
                ),
                StoryVariant(
                    title: "Big Ships and Big Bridges!",
                    mode: .kids,
                    script: "See that big ditch full of water? It's called the Cape Cod Canal, and it was dug by people to let big ships pass through! Before the canal was built, ships had to sail ALL the way around Cape Cod, which was a very long and dangerous trip. Now they can take a shortcut right through here! Watch carefully and you might see a huge ship sail by — some of them are longer than a football field! And see those big bridges up there? Cars and trucks drive over them every day to get to Cape Cod!"
                )
            ],
            facts: [
                "The canal is 6.5 miles long and 480 feet wide",
                "Completed in 1914, making Cape Cod technically an island",
                "Tidal currents can reach 5 knots",
                "The Bourne and Sagamore bridges were built in 1935"
            ],
            tips: [
                "Best for biking — flat and paved the entire length",
                "The Bourne side has better sunset views",
                "Fishing is excellent from the banks — striped bass run in spring and fall"
            ],
            imageSystemName: "bicycle"
        ),

        PointOfInterest(
            id: "heritage-museums",
            name: "Heritage Museums & Gardens",
            coordinate: CLLocationCoordinate2D(latitude: 41.7325, longitude: -70.4819),
            geofenceRadius: 250,
            category: .museum,
            town: .sandwich,
            description: "100 acres of spectacular gardens with an antique car collection, art museum, and the famous Dexter Gristmill nearby.",
            stories: [
                StoryVariant(
                    title: "A Pharmaceutical Fortune in Bloom",
                    mode: .adult,
                    script: "These magnificent gardens owe their existence to pharmaceutical fortunes and a passion for horticulture. Josiah K. Lilly III, heir to the Eli Lilly pharmaceutical empire, created this 100-acre estate in the 1960s as a showcase for his collections. The grounds contain one of the finest rhododendron collections in North America, with over 1,000 varieties that bloom in a spectacular display each May and June. But the surprises keep coming: a round Shaker-style barn houses a world-class antique automobile collection, including a 1930 Duesenberg Model J and Gary Cooper's personal 1931 Duesenberg. The art museum features an outstanding collection of American folk art, and the working antique carousel delights children and adults alike."
                ),
                StoryVariant(
                    title: "Old Cars and a Magic Carousel!",
                    mode: .kids,
                    script: "This place is like a treasure box! First, there are AMAZING old cars — some of them are almost 100 years old and they're shinier than a brand-new car! They were driven by movie stars! Then there's a real carousel that you can ride — it goes round and round with beautiful painted horses! And outside, the gardens are HUGE — 100 acres, which is like 75 football fields full of flowers! In spring, the flowers are so colorful it looks like someone spilled a giant box of crayons!"
                )
            ],
            facts: [
                "100 acres of gardens with over 1,000 rhododendron varieties",
                "Antique car collection includes a Duesenberg owned by Gary Cooper",
                "Founded by Josiah K. Lilly III of the Eli Lilly pharmaceutical family",
                "Features a working antique carousel from 1908"
            ],
            tips: [
                "Visit in late May/early June for peak rhododendron season",
                "The carousel ride is included with admission",
                "Allow at least 2-3 hours to see everything"
            ],
            imageSystemName: "camera.macro"
        ),

        PointOfInterest(
            id: "nobska-light",
            name: "Nobska Point Lighthouse",
            coordinate: CLLocationCoordinate2D(latitude: 41.5158, longitude: -70.6553),
            geofenceRadius: 200,
            category: .lighthouse,
            town: .falmouth,
            description: "Iconic lighthouse overlooking Vineyard Sound with views of Martha's Vineyard. One of the most visited lighthouses in Massachusetts.",
            stories: [
                StoryVariant(
                    title: "Guardian of Vineyard Sound",
                    mode: .adult,
                    script: "Nobska Light has watched over the treacherous waters of Vineyard Sound since 1828. The current cast-iron tower, built in 1876, guides vessels through one of the busiest waterways in New England. What makes Nobska unique among lighthouses is its two-tone signal: it shows a white light to ships in safe water, but a red sector beam warns of the dangerous rocks of Hedge Fence shoal to the southwest. From this vantage point, you can see Martha's Vineyard just seven miles across the Sound. On summer evenings, you can watch the island ferries and sailing yachts pass beneath the lighthouse beam. The surrounding grounds have become one of the most popular wedding venues on Cape Cod."
                ),
                StoryVariant(
                    title: "The Two-Color Lighthouse!",
                    mode: .kids,
                    script: "Most lighthouses shine just one color, but this one is special — it shines white AND red! If a boat captain sees the white light, that means 'You're okay, keep going!' But if they see the red light, it means 'Watch out! There are dangerous rocks over here!' It's like a traffic light for boats! And look across the water — can you see that island? That's Martha's Vineyard! Big ferries go back and forth all day long. See if you can spot one!"
                )
            ],
            facts: [
                "First lit in 1828, current tower from 1876",
                "Unique red sector warns of Hedge Fence shoal",
                "Views of Martha's Vineyard, 7 miles across the Sound",
                "One of the most photographed lighthouses in New England"
            ],
            tips: [
                "The grounds are open year-round for free",
                "Best sunset spot in Falmouth — bring a camera",
                "Combine with a walk along the Shining Sea Bikeway nearby"
            ],
            imageSystemName: "light.beacon.max.fill"
        ),

        PointOfInterest(
            id: "cape-cod-rail-trail",
            name: "Cape Cod Rail Trail",
            coordinate: CLLocationCoordinate2D(latitude: 41.7850, longitude: -70.0566),
            geofenceRadius: 300,
            category: .nature,
            town: .brewster,
            description: "A 25.5-mile paved bike path from South Dennis to Wellfleet, following the old Penn Central railroad bed through forests, cranberry bogs, and salt marshes.",
            stories: [
                StoryVariant(
                    title: "Riding the Rails of History",
                    mode: .adult,
                    script: "The path beneath your wheels was once the Penn Central Railroad, the iron lifeline that connected Cape Cod to Boston from the 1860s until the line was abandoned in the 1960s. Trains brought summer tourists, shipped cranberries and fish to market, and for a century defined the rhythm of Cape Cod life. When the rails were pulled up, communities along the route fought to convert the right-of-way into one of the first rail trails in the country. Today, the 25.5-mile path passes through some of Cape Cod's most diverse landscapes: pitch pine forests, freshwater kettle ponds, salt marshes, and working cranberry bogs. Near Brewster, watch for bog cranberry harvesting in October — the flooded red bogs are one of the most iconic sights in New England."
                ),
                StoryVariant(
                    title: "Biking Where Trains Used to Go!",
                    mode: .kids,
                    script: "Did you know that trains used to drive right where you're biking? A long time ago, a railroad went all the way across Cape Cod! Trains would carry people to the beach and bring cranberries to the city. When the trains stopped running, someone had a great idea: turn the old train path into a bike path! Now you can ride for 25 miles! Keep your eyes open for cranberry bogs — they look like swimming pools filled with red berries!"
                )
            ],
            facts: [
                "25.5 miles from South Dennis to Wellfleet",
                "Built on the old Penn Central Railroad right-of-way",
                "One of the first rail-to-trail conversions in the country",
                "Passes through cranberry bogs, kettle ponds, and salt marshes"
            ],
            tips: [
                "Rent bikes at Idle Times in Brewster or Dennis",
                "The Brewster-to-Nickerson section is the most scenic",
                "Bring water — there are long stretches without services"
            ],
            imageSystemName: "bicycle"
        ),

        PointOfInterest(
            id: "wellfleet-drive-in",
            name: "Wellfleet Drive-In Theatre",
            coordinate: CLLocationCoordinate2D(latitude: 41.9284, longitude: -70.0162),
            geofenceRadius: 200,
            category: .entertainment,
            town: .wellfleet,
            description: "One of the last drive-in movie theaters in New England. Also hosts the famous Wellfleet Flea Market on weekends.",
            stories: [
                StoryVariant(
                    title: "Cape Cod's Last Picture Show",
                    mode: .adult,
                    script: "In an age of streaming and multiplexes, the Wellfleet Drive-In is a defiant survivor. Opened in 1957, it's one of fewer than 300 drive-in theaters still operating in America, down from over 4,000 at the peak. The single screen sits on Route 6, and on summer nights, cars line up along the access road waiting for the gates to open. The ritual hasn't changed in decades: park your car, tune your FM radio to the theater's frequency, grab a box of popcorn from the snack bar, and watch the stars come out before the movie begins. During the day on weekends, this same lot transforms into the legendary Wellfleet Flea Market, where over 200 vendors sell everything from antiques to fresh oysters."
                ),
                StoryVariant(
                    title: "Movie Night Under the Stars!",
                    mode: .kids,
                    script: "Imagine watching a movie outside, from INSIDE your car, with the stars twinkling above you! That's what a drive-in theater is, and this is one of the last ones in all of New England! You park your car, tune the radio to hear the movie, and get yummy popcorn and snacks! The movie doesn't start until it gets dark, so you get to watch the sunset first! And here's something cool — on weekends, this same parking lot turns into a giant flea market where people sell all sorts of treasures!"
                )
            ],
            facts: [
                "Operating since 1957 — one of fewer than 300 drive-ins left in America",
                "The Wellfleet Flea Market runs on the same site on weekends",
                "Double features are still shown nightly in summer",
                "Audio is transmitted via FM radio, replacing the old window speakers"
            ],
            tips: [
                "Arrive 30-45 minutes early for the best spots",
                "Bring bug spray and blankets for sitting outside your car",
                "The flea market runs Saturday & Sunday mornings in season"
            ],
            imageSystemName: "film.fill"
        ),
    ]
}

// MARK: - Guided Tour Model

/// A curated guided tour with an ordered list of POI stops.
struct GuidedTour: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let icon: String
    let category: TourCategory
    let estimatedDuration: String
    let distance: String
    let difficulty: TourDifficulty
    let stopIDs: [String]
    let region: CapeRegion?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: GuidedTour, rhs: GuidedTour) -> Bool { lhs.id == rhs.id }

    /// Resolve stop IDs to actual PointOfInterest objects from bundled content.
    func resolvedStops(from allPOIs: [PointOfInterest]) -> [PointOfInterest] {
        stopIDs.compactMap { stopID in
            allPOIs.first { $0.id == stopID }
        }
    }
}

enum TourCategory: String, CaseIterable, Identifiable {
    case lighthouses
    case history
    case nature
    case family
    case foodAndCulture
    case adventure
    case pirate
    case haunted
    case maritime
    case art
    case romantic
    case photography
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lighthouses: "Lighthouses"
        case .history: "History"
        case .nature: "Nature"
        case .family: "Family Fun"
        case .foodAndCulture: "Food & Culture"
        case .adventure: "Adventure"
        case .pirate: "Pirates"
        case .haunted: "Haunted"
        case .maritime: "Maritime"
        case .art: "Art & Culture"
        case .romantic: "Romantic"
        case .photography: "Photo Spots"
        case .custom: "Custom"
        }
    }

    var icon: String {
        switch self {
        case .lighthouses: "light.beacon.max.fill"
        case .history: "building.columns.fill"
        case .nature: "leaf.fill"
        case .family: "figure.2.and.child.holdinghands"
        case .foodAndCulture: "fork.knife"
        case .adventure: "figure.hiking"
        case .pirate: "flag.filled.and.flag.crossed"
        case .haunted: "moon.stars.fill"
        case .maritime: "sailboat.fill"
        case .art: "paintpalette.fill"
        case .romantic: "heart.fill"
        case .photography: "camera.fill"
        case .custom: "sparkles"
        }
    }

    var themeColor: String {
        switch self {
        case .lighthouses: "sandbarYellow"
        case .history: "sunsetOrange"
        case .nature: "duneGrass"
        case .family: "oceanBlue"
        case .foodAndCulture: "cranberry"
        case .adventure: "sunsetOrange"
        case .pirate: "lobsterRed"
        case .haunted: "deepNavy"
        case .maritime: "oceanBlue"
        case .art: "seafoam"
        case .romantic: "cranberry"
        case .photography: "sandbarYellow"
        case .custom: "oceanBlue"
        }
    }
}

enum TourDifficulty: String, Codable {
    case easy, moderate, challenging

    var displayName: String { rawValue.capitalized }

    var color: String {
        switch self {
        case .easy: "duneGrass"
        case .moderate: "sandbarYellow"
        case .challenging: "sunsetOrange"
        }
    }
}

// MARK: - Curated Tours

enum CuratedTours {

    static let all: [GuidedTour] = [
        lighthouseTrail,
        outerCapeHistory,
        familyAdventure,
        canalToSandwich,
        capeTipExplorer,
        piratesAndLegends,
        hauntedCapeCod,
        maritimeHeritage,
        artAndCultureTrail,
        romanticGetaway,
        photoTour,
        foodieCrawl,
    ]

    static let lighthouseTrail = GuidedTour(
        id: "tour-lighthouses",
        name: "Lighthouse Trail",
        subtitle: "Cape Cod's iconic beacons",
        description: "Visit three of Cape Cod's most famous lighthouses, each with a unique story of storms, rescues, and the relentless Atlantic. From the two-color beacon at Nobska to the chip-bag-famous Nauset Light and the lighthouse that walked at Highland.",
        icon: "light.beacon.max.fill",
        category: .lighthouses,
        estimatedDuration: "3-4 hours",
        distance: "65 miles",
        difficulty: .easy,
        stopIDs: ["nobska-light", "nauset-light", "highland-light"],
        region: nil
    )

    static let outerCapeHistory = GuidedTour(
        id: "tour-outer-cape-history",
        name: "Outer Cape History Trail",
        subtitle: "From Pilgrims to wireless radio",
        description: "Trace the stories that shaped America — from the Pilgrims' true first landing in Provincetown, to the spot where Marconi sent the first transatlantic wireless message, to the dramatic cliffs where Highland Light was moved to safety.",
        icon: "building.columns.fill",
        category: .history,
        estimatedDuration: "4-5 hours",
        distance: "30 miles",
        difficulty: .easy,
        stopIDs: ["pilgrim-monument", "marconi-beach", "highland-light", "race-point-beach"],
        region: .outerCape
    )

    static let familyAdventure = GuidedTour(
        id: "tour-family-fun",
        name: "Family Fun Day",
        subtitle: "Kid-friendly Cape Cod highlights",
        description: "A perfect family day hitting Cape Cod's most exciting spots for kids — real pirate treasure, seal watching, swimming in crystal-clear kettle ponds, and a drive-in movie to cap the night.",
        icon: "figure.2.and.child.holdinghands",
        category: .family,
        estimatedDuration: "Full day",
        distance: "45 miles",
        difficulty: .easy,
        stopIDs: ["whydah-museum", "chatham-fish-pier", "nickerson-state-park", "wellfleet-drive-in"],
        region: nil
    )

    static let canalToSandwich = GuidedTour(
        id: "tour-canal-sandwich",
        name: "Canal & Sandwich",
        subtitle: "Upper Cape gems",
        description: "Explore the engineering marvel of the Cape Cod Canal by bike, walk the story-inscribed Sandwich Boardwalk, and wander through 100 acres of gardens and antique cars at Heritage Museums.",
        icon: "bicycle",
        category: .nature,
        estimatedDuration: "3-4 hours",
        distance: "10 miles",
        difficulty: .moderate,
        stopIDs: ["canal-bike-path", "sandwich-boardwalk", "heritage-museums"],
        region: .upperCape
    )

    static let capeTipExplorer = GuidedTour(
        id: "tour-cape-tip",
        name: "Cape Tip Explorer",
        subtitle: "Provincetown & the wild outer shore",
        description: "Journey to the very tip of Cape Cod where two oceans meet. Climb the Pilgrim Monument for panoramic views, then explore Race Point's wild beaches where whales feed just offshore.",
        icon: "water.waves",
        category: .adventure,
        estimatedDuration: "3-4 hours",
        distance: "5 miles",
        difficulty: .moderate,
        stopIDs: ["pilgrim-monument", "race-point-beach"],
        region: .outerCape
    )

    static let piratesAndLegends = GuidedTour(
        id: "tour-pirates",
        name: "Pirates & Legends",
        subtitle: "Shipwrecks, treasure, and tall tales",
        description: "Discover the swashbuckling history of Cape Cod — from Black Sam Bellamy's treasure at the Whydah Museum to the shipwreck-laden waters off Marconi Beach and the spooky drive-in at Wellfleet.",
        icon: "flag.filled.and.flag.crossed",
        category: .pirate,
        estimatedDuration: "4-5 hours",
        distance: "35 miles",
        difficulty: .easy,
        stopIDs: ["whydah-museum", "marconi-beach", "wellfleet-drive-in"],
        region: nil
    )

    static let hauntedCapeCod = GuidedTour(
        id: "tour-haunted",
        name: "Haunted Cape Cod",
        subtitle: "Ghosts, shipwrecks, and eerie legends",
        description: "As night falls on the Cape, the stories come alive. Visit the sites of ghostly sightings, tragic shipwrecks, and unexplained phenomena. From the Lady in Black of Highland Light to the phantom sailors of Marconi Beach, Cape Cod has no shortage of spine-tingling tales.",
        icon: "moon.stars.fill",
        category: .haunted,
        estimatedDuration: "3-4 hours",
        distance: "40 miles",
        difficulty: .easy,
        stopIDs: ["highland-light", "marconi-beach", "wellfleet-drive-in", "whydah-museum"],
        region: nil
    )

    static let maritimeHeritage = GuidedTour(
        id: "tour-maritime",
        name: "Maritime Heritage Trail",
        subtitle: "Fishing, sailing, and seafaring tradition",
        description: "Cape Cod was built on the sea. Follow the maritime heritage from the working waterfront of Chatham Fish Pier to the historic Cape Cod Canal, lighthouses that guided ships for centuries, and the beaches where lifesaving crews risked everything.",
        icon: "sailboat.fill",
        category: .maritime,
        estimatedDuration: "5-6 hours",
        distance: "55 miles",
        difficulty: .moderate,
        stopIDs: ["chatham-fish-pier", "nobska-light", "canal-bike-path", "highland-light"],
        region: nil
    )

    static let artAndCultureTrail = GuidedTour(
        id: "tour-art-culture",
        name: "Art & Culture Trail",
        subtitle: "Galleries, theater, and creative Cape Cod",
        description: "Cape Cod has inspired artists for centuries. From the Provincetown art colony that launched American modernism to the galleries of Wellfleet and the heritage museums of Sandwich, discover the Cape's creative soul.",
        icon: "paintpalette.fill",
        category: .art,
        estimatedDuration: "4-5 hours",
        distance: "60 miles",
        difficulty: .easy,
        stopIDs: ["pilgrim-monument", "wellfleet-drive-in", "heritage-museums", "jfk-museum"],
        region: nil
    )

    static let romanticGetaway = GuidedTour(
        id: "tour-romantic",
        name: "Romantic Cape Cod",
        subtitle: "Sunsets, lighthouses, and seaside charm",
        description: "The perfect couples' tour: watch the sunset from Nobska Light, stroll the inscribed planks of Sandwich Boardwalk, and end the evening at the Wellfleet Drive-In under the stars. Cape Cod at its most enchanting.",
        icon: "heart.fill",
        category: .romantic,
        estimatedDuration: "4-5 hours",
        distance: "50 miles",
        difficulty: .easy,
        stopIDs: ["nobska-light", "sandwich-boardwalk", "race-point-beach", "wellfleet-drive-in"],
        region: nil
    )

    static let photoTour = GuidedTour(
        id: "tour-photo",
        name: "Cape Cod Photo Tour",
        subtitle: "The most Instagrammable spots",
        description: "Hit every iconic photo opportunity on the Cape — from the candy-striped Nauset Light to the dramatic cliffs of Marconi Beach, the boardwalk of a thousand messages, and the wild beauty of Race Point at golden hour.",
        icon: "camera.fill",
        category: .photography,
        estimatedDuration: "Full day",
        distance: "70 miles",
        difficulty: .moderate,
        stopIDs: ["nauset-light", "marconi-beach", "sandwich-boardwalk", "highland-light", "race-point-beach"],
        region: nil
    )

    static let foodieCrawl = GuidedTour(
        id: "tour-foodie",
        name: "Cape Cod Foodie Crawl",
        subtitle: "Seafood shacks, local fare, and sweet treats",
        description: "Taste your way across the Cape — from the freshest catch at Chatham Fish Pier to Provincetown's world-class dining scene, with stops at Wellfleet's legendary oyster beds and the ice cream shops of Main Street Hyannis.",
        icon: "fork.knife",
        category: .foodAndCulture,
        estimatedDuration: "Full day",
        distance: "65 miles",
        difficulty: .easy,
        stopIDs: ["chatham-fish-pier", "jfk-museum", "pilgrim-monument"],
        region: nil
    )
}

// MARK: - Bundled Restaurant Data

/// Bundled restaurant data with menu highlights and community ratings.
enum BundledRestaurants {

    static let all: [Restaurant] = [

        Restaurant(
            id: "rest-chatham-pier-market",
            name: "Chatham Pier Fish Market",
            description: "The freshest seafood on Cape Cod — literally steps from the fishing boats. Famous for their fish & chips, lobster rolls, and chowder made with the day's catch.",
            latitude: 41.6718,
            longitude: -69.9508,
            town: "chatham",
            address: "45 Barcliff Avenue, Chatham",
            cuisine: .seafood,
            priceRange: .moderate,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "10 AM - 7 PM (Seasonal)",
            menuHighlights: [
                MenuItem(id: "cpm-1", name: "Lobster Roll", description: "Fresh-picked lobster on a toasted New England roll with drawn butter", price: 28.99, category: .seafood, communityRating: 4.8, ratingCount: 342, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "cpm-2", name: "Fish & Chips", description: "Beer-battered local cod with hand-cut fries and coleslaw", price: 18.99, category: .seafood, communityRating: 4.6, ratingCount: 287, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "cpm-3", name: "New England Clam Chowder", description: "Creamy chowder loaded with fresh clams, potatoes, and salt pork", price: 9.99, category: .soup, communityRating: 4.7, ratingCount: 198, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "cpm-4", name: "Fried Clam Strips", description: "Tender clam strips lightly breaded and fried golden", price: 16.99, category: .appetizer, communityRating: 4.4, ratingCount: 156, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "cpm-5", name: "Grilled Swordfish Plate", description: "Day-boat swordfish grilled with lemon herb butter", price: 24.99, category: .seafood, communityRating: 4.5, ratingCount: 89, isSignatureDish: false, dietaryTags: [.localCatch, .glutenFree]),
            ],
            averageRating: 4.6,
            totalReviews: 1072,
            tags: ["seafood", "waterfront", "casual", "local catch"]
        ),

        Restaurant(
            id: "rest-arnolds-lobster",
            name: "Arnold's Lobster & Clam Bar",
            description: "A legendary Cape Cod clam shack since 1955. Their fried clams are consistently ranked among the best in New England, and the raw bar is outstanding.",
            latitude: 41.7541,
            longitude: -70.0718,
            town: "eastham",
            address: "3580 State Highway Route 6, Eastham",
            cuisine: .seafood,
            priceRange: .moderate,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "11 AM - 9 PM (Seasonal)",
            menuHighlights: [
                MenuItem(id: "alc-1", name: "Whole Belly Fried Clams", description: "The Cape's best whole belly clams — golden, crispy, and impossibly tender", price: 29.99, category: .seafood, communityRating: 4.9, ratingCount: 523, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "alc-2", name: "Raw Oysters", description: "Wellfleet oysters on the half shell with mignonette and cocktail sauce", price: 18.99, category: .appetizer, communityRating: 4.7, ratingCount: 312, isSignatureDish: true, dietaryTags: [.localCatch, .glutenFree]),
                MenuItem(id: "alc-3", name: "Lobster Mac & Cheese", description: "Creamy four-cheese mac loaded with chunks of fresh lobster", price: 26.99, category: .entree, communityRating: 4.6, ratingCount: 201, isSignatureDish: false, dietaryTags: []),
                MenuItem(id: "alc-4", name: "Clam Chowder", description: "Award-winning creamy New England chowder", price: 10.99, category: .soup, communityRating: 4.5, ratingCount: 178, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "alc-5", name: "Ice Cream Sundae", description: "Homemade ice cream with your choice of toppings", price: 8.99, category: .dessert, communityRating: 4.3, ratingCount: 145, isSignatureDish: false, dietaryTags: []),
            ],
            averageRating: 4.5,
            totalReviews: 1359,
            tags: ["clam shack", "outdoor seating", "family friendly", "cash preferred"]
        ),

        Restaurant(
            id: "rest-lobster-pot",
            name: "The Lobster Pot",
            description: "Provincetown's iconic waterfront restaurant. A Cape Cod institution since 1979, known for their lobster bisque, boiled lobster dinners, and stunning harbor views.",
            latitude: 42.0530,
            longitude: -70.1847,
            town: "provincetown",
            address: "321 Commercial Street, Provincetown",
            cuisine: .seafood,
            priceRange: .upscale,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "11:30 AM - 10 PM",
            menuHighlights: [
                MenuItem(id: "lp-1", name: "Lobster Bisque", description: "The Cape's most famous bisque — rich, creamy, and loaded with lobster", price: 14.99, category: .soup, communityRating: 4.9, ratingCount: 876, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "lp-2", name: "Boiled Lobster Dinner", description: "2 lb live lobster with corn on the cob, drawn butter, and coleslaw", price: 44.99, category: .seafood, communityRating: 4.7, ratingCount: 654, isSignatureDish: true, dietaryTags: [.localCatch, .glutenFree]),
                MenuItem(id: "lp-3", name: "Portuguese Fisherman's Stew", description: "Chorizo, littleneck clams, shrimp, and cod in saffron tomato broth", price: 32.99, category: .seafood, communityRating: 4.8, ratingCount: 312, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "lp-4", name: "Baked Stuffed Lobster", description: "Whole lobster stuffed with scallop and shrimp stuffing", price: 52.99, category: .seafood, communityRating: 4.6, ratingCount: 234, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "lp-5", name: "Wellfleet Oysters Rockefeller", description: "Baked oysters with spinach, cream, and Pernod", price: 18.99, category: .appetizer, communityRating: 4.5, ratingCount: 189, isSignatureDish: false, dietaryTags: [.localCatch]),
            ],
            averageRating: 4.6,
            totalReviews: 2265,
            tags: ["waterfront dining", "iconic", "lobster", "harbor views"]
        ),

        Restaurant(
            id: "rest-captain-linnell",
            name: "Captain Linnell House",
            description: "Fine dining in a beautifully restored 1840 sea captain's mansion. Elegant New England cuisine with a focus on local ingredients and seasonal menus.",
            latitude: 41.7917,
            longitude: -69.9875,
            town: "orleans",
            address: "137 Skaket Beach Road, Orleans",
            cuisine: .fineDining,
            priceRange: .upscale,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "5 PM - 9 PM",
            menuHighlights: [
                MenuItem(id: "clh-1", name: "Pan-Seared Day Boat Scallops", description: "Chatham scallops with truffle risotto and brown butter", price: 38.99, category: .seafood, communityRating: 4.8, ratingCount: 267, isSignatureDish: true, dietaryTags: [.localCatch, .glutenFree]),
                MenuItem(id: "clh-2", name: "Rack of Lamb", description: "Herb-crusted rack with roasted garlic mashed potatoes", price: 42.99, category: .entree, communityRating: 4.7, ratingCount: 189, isSignatureDish: false, dietaryTags: [.glutenFree]),
                MenuItem(id: "clh-3", name: "Lobster Thermidor", description: "Classic preparation with sherry cream sauce, gruyère gratin", price: 46.99, category: .seafood, communityRating: 4.6, ratingCount: 145, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "clh-4", name: "Crème Brûlée", description: "Classic vanilla bean custard with caramelized sugar", price: 12.99, category: .dessert, communityRating: 4.5, ratingCount: 198, isSignatureDish: false, dietaryTags: [.glutenFree]),
            ],
            averageRating: 4.7,
            totalReviews: 799,
            tags: ["fine dining", "romantic", "historic mansion", "prix fixe"]
        ),

        Restaurant(
            id: "rest-pjs-family",
            name: "PJ's Family Restaurant",
            description: "A beloved Cape Cod family restaurant with massive portions and a friendly atmosphere. Famous for their breakfast and fresh-baked pies.",
            latitude: 41.9338,
            longitude: -70.0155,
            town: "wellfleet",
            address: "2616 State Highway Route 6, Wellfleet",
            cuisine: .american,
            priceRange: .budget,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "7 AM - 2 PM",
            menuHighlights: [
                MenuItem(id: "pj-1", name: "Blueberry Pancakes", description: "Fluffy buttermilk pancakes loaded with fresh Cape Cod blueberries", price: 12.99, category: .entree, communityRating: 4.7, ratingCount: 456, isSignatureDish: true, dietaryTags: [.vegetarian]),
                MenuItem(id: "pj-2", name: "Lobster Benedict", description: "Poached eggs and lobster on English muffin with hollandaise", price: 19.99, category: .entree, communityRating: 4.8, ratingCount: 312, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "pj-3", name: "Homemade Pie", description: "Seasonal fruit pie baked fresh daily — ask what's available", price: 7.99, category: .dessert, communityRating: 4.6, ratingCount: 278, isSignatureDish: true, dietaryTags: [.vegetarian]),
                MenuItem(id: "pj-4", name: "Fish Tacos", description: "Grilled local catch with mango salsa and lime crema", price: 15.99, category: .entree, communityRating: 4.4, ratingCount: 167, isSignatureDish: false, dietaryTags: [.localCatch]),
            ],
            averageRating: 4.5,
            totalReviews: 1213,
            tags: ["breakfast", "family friendly", "homemade pies", "generous portions"]
        ),

        Restaurant(
            id: "rest-portuguese-bakery",
            name: "The Portuguese Bakery",
            description: "A Provincetown institution serving authentic Portuguese pastries, breads, and sandwiches since 1950. The malasadas and meat pies are legendary.",
            latitude: 42.0524,
            longitude: -70.1853,
            town: "provincetown",
            address: "299 Commercial Street, Provincetown",
            cuisine: .portuguese,
            priceRange: .budget,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "6 AM - 9 PM",
            menuHighlights: [
                MenuItem(id: "pb-1", name: "Malasadas", description: "Traditional Portuguese fried dough dusted with sugar — warm and pillowy", price: 3.99, category: .dessert, communityRating: 4.9, ratingCount: 876, isSignatureDish: true, dietaryTags: [.vegetarian]),
                MenuItem(id: "pb-2", name: "Portuguese Meat Pie", description: "Savory pie filled with spiced pork and linguiça", price: 6.99, category: .entree, communityRating: 4.7, ratingCount: 543, isSignatureDish: true, dietaryTags: []),
                MenuItem(id: "pb-3", name: "Pastéis de Nata", description: "Classic Portuguese custard tarts with flaky pastry", price: 4.99, category: .dessert, communityRating: 4.8, ratingCount: 412, isSignatureDish: true, dietaryTags: [.vegetarian]),
                MenuItem(id: "pb-4", name: "Linguiça Sandwich", description: "Grilled Portuguese sausage on fresh-baked bread with peppers", price: 9.99, category: .sandwich, communityRating: 4.5, ratingCount: 298, isSignatureDish: false, dietaryTags: []),
            ],
            averageRating: 4.7,
            totalReviews: 2129,
            tags: ["bakery", "Portuguese", "cash only", "local institution"]
        ),

        Restaurant(
            id: "rest-seafood-sams",
            name: "Seafood Sam's",
            description: "A Cape Cod chain of casual seafood restaurants with consistently good fried seafood and family-friendly prices. Multiple locations across the Cape.",
            latitude: 41.7636,
            longitude: -70.4943,
            town: "sandwich",
            address: "6 Coast Guard Road, Sandwich",
            cuisine: .casual,
            priceRange: .moderate,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "11 AM - 9 PM",
            menuHighlights: [
                MenuItem(id: "ss-1", name: "Fisherman's Platter", description: "Fried clams, scallops, shrimp, and fish with fries and coleslaw", price: 32.99, category: .seafood, communityRating: 4.5, ratingCount: 567, isSignatureDish: true, dietaryTags: [.localCatch]),
                MenuItem(id: "ss-2", name: "Clam Roll", description: "Whole belly clams on a toasted New England roll", price: 22.99, category: .sandwich, communityRating: 4.4, ratingCount: 345, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "ss-3", name: "Kids Fish & Chips", description: "Kid-sized portion of fried fish with fries", price: 9.99, category: .kids, communityRating: 4.3, ratingCount: 234, isSignatureDish: false, dietaryTags: []),
                MenuItem(id: "ss-4", name: "Garden Salad with Grilled Fish", description: "Fresh greens topped with grilled catch of the day", price: 18.99, category: .salad, communityRating: 4.2, ratingCount: 123, isSignatureDish: false, dietaryTags: [.glutenFree, .localCatch]),
            ],
            averageRating: 4.3,
            totalReviews: 1269,
            tags: ["family friendly", "casual", "kid-friendly", "multiple locations"]
        ),

        Restaurant(
            id: "rest-mac-seafood",
            name: "Mac's Seafood",
            description: "Farm-to-table seafood from their own oyster farm and fishing fleet. Multiple locations in Wellfleet and Eastham with the freshest local seafood.",
            latitude: 41.9297,
            longitude: -70.0361,
            town: "wellfleet",
            address: "265 Commercial Street, Wellfleet",
            cuisine: .farmToTable,
            priceRange: .moderate,
            imageUrl: nil,
            phoneNumber: nil,
            websiteUrl: nil,
            hours: "11 AM - 8 PM (Seasonal)",
            menuHighlights: [
                MenuItem(id: "ms-1", name: "Wellfleet Oysters", description: "From their own oyster farm — briny, sweet, and impossibly fresh", price: 16.99, category: .appetizer, communityRating: 4.9, ratingCount: 678, isSignatureDish: true, dietaryTags: [.localCatch, .glutenFree]),
                MenuItem(id: "ms-2", name: "Sushi-Grade Tuna Poke Bowl", description: "Fresh tuna poke with avocado, edamame, and sesame", price: 22.99, category: .entree, communityRating: 4.7, ratingCount: 345, isSignatureDish: true, dietaryTags: [.localCatch, .glutenFree]),
                MenuItem(id: "ms-3", name: "Lobster Roll", description: "Chilled lobster salad on a buttered roll with chips", price: 26.99, category: .seafood, communityRating: 4.6, ratingCount: 456, isSignatureDish: false, dietaryTags: [.localCatch]),
                MenuItem(id: "ms-4", name: "Fish Tacos", description: "Grilled mahi-mahi with pineapple salsa and chipotle crema", price: 17.99, category: .entree, communityRating: 4.5, ratingCount: 234, isSignatureDish: false, dietaryTags: [.localCatch]),
            ],
            averageRating: 4.6,
            totalReviews: 1713,
            tags: ["oyster farm", "farm to table", "fresh local seafood", "outdoor seating"]
        ),
    ]
}

-- ============================================================
-- VallartApp — Supabase Seed Data
-- Run this in: supabase.com → your project → SQL Editor
-- ============================================================

-- Clear existing data (safe to re-run)
truncate table reviews restart identity cascade;
truncate table listings restart identity cascade;
truncate table events  restart identity cascade;

-- ============================================================
-- LISTINGS
-- ============================================================
insert into listings (name, category, neighborhood, address, latitude, longitude, description, photos, rating, review_count, price_range, phone, website, instagram, tags, is_premium, is_featured, is_open, open_hours, is_lgbt_friendly) values

-- RESTAURANTS
('Café des Artistes',
 'restaurants', 'centro',
 'Guadalupe Sánchez 740, Centro',
 20.6060, -105.2370,
 'Puerto Vallarta''s most celebrated fine dining restaurant. Set in a stunning art-filled mansion, offering contemporary Mexican cuisine with French influences.',
 array[]::text[], 4.9, 842, 4,
 '+52 322 222 3228', 'https://cafedesartistes.com', '@cafedesartistes_pv',
 array['Fine Dining','Mexican','Romantic','Art'],
 true, true, true, '6:00 PM – 11:30 PM', false),

('El Arrayán',
 'restaurants', 'zonaRomantica',
 'Allende 344, Zona Romántica',
 20.5990, -105.2380,
 'Award-winning restaurant serving authentic Mexican home cooking with a twist. Famous for their mole and mezcal selection.',
 array[]::text[], 4.7, 612, 3,
 '+52 322 222 7195', null, null,
 array['Mexican','Mole','Mezcal','Authentic'],
 true, true, true, '5:30 PM – 11:00 PM', false),

('La Palapa',
 'restaurants', 'zonaRomantica',
 'Pulpito 103, Playa Los Muertos',
 20.5975, -105.2395,
 'Iconic beachfront restaurant on Los Muertos Beach. Fresh seafood, tropical cocktails, and your feet in the sand.',
 array[]::text[], 4.6, 1203, 3,
 '+52 322 222 5225', null, null,
 array['Seafood','Beachfront','Tropical','Brunch'],
 true, false, true, '8:00 AM – 11:00 PM', true),

('Taco Bar Sayulita',
 'restaurants', 'sayulita',
 'Calle Revolución s/n, Sayulita',
 20.8695, -105.4450,
 'The best street tacos in Sayulita. Legendary al pastor, fresh tortillas, and cold cervezas.',
 array[]::text[], 4.8, 378, 1,
 null, null, null,
 array['Tacos','Street Food','Local','Casual'],
 false, false, true, '12:00 PM – 10:00 PM', false),

-- BARS & NIGHTLIFE
('Los Muertos Brewing',
 'bars', 'zonaRomantica',
 'Lázaro Cárdenas 302, Zona Romántica',
 20.5985, -105.2378,
 'Puerto Vallarta''s first craft brewery. Tropical-inspired beers brewed on-site, lively rooftop terrace with ocean views.',
 array[]::text[], 4.7, 521, 2,
 '+52 322 222 6516', null, null,
 array['Craft Beer','Rooftop','LGBT Friendly','Live Music'],
 true, true, true, '2:00 PM – 1:00 AM', true),

('Mandala Beach Club',
 'bars', 'hotelZone',
 'Blvd. Francisco Medina Ascencio, Zona Hotelera',
 20.6350, -105.2410,
 'Puerto Vallarta''s hottest beach club and nightclub. International DJs, bottle service, swim-up bar.',
 array[]::text[], 4.4, 897, 3,
 null, null, null,
 array['Club','Beach Club','DJ','Party'],
 true, true, false, '10:00 PM – 5:00 AM', false),

('La Noche Bar',
 'bars', 'zonaRomantica',
 'Lázaro Cárdenas 257, Zona Romántica',
 20.5982, -105.2375,
 'Beloved LGBT+ bar in the heart of Zona Romántica. Weekly drag shows, theme nights, and the friendliest staff in PV.',
 array[]::text[], 4.8, 443, 2,
 null, null, '@lanochepv',
 array['LGBT+','Drag Shows','Gay Bar','Fun'],
 false, true, true, '6:00 PM – 3:00 AM', true),

-- HOTELS
('Garza Blanca Preserve Resort & Spa',
 'hotels', 'hotelZone',
 'Carr. Barra de Navidad Km 7.5',
 20.5610, -105.2570,
 'Ultra-luxury 5-star resort with private beach, multiple pools, gourmet restaurants, and world-class spa. The pinnacle of Vallarta luxury.',
 array[]::text[], 4.9, 1876, 4,
 '+52 322 176 0700', 'https://garzablanca.com', null,
 array['5-Star','Luxury','Spa','Private Beach','All-Inclusive Option'],
 true, true, true, '24 hours', false),

('Casa Kimberly',
 'hotels', 'centro',
 'Zaragoza 445, Centro',
 20.6048, -105.2360,
 'The legendary former home of Elizabeth Taylor & Richard Burton, converted into a stunning boutique luxury hotel. History, romance, and views.',
 array[]::text[], 4.8, 634, 4,
 '+52 322 222 1336', 'https://casakimberly.com', null,
 array['Boutique','Historic','Romantic','Views','Adults Only'],
 true, true, true, '24 hours', false),

('W Punta de Mita',
 'hotels', 'puntaMita',
 'Lote H-1, Corral del Risco, Punta de Mita',
 20.7715, -105.4970,
 'Ultra-cool luxury resort in Punta Mita. Celebrity hotspot with stunning beach, W Lounge, and insane pool scene.',
 array[]::text[], 4.7, 912, 4,
 null, null, null,
 array['5-Star','Beach','Pool','Celebrity','Surfing'],
 true, false, true, '24 hours', false),

-- ACTIVITIES
('Marietas Islands Snorkeling & Hidden Beach',
 'activities', 'puntaMita',
 'Departs from La Cruz Marina',
 20.7130, -105.5600,
 'Iconic tour to the Marieta Islands — a UNESCO protected area. Snorkel with sea turtles, manta rays, and visit the famous Hidden Beach (Playa del Amor).',
 array[]::text[], 4.9, 2341, 2,
 '+52 322 297 1212', null, null,
 array['Snorkeling','Wildlife','UNESCO','Hidden Beach','Day Trip'],
 false, true, true, '8:00 AM – 5:00 PM', false),

('Canopy River Zip-line & ATV',
 'activities', 'centro',
 'Carr. a Boca de Tomatlán Km 3',
 20.5720, -105.2490,
 'Thrilling zip-line tour through the jungle canopy above the Cuale River. Combine with ATV adventure and a traditional Mexican lunch.',
 array[]::text[], 4.7, 1564, 3,
 '+52 322 222 4330', null, null,
 array['Zip-line','ATV','Jungle','Adventure','Family'],
 true, true, true, '8:00 AM – 5:00 PM', false),

('Whale Watching PV (Nov–Mar)',
 'activities', 'marina',
 'Departs from Marina Vallarta',
 20.6720, -105.2540,
 'Seasonal humpback whale watching tours. Puerto Vallarta''s Banderas Bay is one of the world''s best spots to see humpback whales November through March.',
 array[]::text[], 4.9, 876, 2,
 null, null, null,
 array['Whale Watching','Seasonal','Wildlife','Ocean','Photography'],
 false, true, false, 'Nov–Mar: 8:00 AM – 1:00 PM', false),

('Sayulita Surf School',
 'activities', 'sayulita',
 'Playa Sayulita, Sayulita',
 20.8690, -105.4460,
 'Learn to surf in one of Mexico''s most famous surf towns. Beginners to advanced lessons, board rentals, daily surf camps.',
 array[]::text[], 4.8, 445, 2,
 null, null, '@sayulitasurf',
 array['Surfing','Lessons','Beginner','Sayulita','Beach'],
 false, true, true, '7:00 AM – 6:00 PM', false),

-- YACHT RENTALS
('Sunset Sailing Cruise PV',
 'yachts', 'marina',
 'Marina Vallarta, Dock B',
 20.6715, -105.2545,
 '4-hour sunset sailing cruise aboard a 42ft catamaran. Open bar, snorkeling stop, live music. The most romantic experience in Puerto Vallarta.',
 array[]::text[], 4.9, 1123, 3,
 '+52 322 225 4777', null, null,
 array['Sunset','Catamaran','Open Bar','Snorkeling','Romantic'],
 true, true, true, '3:00 PM – 7:00 PM', true),

('Private Yacht Charter — Marietas',
 'yachts', 'marina',
 'Marina Vallarta',
 20.6718, -105.2548,
 'Full-day private yacht charter to the Marieta Islands. Up to 12 guests. Includes captain, crew, gourmet catering, snorkel equipment, paddleboards.',
 array[]::text[], 4.8, 312, 4,
 '+52 322 225 5000', null, null,
 array['Private','Charter','Full Day','Luxury','Snorkeling'],
 true, false, true, '8:00 AM – 6:00 PM', false),

('PV Sport Fishing Charter',
 'yachts', 'marina',
 'Marina Vallarta, Dock C',
 20.6720, -105.2550,
 'World-class sport fishing in Banderas Bay. Full-day and half-day charters. Target: Marlin, Sailfish, Mahi-Mahi, Tuna. All equipment included.',
 array[]::text[], 4.7, 234, 4,
 null, null, null,
 array['Fishing','Sport Fishing','Marlin','Deep Sea','Charter'],
 false, false, true, '6:00 AM – 3:00 PM', false),

-- CAR & MOTO RENTALS
('Vallarta Car Rental',
 'rentals', 'centro',
 'Blvd. Francisco Medina Ascencio 1728',
 20.6320, -105.2430,
 'Best rates on car rentals in Puerto Vallarta. Large fleet: economy cars, SUVs, convertibles. Airport pickup available.',
 array[]::text[], 4.5, 678, 2,
 '+52 322 222 0999', null, null,
 array['Car Rental','Airport','SUV','Economy','Convertible'],
 true, false, true, '8:00 AM – 8:00 PM', false),

('Moto Rent PV',
 'rentals', 'zonaRomantica',
 'Olas Altas 390, Zona Romántica',
 20.5988, -105.2371,
 'Scooters, motorbikes, and ATVs for rent by the hour or day. Explore PV on two wheels. Helmets and insurance included.',
 array[]::text[], 4.6, 289, 1,
 '+52 322 222 1234', null, '@motorentpv',
 array['Moto','Scooter','ATV','Hourly','Daily'],
 false, false, true, '9:00 AM – 7:00 PM', false),

-- BEACHES
('Playa Los Muertos',
 'beaches', 'zonaRomantica',
 'Playa Los Muertos, Zona Romántica',
 20.5970, -105.2400,
 'Puerto Vallarta''s most famous and vibrant beach. Gay-friendly south end (Blue Chairs), beach restaurants, volleyball, parasailing, and legendary sunsets.',
 array[]::text[], 4.8, 4521, 0,
 null, null, null,
 array['Gay Friendly','Beach Bars','Sunset','Volleyball','Central'],
 false, true, true, 'Always open', true),

('Playa Sayulita',
 'beaches', 'sayulita',
 'Sayulita, Nayarit',
 20.8685, -105.4458,
 'Charming bohemian surf beach in Sayulita. Mexican fishermen, surfers, and hippie travelers all coexist. Colorful town, great tacos nearby.',
 array[]::text[], 4.7, 2134, 0,
 null, null, null,
 array['Surf','Bohemian','Town','Colorful','Fishing'],
 false, true, true, 'Always open', false),

-- SHOPPING (new — was missing from mock!)
('Mercado de Artesanías',
 'shopping', 'centro',
 'Agustín Rodríguez 164, Centro',
 20.6042, -105.2348,
 'Puerto Vallarta''s famous artisan market. Huichol beadwork, Talavera ceramics, handwoven textiles, leather goods, and silver jewelry. Best souvenirs in PV.',
 array[]::text[], 4.5, 1872, 1,
 null, null, null,
 array['Artisan','Souvenirs','Huichol','Handmade','Market'],
 false, true, true, '9:00 AM – 8:00 PM', false),

('La Catrina Galería & Boutique',
 'shopping', 'centro',
 'Juárez 510, Centro',
 20.6055, -105.2362,
 'Curated boutique showcasing Mexican folk art, Day of the Dead art, contemporary Mexican designers, and unique gifts. Beautifully presented.',
 array[]::text[], 4.7, 234, 2,
 null, null, '@lacatrinapv',
 array['Boutique','Folk Art','Day of the Dead','Mexican Design','Gifts'],
 false, false, true, '10:00 AM – 8:00 PM', false),

('Sayulita Market Collective',
 'shopping', 'sayulita',
 'Calle Delfín, Sayulita',
 20.8698, -105.4448,
 'Weekly artisan market in Sayulita. Local jewelry makers, surf brands, vintage clothing, organic foods, and live music every Saturday.',
 array[]::text[], 4.6, 312, 1,
 null, null, null,
 array['Market','Artisan','Vintage','Organic','Saturday'],
 false, false, true, 'Saturdays 10:00 AM – 4:00 PM', false),

-- SPAS
('Garza Blanca Spa',
 'spas', 'hotelZone',
 'Carr. Barra de Navidad Km 7.5',
 20.5612, -105.2572,
 'World-class spa at Garza Blanca Resort. Signature treatments inspired by Mexican healing traditions. Ocean views, hydrotherapy, couples suites.',
 array[]::text[], 4.9, 456, 4,
 '+52 322 176 0700', null, null,
 array['Luxury Spa','Couples','Hydrotherapy','Ocean Views','Massage'],
 true, true, true, '9:00 AM – 9:00 PM', false);


-- ============================================================
-- EVENTS (using relative dates from now)
-- ============================================================
insert into events (title, description, neighborhood, address, latitude, longitude,
  start_date, end_date, is_public, is_free, ticket_price, ticket_url,
  photos, tags, organizer, instagram, is_premium, is_featured,
  is_lgbt_friendly, is_recurring, recurrence_label) values

('Vallarta Pride 2026',
 'Puerto Vallarta''s world-famous Pride festival. Week-long celebration in Zona Romántica with parades, concerts, beach parties, and the iconic Pride parade along the Malecón.',
 'zonaRomantica', 'Zona Romántica & Malecón',
 20.5985, -105.2380,
 now() + interval '14 days', now() + interval '21 days',
 true, true, null, null,
 array[]::text[], array['Pride','LGBT+','Parade','Festival','Annual'],
 'Vallarta Pride Organization', '@vallartapride',
 false, true, true, true, 'Annual'),

('Moonlight Jazz at the Marina',
 'Exclusive monthly jazz evening at Marina Vallarta''s premier yacht club. Live jazz quartet, gourmet tapas, and craft cocktails under the stars. Limited tickets.',
 'marina', 'Yacht Club Marina Vallarta',
 20.6715, -105.2545,
 now() + interval '3 days', now() + interval '3 days' + interval '4 hours',
 false, false, 850, null,
 array[]::text[], array['Jazz','Live Music','Cocktails','Exclusive','Marina'],
 'Marina Yacht Club', null,
 true, false, false, true, 'Monthly'),

('Sayulita Surf Competition',
 'Annual amateur and pro surf competition at Playa Sayulita. Watch world-class surfers tear up the waves. Free entry for spectators, food and craft vendors.',
 'sayulita', 'Playa Sayulita',
 20.8685, -105.4458,
 now() + interval '7 days', now() + interval '9 days',
 true, true, null, null,
 array[]::text[], array['Surf','Competition','Sayulita','Sport','Annual'],
 'Sayulita Surf Club', null,
 false, true, false, true, 'Annual'),

('Gourmet Food & Wine Festival',
 'Puerto Vallarta''s renowned Gourmet Festival. 10 days of special menus, wine pairings, and culinary events at 50+ top restaurants. The ultimate foodie event in Mexico.',
 'centro', 'Multiple venues, Puerto Vallarta',
 20.6060, -105.2370,
 now() + interval '30 days', now() + interval '40 days',
 true, false, 500, null,
 array[]::text[], array['Gourmet','Wine','Restaurants','Festival','Annual'],
 'Festival Gourmet International', null,
 false, true, false, true, 'Annual - November'),

('Thursday Night Art Walk',
 'Every Thursday the Centro galleries open late for a self-guided art walk. Meet local and international artists, enjoy wine, and discover PV''s thriving art scene.',
 'centro', 'Zona Centro, starting at Galería Dante',
 20.6050, -105.2355,
 now() + interval '4 days', now() + interval '4 days' + interval '4 hours',
 true, true, null, null,
 array[]::text[], array['Art','Galleries','Culture','Wine','Weekly'],
 'PV Art Galleries Association', null,
 false, false, false, true, 'Every Thursday'),

('Sunset Beach Party — Blue Chairs',
 'The legendary daily sunset party at Blue Chairs Resort on Los Muertos Beach. DJs, dancers, signature cocktails, and the best sunset view in town.',
 'zonaRomantica', 'Blue Chairs Resort, Playa Los Muertos',
 20.5968, -105.2398,
 now() + interval '1 day', now() + interval '1 day' + interval '4 hours',
 true, true, null, null,
 array[]::text[], array['Sunset','DJ','Beach','LGBT+','Daily'],
 'Blue Chairs Resort', null,
 false, true, true, true, 'Daily');


-- ============================================================
-- RLS POLICIES
-- Enable Row Level Security and set access rules
-- ============================================================

-- LISTINGS: anyone can read, only service_role can write (admin portal)
alter table listings enable row level security;
drop policy if exists "Public read listings" on listings;
create policy "Public read listings"
  on listings for select using (true);

-- EVENTS: anyone can read
alter table events enable row level security;
drop policy if exists "Public read events" on events;
create policy "Public read events"
  on events for select using (true);

-- REVIEWS: anyone can read, authenticated users can insert their own
alter table reviews enable row level security;
drop policy if exists "Public read reviews" on reviews;
drop policy if exists "Auth users insert reviews" on reviews;
create policy "Public read reviews"
  on reviews for select using (true);
create policy "Auth users insert reviews"
  on reviews for insert with check (auth.uid() = user_id);

-- PROFILES: users can only read/write their own profile
alter table profiles enable row level security;
drop policy if exists "Users manage own profile" on profiles;
create policy "Users manage own profile"
  on profiles for all using (auth.uid() = id);

-- BUSINESS_OWNERS: users can only read their own record
alter table business_owners enable row level security;
drop policy if exists "Users read own business_owner" on business_owners;
create policy "Users read own business_owner"
  on business_owners for select using (auth.uid() = user_id);

-- ============================================================
-- DONE ✅
-- Check results:
-- select count(*) from listings;   -- should be 25
-- select count(*) from events;     -- should be 6
-- ============================================================

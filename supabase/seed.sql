-- ============================================================
-- VallartApp — Full Supabase Seed (schema + data)
-- Run this in: supabase.com → your project → SQL Editor
-- ============================================================
-- Category values MUST match Swift ListingCategory.rawValue exactly:
--   "Restaurants" | "Bars & Nightlife" | "Hotels" | "Activities"
--   "Yacht Rentals" | "Car & Moto Rental" | "Events" | "Beaches"
--   "Shopping" | "Spas & Wellness"
--
-- Neighborhood values MUST match Swift Neighborhood.rawValue exactly:
--   "Centro" | "Zona Romántica" | "Marina" | "Hotel Zone"
--   "Nuevo Vallarta" | "Bucerías" | "La Cruz" | "Punta Mita"
--   "Sayulita" | "San Pancho" | "Yelapa"
--
-- price_range: 0=Free 1=Budget 2=Moderate 3=Upscale 4=Luxury
-- ============================================================

-- ── 1. CREATE TABLES ─────────────────────────────────────────

create table if not exists listings (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  category      text not null,
  neighborhood  text not null,
  address       text,
  latitude      double precision,
  longitude     double precision,
  description   text,
  photos        text[],
  rating        double precision default 0,
  review_count  integer default 0,
  price_range   integer default 2,
  phone         text,
  website       text,
  instagram     text,
  tags          text[],
  is_premium    boolean default false,
  is_featured   boolean default false,
  is_open       boolean default true,
  open_hours    text,
  is_lgbt_friendly boolean default false,
  created_at    timestamptz default now()
);

create table if not exists events (
  id               uuid primary key default gen_random_uuid(),
  title            text not null,
  description      text,
  neighborhood     text,
  address          text,
  latitude         double precision,
  longitude        double precision,
  start_date       timestamptz,
  end_date         timestamptz,
  is_public        boolean default true,
  is_free          boolean default true,
  ticket_price     double precision,
  ticket_url       text,
  photos           text[],
  tags             text[],
  organizer        text,
  phone            text,
  instagram        text,
  is_premium       boolean default false,
  is_featured      boolean default false,
  is_lgbt_friendly boolean default false,
  is_recurring     boolean default false,
  recurrence_label text,
  created_at       timestamptz default now()
);

create table if not exists profiles (
  id                uuid primary key references auth.users on delete cascade,
  name              text,
  avatar_url        text,
  saved_listing_ids uuid[] default '{}',
  is_business_owner boolean default false,
  created_at        timestamptz default now()
);

create table if not exists reviews (
  id            uuid primary key default gen_random_uuid(),
  listing_id    uuid references listings on delete cascade,
  user_id       uuid references auth.users on delete cascade,
  author_name   text not null,
  author_avatar text default 'person.circle.fill',
  rating        double precision not null,
  text          text not null,
  created_at    timestamptz default now()
);

create table if not exists business_owners (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users on delete cascade,
  listing_id uuid references listings on delete cascade,
  plan       text default 'free',
  created_at timestamptz default now()
);

-- ── 2. CLEAR & RESEED ────────────────────────────────────────
truncate table reviews    restart identity cascade;
truncate table listings   restart identity cascade;
truncate table events     restart identity cascade;

-- ── 3. LISTINGS ──────────────────────────────────────────────
insert into listings (
  name, category, neighborhood,
  address, latitude, longitude,
  description, photos,
  rating, review_count, price_range,
  phone, website, instagram, tags,
  is_premium, is_featured, is_open, open_hours, is_lgbt_friendly
) values

-- RESTAURANTS
('Café des Artistes',
 'Restaurants', 'Centro',
 'Guadalupe Sánchez 740, Centro, Puerto Vallarta',
 20.6055, -105.2368,
 'Puerto Vallarta''s most celebrated fine-dining restaurant, open 35+ years. Chef Thierry Blouet transforms ingredients into culinary art inside a stunning colonial mansion. Smart casual — children 8+ only.',
 array['fork.knife'], 4.8, 7377, 4,
 '+52 322 226 7200', 'https://cafedesartistes.com', '@cafedeartistes',
 array['Fine Dining','French-Mexican Fusion','Romantic','Award-Winning','Wine List'],
 true, true, true, 'Mon–Sun 4:00 PM – 12:00 AM', false),

('Tuna Azul',
 'Restaurants', 'Zona Romántica',
 'Rodolfo Gómez 109, Col. E. Zapata, Puerto Vallarta',
 20.5983, -105.2371,
 '#1 on TripAdvisor Puerto Vallarta. Family-run gem serving fresh tuna aguachile, marlin al pastor, and octopus chicharrón. Tiny space, huge flavor — arrive early.',
 array['fork.knife'], 4.9, 2865, 2,
 '+52 322 222 0795', null, '@tunaazulpv',
 array['Seafood','Fresh Tuna','Local Favorite','Authentic Mexican','Casual'],
 false, true, true, 'Tue–Sun 11:00 AM – 6:00 PM', true),

('La Palapa',
 'Restaurants', 'Zona Romántica',
 'Pulpito 103, Playa Los Muertos, Puerto Vallarta',
 20.5971, -105.2397,
 'Iconic beachfront restaurant on Los Muertos Beach since 1959. Fresh Pacific seafood, tropical cocktails, and legendary breakfasts with your feet in the sand.',
 array['fork.knife'], 4.5, 7272, 2,
 '+52 322 222 5225', 'https://lapalapapv.com', '@lapalapapv',
 array['Beachfront','Seafood','Breakfast','Brunch','Iconic','Tropical'],
 true, true, true, 'Daily 8:00 AM – 11:00 PM', true),

('Mar Y Vino',
 'Restaurants', 'Hotel Zone',
 'Paseo de la Marina Sur 220, Marina Vallarta, Puerto Vallarta',
 20.6658, -105.2598,
 'Clifftop restaurant with sweeping panoramic views of Banderas Bay. Contemporary Mexican cuisine and an outstanding wine list. Perfect for sunsets.',
 array['fork.knife'], 4.8, 2172, 3,
 '+52 322 221 0722', 'https://maryvino.com', '@maryvino_pv',
 array['Panoramic Views','Sunset','Mexican','Wine','Romantic','Seafood'],
 true, true, true, 'Mon–Sun 1:00 PM – 11:00 PM', false),

('Barcelona Tapas',
 'Restaurants', 'Centro',
 'Morelos 531, Centro, Puerto Vallarta',
 20.6060, -105.2345,
 'Puerto Vallarta''s beloved Spanish tapas bar with 3,300+ reviews. Authentic patatas bravas, jamón ibérico, seafood croquetas, paella, and incredible sangria on the Malecon.',
 array['fork.knife'], 4.7, 3302, 2,
 '+52 322 222 0510', 'https://barcelonatapas.net', '@barcelonatapas_pv',
 array['Spanish','Tapas','Sangria','Paella','Malecon','Late Night'],
 false, true, true, 'Mon–Sun 12:00 PM – 1:00 AM', false),

-- BARS & NIGHTLIFE
('Los Muertos Brewing',
 'Bars & Nightlife', 'Zona Romántica',
 'Lázaro Cárdenas 302, Zona Romántica, Puerto Vallarta',
 20.5985, -105.2378,
 'Puerto Vallarta''s first craft brewery. Tropical-inspired beers brewed on-site, lively rooftop terrace with ocean views.',
 array['music.note'], 4.7, 521, 2,
 '+52 322 222 6516', null, null,
 array['Craft Beer','Rooftop','LGBT Friendly','Live Music'],
 true, true, true, '2:00 PM – 1:00 AM', true),

('Mandala Beach Club',
 'Bars & Nightlife', 'Hotel Zone',
 'Blvd. Francisco Medina Ascencio, Hotel Zone, Puerto Vallarta',
 20.6350, -105.2410,
 'Puerto Vallarta''s hottest beach club and nightclub. International DJs, bottle service, swim-up bar.',
 array['music.note'], 4.4, 897, 3,
 null, null, null,
 array['Club','Beach Club','DJ','Party'],
 true, true, false, '10:00 PM – 5:00 AM', false),

('La Noche Bar',
 'Bars & Nightlife', 'Zona Romántica',
 'Lázaro Cárdenas 257, Zona Romántica, Puerto Vallarta',
 20.5982, -105.2375,
 'Beloved LGBT+ bar in the heart of Zona Romántica. Weekly drag shows, theme nights, and the friendliest staff in PV.',
 array['music.note'], 4.8, 443, 2,
 null, null, '@lanochepv',
 array['LGBT+','Drag Shows','Gay Bar','Fun'],
 false, true, true, '6:00 PM – 3:00 AM', true),

-- HOTELS
('Garza Blanca Preserve Resort & Spa',
 'Hotels', 'Hotel Zone',
 'Carr. Barra de Navidad Km 7.5, Puerto Vallarta',
 20.5610, -105.2570,
 'Ultra-luxury 5-star resort with private beach, multiple pools, gourmet restaurants, and world-class spa.',
 array['bed.double.fill'], 4.9, 1876, 4,
 '+52 322 176 0700', 'https://garzablanca.com', null,
 array['5-Star','Luxury','Spa','Private Beach','All-Inclusive Option'],
 true, true, true, '24 hours', false),

('Casa Kimberly',
 'Hotels', 'Centro',
 'Zaragoza 445, Centro, Puerto Vallarta',
 20.6048, -105.2360,
 'The legendary former home of Elizabeth Taylor & Richard Burton, converted into a stunning boutique luxury hotel.',
 array['bed.double.fill'], 4.8, 634, 4,
 '+52 322 222 1336', 'https://casakimberly.com', null,
 array['Boutique','Historic','Romantic','Views','Adults Only'],
 true, true, true, '24 hours', false),

('W Punta de Mita',
 'Hotels', 'Punta Mita',
 'Lote H-1, Corral del Risco, Punta de Mita, Nayarit',
 20.7715, -105.4970,
 'Ultra-cool luxury resort in Punta Mita. Celebrity hotspot with stunning beach, W Lounge, and insane pool scene.',
 array['bed.double.fill'], 4.7, 912, 4,
 null, null, null,
 array['5-Star','Beach','Pool','Celebrity','Surfing'],
 true, false, true, '24 hours', false),

-- ACTIVITIES
('Marietas Islands Snorkeling & Hidden Beach',
 'Activities', 'Punta Mita',
 'Departs from La Cruz Marina, Nayarit',
 20.7130, -105.5600,
 'Iconic tour to the Marieta Islands — a UNESCO protected area. Snorkel with sea turtles, manta rays, and visit the famous Hidden Beach.',
 array['figure.surfing'], 4.9, 2341, 2,
 '+52 322 297 1212', null, null,
 array['Snorkeling','Wildlife','UNESCO','Hidden Beach','Day Trip'],
 false, true, true, '8:00 AM – 5:00 PM', false),

('Canopy River Zip-line & ATV',
 'Activities', 'Centro',
 'Carr. a Boca de Tomatlán Km 3, Puerto Vallarta',
 20.5720, -105.2490,
 'Thrilling zip-line tour through the jungle canopy above the Cuale River. Combine with ATV adventure and a traditional Mexican lunch.',
 array['figure.surfing'], 4.7, 1564, 3,
 '+52 322 222 4330', null, null,
 array['Zip-line','ATV','Jungle','Adventure','Family'],
 true, true, true, '8:00 AM – 5:00 PM', false),

('Whale Watching PV',
 'Activities', 'Marina',
 'Departs from Marina Vallarta',
 20.6720, -105.2540,
 'Seasonal humpback whale watching tours Nov–Mar. Banderas Bay is one of the world''s best spots to see humpback whales up close.',
 array['figure.surfing'], 4.9, 876, 2,
 null, null, null,
 array['Whale Watching','Seasonal','Wildlife','Ocean','Photography'],
 false, true, false, 'Nov–Mar: 8:00 AM – 1:00 PM', false),

('Sayulita Surf School',
 'Activities', 'Sayulita',
 'Playa Sayulita, Sayulita, Nayarit',
 20.8690, -105.4460,
 'Learn to surf in one of Mexico''s most famous surf towns. Beginners to advanced lessons, board rentals, daily surf camps.',
 array['figure.surfing'], 4.8, 445, 2,
 null, null, '@sayulitasurf',
 array['Surfing','Lessons','Beginner','Sayulita','Beach'],
 false, true, true, '7:00 AM – 6:00 PM', false),

-- YACHT RENTALS
('Sunset Sailing Cruise PV',
 'Yacht Rentals', 'Marina',
 'Marina Vallarta, Dock B, Puerto Vallarta',
 20.6715, -105.2545,
 '4-hour sunset sailing cruise aboard a 42ft catamaran. Open bar, snorkeling stop, live music. The most romantic experience in Puerto Vallarta.',
 array['sailboat.fill'], 4.9, 1123, 3,
 '+52 322 225 4777', null, null,
 array['Sunset','Catamaran','Open Bar','Snorkeling','Romantic'],
 true, true, true, '3:00 PM – 7:00 PM', true),

('Private Yacht Charter — Marietas',
 'Yacht Rentals', 'Marina',
 'Marina Vallarta, Puerto Vallarta',
 20.6718, -105.2548,
 'Full-day private yacht charter to the Marieta Islands. Up to 12 guests. Captain, crew, gourmet catering, snorkel gear, paddleboards.',
 array['sailboat.fill'], 4.8, 312, 4,
 '+52 322 225 5000', null, null,
 array['Private','Charter','Full Day','Luxury','Snorkeling'],
 true, false, true, '8:00 AM – 6:00 PM', false),

-- CAR & MOTO RENTAL
('Vallarta Car Rental',
 'Car & Moto Rental', 'Centro',
 'Blvd. Francisco Medina Ascencio 1728, Puerto Vallarta',
 20.6320, -105.2430,
 'Best rates on car rentals in Puerto Vallarta. Large fleet: economy cars, SUVs, convertibles. Airport pickup available.',
 array['car.fill'], 4.5, 678, 2,
 '+52 322 222 0999', null, null,
 array['Car Rental','Airport','SUV','Economy','Convertible'],
 true, false, true, '8:00 AM – 8:00 PM', false),

('Moto Rent PV',
 'Car & Moto Rental', 'Zona Romántica',
 'Olas Altas 390, Zona Romántica, Puerto Vallarta',
 20.5988, -105.2371,
 'Scooters, motorbikes, and ATVs for rent by the hour or day. Explore PV on two wheels. Helmets and insurance included.',
 array['car.fill'], 4.6, 289, 1,
 '+52 322 222 1234', null, '@motorentpv',
 array['Moto','Scooter','ATV','Hourly','Daily'],
 false, false, true, '9:00 AM – 7:00 PM', false),

-- BEACHES
('Playa Los Muertos',
 'Beaches', 'Zona Romántica',
 'Playa Los Muertos, Zona Romántica, Puerto Vallarta',
 20.5970, -105.2400,
 'Puerto Vallarta''s most famous beach. Gay-friendly south end (Blue Chairs), beach restaurants, volleyball, parasailing, and legendary sunsets.',
 array['sun.max.fill'], 4.8, 4521, 0,
 null, null, null,
 array['Gay Friendly','Beach Bars','Sunset','Volleyball','Central'],
 false, true, true, 'Always open', true),

('Playa Sayulita',
 'Beaches', 'Sayulita',
 'Sayulita, Nayarit',
 20.8685, -105.4458,
 'Charming bohemian surf beach in Sayulita. Mexican fishermen, surfers, and hippie travelers all coexist. Colorful town, great tacos nearby.',
 array['sun.max.fill'], 4.7, 2134, 0,
 null, null, null,
 array['Surf','Bohemian','Town','Colorful','Fishing'],
 false, true, true, 'Always open', false),

-- SHOPPING
('Mercado de Artesanías',
 'Shopping', 'Centro',
 'Agustín Rodríguez 164, Centro, Puerto Vallarta',
 20.6042, -105.2348,
 'Puerto Vallarta''s famous artisan market. Huichol beadwork, Talavera ceramics, handwoven textiles, leather goods, and silver jewelry.',
 array['bag.fill'], 4.5, 1872, 1,
 null, null, null,
 array['Artisan','Souvenirs','Huichol','Handmade','Market'],
 false, true, true, '9:00 AM – 8:00 PM', false),

-- SPAS & WELLNESS
('Garza Blanca Spa',
 'Spas & Wellness', 'Hotel Zone',
 'Carr. Barra de Navidad Km 7.5, Puerto Vallarta',
 20.5612, -105.2572,
 'World-class spa at Garza Blanca Resort. Signature treatments inspired by Mexican healing traditions. Ocean views, hydrotherapy, couples suites.',
 array['leaf.fill'], 4.9, 456, 4,
 '+52 322 176 0700', null, null,
 array['Luxury Spa','Couples','Hydrotherapy','Ocean Views','Massage'],
 true, true, true, '9:00 AM – 9:00 PM', false);


-- ── 4. EVENTS ────────────────────────────────────────────────
insert into events (
  title, description, neighborhood, address, latitude, longitude,
  start_date, end_date, is_public, is_free, ticket_price, ticket_url,
  photos, tags, organizer, instagram,
  is_premium, is_featured, is_lgbt_friendly, is_recurring, recurrence_label
) values

('Vallarta Pride 2026',
 'Puerto Vallarta''s world-famous Pride festival. Week-long celebration with parades, concerts, beach parties, and the iconic parade along the Malecón.',
 'Zona Romántica', 'Zona Romántica & Malecón, Puerto Vallarta',
 20.5985, -105.2380,
 now() + interval '14 days', now() + interval '21 days',
 true, true, null, null,
 array['calendar'], array['Pride','LGBT+','Parade','Festival','Annual'],
 'Vallarta Pride Organization', '@vallartapride',
 false, true, true, true, 'Annual'),

('Moonlight Jazz at the Marina',
 'Exclusive monthly jazz evening at Marina Vallarta''s premier yacht club. Live jazz quartet, gourmet tapas, craft cocktails under the stars.',
 'Marina', 'Yacht Club Marina Vallarta, Puerto Vallarta',
 20.6715, -105.2545,
 now() + interval '3 days', now() + interval '3 days' + interval '4 hours',
 false, false, 850, null,
 array['calendar'], array['Jazz','Live Music','Cocktails','Exclusive','Marina'],
 'Marina Yacht Club', null,
 true, true, false, true, 'Monthly'),

('Sayulita Surf Competition',
 'Annual amateur and pro surf competition at Playa Sayulita. Free entry for spectators, food and craft vendors.',
 'Sayulita', 'Playa Sayulita, Nayarit',
 20.8685, -105.4458,
 now() + interval '7 days', now() + interval '9 days',
 true, true, null, null,
 array['calendar'], array['Surf','Competition','Sayulita','Sport','Annual'],
 'Sayulita Surf Club', null,
 false, true, false, true, 'Annual'),

('Gourmet Food & Wine Festival',
 'Puerto Vallarta''s renowned Gourmet Festival. 10 days of special menus, wine pairings, and culinary events at 50+ top restaurants.',
 'Centro', 'Multiple venues, Puerto Vallarta',
 20.6060, -105.2370,
 now() + interval '30 days', now() + interval '40 days',
 true, false, 500, null,
 array['calendar'], array['Gourmet','Wine','Restaurants','Festival','Annual'],
 'Festival Gourmet Internacional', null,
 false, true, false, true, 'Annual - November'),

('Thursday Night Art Walk',
 'Every Thursday the Centro galleries open late. Meet local and international artists, enjoy wine, discover PV''s thriving art scene.',
 'Centro', 'Zona Centro — start at Galería Dante, Puerto Vallarta',
 20.6050, -105.2355,
 now() + interval '4 days', now() + interval '4 days' + interval '4 hours',
 true, true, null, null,
 array['calendar'], array['Art','Galleries','Culture','Wine','Weekly'],
 'PV Art Galleries Association', null,
 false, true, false, true, 'Every Thursday'),

('Sunset Beach Party — Blue Chairs',
 'The legendary daily sunset party at Blue Chairs Resort on Los Muertos Beach. DJs, dancers, signature cocktails, best sunset view in town.',
 'Zona Romántica', 'Blue Chairs Resort, Playa Los Muertos, Puerto Vallarta',
 20.5968, -105.2398,
 now() + interval '1 day', now() + interval '1 day' + interval '4 hours',
 true, true, null, null,
 array['calendar'], array['Sunset','DJ','Beach','LGBT+','Daily'],
 'Blue Chairs Resort', null,
 false, true, true, true, 'Daily');


-- ── 5. ROW LEVEL SECURITY ────────────────────────────────────
alter table listings        enable row level security;
alter table events          enable row level security;
alter table reviews         enable row level security;
alter table profiles        enable row level security;
alter table business_owners enable row level security;

drop policy if exists "Public read listings"          on listings;
drop policy if exists "Public read events"            on events;
drop policy if exists "Public read reviews"           on reviews;
drop policy if exists "Auth users insert reviews"     on reviews;
drop policy if exists "Users manage own profile"      on profiles;
drop policy if exists "Users read own business_owner" on business_owners;

create policy "Public read listings"
  on listings for select using (true);
create policy "Public read events"
  on events for select using (true);
create policy "Public read reviews"
  on reviews for select using (true);
create policy "Auth users insert reviews"
  on reviews for insert with check (auth.uid() = user_id);
create policy "Users manage own profile"
  on profiles for all using (auth.uid() = id);
create policy "Users read own business_owner"
  on business_owners for select using (auth.uid() = user_id);

-- ── VERIFY ───────────────────────────────────────────────────
-- select count(*) from listings;  -- expect 22
-- select count(*) from events;    -- expect 6
-- select name, category, neighborhood from listings order by category, name;

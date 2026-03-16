-- ============================================================
-- VallartApp — Real Restaurant Seed Data
-- Run this in: supabase.com → your project → SQL Editor
-- ============================================================
-- price_range: 0=Free 1=Budget($) 2=Moderate($$) 3=Upscale($$$) 4=Luxury($$$$)
-- photos: array of SF Symbol names (used as icons until real photos are uploaded)
-- ============================================================

INSERT INTO listings (
  id, name, category, neighborhood,
  address, latitude, longitude,
  description, photos,
  rating, review_count, price_range,
  phone, website, instagram,
  tags,
  is_premium, is_featured, is_open, open_hours, is_lgbt_friendly
) VALUES

-- 1. Café des Artistes
(
  gen_random_uuid(),
  'Café des Artistes',
  'Restaurants',
  'Centro',
  'Guadalupe Sánchez 740, Centro, Puerto Vallarta',
  20.6055,
  -105.2368,
  'Puerto Vallarta''s most celebrated fine-dining restaurant, open for 35+ years. Chef Thierry Blouet transforms ingredients into culinary art inside a stunning colonial mansion. Multiple international awards including Food & Travel Top 50. Smart casual dress code, children 8+ only.',
  ARRAY['fork.knife'],
  4.8,
  7377,
  4,
  '+52 322 226 7200',
  'https://cafedesartistes.com',
  '@cafedeartistes',
  ARRAY['Fine Dining','French-Mexican Fusion','Romantic','Award-Winning','Wine List','Art Gallery'],
  true, true, true,
  'Mon–Sun 4:00 PM – 12:00 AM',
  false
),

-- 2. Tuna Azul
(
  gen_random_uuid(),
  'Tuna Azul',
  'Restaurants',
  'Zona Romántica',
  'Rodolfo Gómez 109, Col. E. Zapata, Puerto Vallarta',
  20.5983,
  -105.2371,
  '#1 on TripAdvisor Puerto Vallarta with 4.9 stars and nearly 3,000 reviews. Family-run gem serving fresh tuna aguachile, marlin al pastor, and octopus chicharrón. Tiny space, huge flavor — arrive early or expect a wait.',
  ARRAY['fork.knife'],
  4.9,
  2865,
  2,
  '+52 322 222 0795',
  NULL,
  '@tunaazulpv',
  ARRAY['Seafood','Fresh Tuna','Local Favorite','Authentic Mexican','Casual','BYOB'],
  false, true, true,
  'Tue–Sun 11:00 AM – 6:00 PM',
  true
),

-- 3. Mar Y Vino
(
  gen_random_uuid(),
  'Mar Y Vino',
  'Restaurants',
  'Hotel Zone',
  'Paseo de la Marina Sur 220, Marina Vallarta, Puerto Vallarta',
  20.6658,
  -105.2598,
  'Stunning clifftop restaurant with sweeping panoramic views of Puerto Vallarta, Banderas Bay and the Sierra Madre. Contemporary Mexican cuisine with an outstanding wine list. Ideal for sunsets. Consistently ranked top 3 in PV.',
  ARRAY['fork.knife'],
  4.8,
  2172,
  3,
  '+52 322 221 0722',
  'https://maryvino.com',
  '@maryvino_pv',
  ARRAY['Panoramic Views','Sunset','Mexican','Wine','Romantic','Seafood'],
  true, true, true,
  'Mon–Sun 1:00 PM – 11:00 PM',
  false
),

-- 4. La Palapa Restaurant
(
  gen_random_uuid(),
  'La Palapa',
  'Restaurants',
  'Zona Romántica',
  'Pulpito 103, Playa Los Muertos, Puerto Vallarta',
  20.5971,
  -105.2397,
  'Iconic beachfront restaurant on Los Muertos Beach since 1959. Sink your feet in the sand while enjoying fresh Pacific seafood, tropical cocktails, and legendary breakfasts. One of PV''s most beloved institutions with over 7,000 TripAdvisor reviews.',
  ARRAY['fork.knife'],
  4.5,
  7272,
  2,
  '+52 322 222 5225',
  'https://lapalapapv.com',
  '@lapalapapv',
  ARRAY['Beachfront','Seafood','Breakfast','Brunch','Iconic','Tropical'],
  true, true, true,
  'Daily 8:00 AM – 11:00 PM',
  true
),

-- 5. Barcelona Tapas
(
  gen_random_uuid(),
  'Barcelona Tapas',
  'Restaurants',
  'Centro',
  'Morelos 531, Centro, Puerto Vallarta',
  20.6060,
  -105.2345,
  'Puerto Vallarta''s beloved Spanish tapas bar with over 3,300 TripAdvisor reviews. Authentic patatas bravas, jamón ibérico, seafood croquetas, paella, and an incredible sangria. Lively atmosphere on the Malecon, open late.',
  ARRAY['fork.knife'],
  4.7,
  3302,
  2,
  '+52 322 222 0510',
  'https://barcelonatapas.net',
  '@barcelonatapas_pv',
  ARRAY['Spanish','Tapas','Sangria','Paella','Malecon','Late Night'],
  false, true, true,
  'Mon–Sun 12:00 PM – 1:00 AM',
  false
);

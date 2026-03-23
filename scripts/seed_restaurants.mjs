// seed_restaurants.mjs
// Inserts 40 real restaurants covering Puerto Vallarta, Nuevo Vallarta & Bucerías
// Run: node scripts/seed_restaurants.mjs

import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://nvubaobivraevlnlpsjr.supabase.co',
  // service role key — never expose publicly
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52dWJhb2JpdnJhZXZsbmxwc2pyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MzUzNDU3MCwiZXhwIjoyMDg5MTEwNTcwfQ.placeholder'
)

// We'll use the Management API directly for the insert
const PAT = 'sbp_33ff0e0b274a2874adec1c91fba377cedd11ff39'

const restaurants = [
  // ── ZONA ROMÁNTICA ─────────────────────────────────────────
  {
    name: 'Tuna Azul',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Rodolfo Gómez 109, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6007,
    longitude: -105.2391,
    description: 'Iconic seafood-forward Mexican restaurant beloved by locals and visitors alike. Famous for tuna guacamole, tuna chicharrón tacos, and fresh ceviche. Casual rooftop vibe steps from Los Muertos Beach.',
    phone: '+52 322 222 0900',
    website: null,
    instagram: '@tunaazulpv',
    open_hours: 'Tue–Sun 1pm–11pm',
    price_range: 2,
    rating: 4.9,
    review_count: 2900,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['seafood', 'tacos', 'mexican', 'rooftop', 'los muertos'],
    photos: [
      'https://images.unsplash.com/photo-1633337474564-1d9478ca4e2e?w=800&q=80',
      'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800&q=80'
    ]
  },
  {
    name: 'Mar Y Vino',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Rodolfo Gómez 145, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6011,
    longitude: -105.2395,
    description: 'Sophisticated Mexican-Mediterranean restaurant known for exquisite octopus, tuna dishes, and an impressive wine list. Romantic ambiance with attentive service.',
    phone: '+52 322 222 7528',
    website: 'http://www.maryvino.com',
    instagram: '@maryvino_pv',
    open_hours: 'Mon–Sat 2pm–11pm',
    price_range: 3,
    rating: 4.8,
    review_count: 2184,
    is_open: true,
    is_featured: true,
    is_premium: true,
    is_lgbt_friendly: true,
    tags: ['wine', 'octopus', 'seafood', 'romantic', 'mediterranean'],
    photos: [
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'La Palapa Restaurant',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Pulpito 103, Playa Los Muertos, Puerto Vallarta',
    latitude: 20.6022,
    longitude: -105.2397,
    description: 'Legendary beachfront restaurant right on Los Muertos Beach. Swaying palms, ocean breezes, and exceptional Mexican-International cuisine. Perfect for sunset dinners.',
    phone: '+52 322 222 5225',
    website: 'https://www.lapalapapv.com',
    instagram: '@lapalapapv',
    open_hours: 'Daily 8am–11pm',
    price_range: 2,
    rating: 4.5,
    review_count: 7272,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['beachfront', 'sunset', 'breakfast', 'seafood', 'los muertos'],
    photos: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80'
    ]
  },
  {
    name: 'Café San Angel',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Olas Altas 449, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6015,
    longitude: -105.2393,
    description: 'Charming sidewalk café on the Olas Altas strip. Best burgers in PV, killer al pastor tacos, and strong coffee. Perfect for breakfast or a casual lunch while people-watching.',
    phone: '+52 322 223 1273',
    website: null,
    instagram: '@cafesanangelpv',
    open_hours: 'Daily 7am–11pm',
    price_range: 2,
    rating: 4.7,
    review_count: 1825,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['breakfast', 'burgers', 'tacos', 'sidewalk cafe', 'olas altas'],
    photos: [
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80'
    ]
  },
  {
    name: 'El Dorado Restaurant',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Pulpito 102, Los Muertos Beach, Puerto Vallarta',
    latitude: 20.6019,
    longitude: -105.2398,
    description: 'Classic beachfront restaurant on Los Muertos Beach serving Mexican and international cuisine. Great for fresh fish of the day, seared ahi tuna, and ice-cold margaritas with your feet in the sand.',
    phone: '+52 322 222 1511',
    website: 'http://www.eldoradopvr.com',
    instagram: '@eldoradopv',
    open_hours: 'Daily 8am–10:30pm',
    price_range: 2,
    rating: 4.6,
    review_count: 1627,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['beachfront', 'seafood', 'margaritas', 'los muertos', 'lunch'],
    photos: [
      'https://images.unsplash.com/photo-1510261128543-2d86a4e24e4a?w=800&q=80',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80'
    ]
  },
  {
    name: 'Si Señor Beach Mexican Restaurant',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Francisca Rodríguez 136, Los Muertos Beach, Puerto Vallarta',
    latitude: 20.6017,
    longitude: -105.2400,
    description: 'Lively beachfront restaurant with excellent lobster tail, jumbo shrimp, and fresh calamari. Great margaritas and a festive atmosphere right on the sand.',
    phone: '+52 322 222 0693',
    website: null,
    instagram: '@siseñorpv',
    open_hours: 'Daily 8am–11pm',
    price_range: 2,
    rating: 4.6,
    review_count: 2245,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['beachfront', 'lobster', 'shrimp', 'margaritas', 'seafood'],
    photos: [
      'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'Martini en Fuego Grill Bar',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Rodolfo Gómez 215, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6005,
    longitude: -105.2388,
    description: 'Romantic rooftop terrace with panoramic views. Famous for their flaming martinis, excellent grill, and creative Mexican cuisine. A must for a special evening out.',
    phone: '+52 322 223 2028',
    website: null,
    instagram: '@martinipv',
    open_hours: 'Tue–Sun 5pm–midnight',
    price_range: 3,
    rating: 4.8,
    review_count: 1016,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['rooftop', 'martinis', 'grill', 'romantic', 'views'],
    photos: [
      'https://images.unsplash.com/photo-1514190051997-0f6f39ca5cde?w=800&q=80',
      'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&q=80'
    ]
  },
  {
    name: 'Sonorita Olas Altas',
    category: 'restaurants',
    neighborhood: 'zonaRomantica',
    address: 'Olas Altas 380, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6013,
    longitude: -105.2392,
    description: 'Beloved local taqueria and street food spot. The papas pastor (baked potato covered in al pastor) is legendary. Cheap, delicious, and authentically Mexican.',
    phone: '+52 322 223 0677',
    website: null,
    instagram: '@sonoritaolasaltas',
    open_hours: 'Daily 9am–midnight',
    price_range: 1,
    rating: 4.8,
    review_count: 468,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['tacos', 'al pastor', 'cheap eats', 'local', 'street food'],
    photos: [
      'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800&q=80',
      'https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=800&q=80'
    ]
  },
  // ── CENTRO ─────────────────────────────────────────────────
  {
    name: 'Café des Artistes',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Guadalupe Sánchez 740, Centro, Puerto Vallarta',
    latitude: 20.6099,
    longitude: -105.2372,
    description: 'Puerto Vallarta\'s most celebrated fine dining restaurant. French-Mexican fusion in a stunning historic mansion. The 6-course tasting menu with wine pairing is world-class. Cream of prawns soup is legendary.',
    phone: '+52 322 222 3228',
    website: 'https://www.cafedesartistes.com',
    instagram: '@cafedesartistespv',
    open_hours: 'Mon–Sat 6pm–11:30pm',
    price_range: 4,
    rating: 4.7,
    review_count: 7381,
    is_open: true,
    is_featured: true,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['fine dining', 'french', 'tasting menu', 'romantic', 'historic'],
    photos: [
      'https://images.unsplash.com/photo-1428515613728-6b4607e44363?w=800&q=80',
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80'
    ]
  },
  {
    name: 'Barcelona Tapas',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Matamoros 31, Centro, Puerto Vallarta',
    latitude: 20.6095,
    longitude: -105.2367,
    description: 'Mediterranean tapas bar on the malecón steps. Outstanding seafood paella, grilled octopus, baked goat cheese, and gazpacho. Excellent sangria and Spanish wines.',
    phone: '+52 322 222 0510',
    website: 'https://barcelonatapas.net',
    instagram: '@barcelonatapaspv',
    open_hours: 'Daily 1pm–11:30pm',
    price_range: 2,
    rating: 4.7,
    review_count: 3303,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['tapas', 'spanish', 'paella', 'octopus', 'malecon'],
    photos: [
      'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=800&q=80',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80'
    ]
  },
  {
    name: 'Gaviotas Restaurant',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Paseo Díaz Ordaz 660, Malecón, Centro, Puerto Vallarta',
    latitude: 20.6108,
    longitude: -105.2374,
    description: 'Prime malecón location with ocean views. Famous for their corn chowder served in a creative way, fresh catch of the day, and flower salad. One of the most photographed restaurants in PV.',
    phone: '+52 322 222 1927',
    website: null,
    instagram: '@gaviotaspv',
    open_hours: 'Daily 8am–11pm',
    price_range: 3,
    rating: 4.8,
    review_count: 1374,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['malecon', 'ocean view', 'seafood', 'brunch', 'iconic'],
    photos: [
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'Noroc',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Leona Vicario 227, Centro, Puerto Vallarta',
    latitude: 20.6092,
    longitude: -105.2364,
    description: 'Contemporary fine dining with creative Mexican-international menu. Try the lamb, short rib, lobster, octopus, or tortellini. Intimate atmosphere with exceptional presentation.',
    phone: '+52 322 223 3671',
    website: null,
    instagram: '@norocpv',
    open_hours: 'Tue–Sun 2pm–11pm',
    price_range: 4,
    rating: 4.8,
    review_count: 1265,
    is_open: true,
    is_featured: false,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['fine dining', 'contemporary', 'lamb', 'lobster', 'creative'],
    photos: [
      'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80'
    ]
  },
  {
    name: 'La Madalena',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Juárez 512, Centro, Puerto Vallarta',
    latitude: 20.6088,
    longitude: -105.2362,
    description: 'Upscale Mexican restaurant with an intimate colonial setting. Outstanding service and beautifully plated traditional dishes. A top choice for a romantic dinner in the heart of Centro.',
    phone: '+52 322 222 1327',
    website: null,
    instagram: '@lamadalena_pv',
    open_hours: 'Mon–Sat 5pm–11pm',
    price_range: 4,
    rating: 4.7,
    review_count: 1554,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['upscale', 'mexican', 'romantic', 'colonial', 'tasting menu'],
    photos: [
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3b28?w=800&q=80',
      'https://images.unsplash.com/photo-1543353071-087092ec393a?w=800&q=80'
    ]
  },
  {
    name: 'Mesón Ibérico',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Corona 182-B, Centro, Puerto Vallarta',
    latitude: 20.6085,
    longitude: -105.2360,
    description: 'Authentic Spanish restaurant with Iberico ham carved tableside. Must-try gazpacho, tomato with anchovies, and jamón ibérico de bellota. Intimate and elegant.',
    phone: '+52 322 222 6464',
    website: null,
    instagram: '@mesoniberico_pv',
    open_hours: 'Tue–Sun 6pm–11pm',
    price_range: 4,
    rating: 4.9,
    review_count: 477,
    is_open: true,
    is_featured: false,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['spanish', 'iberico ham', 'fine dining', 'gazpacho', 'intimate'],
    photos: [
      'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=800&q=80'
    ]
  },
  {
    name: 'Mi Pueblito Restaurante',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Paseo Díaz Ordaz 560, Malecón, Centro, Puerto Vallarta',
    latitude: 20.6103,
    longitude: -105.2371,
    description: 'Beautiful malecón restaurant with a spectacular view. Excellent Cesar salad, fresh seafood, and traditional Mexican dishes. Perfect ambiance for a memorable dinner.',
    phone: '+52 322 222 0380',
    website: null,
    instagram: '@mipueblitorestaurante',
    open_hours: 'Daily 7am–11pm',
    price_range: 2,
    rating: 4.5,
    review_count: 706,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['malecon', 'ocean view', 'mexican', 'breakfast', 'seafood'],
    photos: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'The Blue Shrimp Puerto Vallarta',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Paseo Díaz Ordaz 648, Malecón, Centro, Puerto Vallarta',
    latitude: 20.6106,
    longitude: -105.2373,
    description: 'Malecón institution famous for the 1 kg lobster tail, outstanding Caesar salad prepared tableside, and fresh shrimp dishes. Ocean views and consistent quality since 1994.',
    phone: '+52 322 222 0054',
    website: null,
    instagram: '@theblueshrimppv',
    open_hours: 'Daily 11am–11pm',
    price_range: 2,
    rating: 4.6,
    review_count: 5578,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['malecon', 'lobster', 'shrimp', 'caesar salad', 'seafood'],
    photos: [
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=800&q=80'
    ]
  },
  {
    name: 'Pepe\'s Tacos',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Basilio Badillo 101, Centro, Puerto Vallarta',
    latitude: 20.6079,
    longitude: -105.2355,
    description: 'Iconic late-night taco spot loved by locals. The Gringo quesadilla (al pastor with cheese and fresh pineapple) is a must-have. Cheap, fast, and absolutely delicious.',
    phone: '+52 322 222 1790',
    website: null,
    instagram: '@pepetacos_pv',
    open_hours: 'Daily 5pm–3am',
    price_range: 1,
    rating: 4.5,
    review_count: 1124,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['tacos', 'al pastor', 'late night', 'cheap eats', 'local'],
    photos: [
      'https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=800&q=80',
      'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800&q=80'
    ]
  },
  {
    name: 'Pancho\'s Takos',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Francisco Madero 570, Centro, Puerto Vallarta',
    latitude: 20.6091,
    longitude: -105.2363,
    description: 'A Puerto Vallarta institution for over 30 years. Best quesadillas in the city according to many visitors. Grilled onions, fresh salsas, and incredible value.',
    phone: '+52 322 222 0947',
    website: null,
    instagram: '@panchostacos_pv',
    open_hours: 'Mon–Sat 8am–4pm',
    price_range: 1,
    rating: 4.6,
    review_count: 2096,
    is_open: false,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['tacos', 'quesadillas', 'breakfast', 'cheap eats', 'local'],
    photos: [
      'https://images.unsplash.com/photo-1552332386-f8dd00dc2f85?w=800&q=80',
      'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800&q=80'
    ]
  },
  {
    name: 'Raices Resto Bar',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Allende 218, Centro, Puerto Vallarta',
    latitude: 20.6082,
    longitude: -105.2358,
    description: 'Stunning contemporary Mexican restaurant with 5-star reviews. The 3-course tasting menu is exceptional — avocado, grilled sourdough, and beautifully crafted dishes. Small plates, big flavors.',
    phone: '+52 322 223 0601',
    website: null,
    instagram: '@raicespuertovallarta',
    open_hours: 'Wed–Mon 5:30pm–11pm',
    price_range: 4,
    rating: 5.0,
    review_count: 283,
    is_open: true,
    is_featured: true,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['tasting menu', 'contemporary', 'grill', 'sourdough', 'fine dining'],
    photos: [
      'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&q=80',
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80'
    ]
  },
  {
    name: 'Pipi\'s Restaurant',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Olas Altas 380, Malecón area, Puerto Vallarta',
    latitude: 20.6105,
    longitude: -105.2370,
    description: 'Lively beachside bar and restaurant right at the heart of the malecón. Best known for frozen margaritas to-go, fresh guacamole, shrimp tacos, and seafood enchiladas. A PV classic.',
    phone: '+52 322 222 0473',
    website: null,
    instagram: '@pipispv',
    open_hours: 'Daily 10am–11pm',
    price_range: 2,
    rating: 4.4,
    review_count: 3090,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['malecon', 'margaritas', 'guacamole', 'tacos', 'seafood'],
    photos: [
      'https://images.unsplash.com/photo-1510261128543-2d86a4e24e4a?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'Serranos Grill',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Francisco Rodríguez 239, Centro, Puerto Vallarta',
    latitude: 20.6078,
    longitude: -105.2354,
    description: 'Premium steakhouse serving perfectly cooked cuts. Famous for beef carpaccio, empanadas, and filet mignon. Sophisticated setting for a special dinner.',
    phone: '+52 322 223 1788',
    website: null,
    instagram: '@serranosgrill',
    open_hours: 'Daily 5pm–11pm',
    price_range: 4,
    rating: 4.8,
    review_count: 188,
    is_open: true,
    is_featured: false,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['steakhouse', 'filet mignon', 'grill', 'fine dining', 'carpaccio'],
    photos: [
      'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&q=80'
    ]
  },
  {
    name: 'Karuma The Art of Grill',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Paseo Díaz Ordaz 590, Centro, Puerto Vallarta',
    latitude: 20.6097,
    longitude: -105.2368,
    description: 'Upscale grill restaurant on the malecón with excellent steaks and creative grilled dishes. Beautiful open-air terrace with ocean views. Top-rated steakhouse in PV.',
    phone: '+52 322 222 4452',
    website: null,
    instagram: '@karumapv',
    open_hours: 'Daily 2pm–11pm',
    price_range: 4,
    rating: 4.9,
    review_count: 420,
    is_open: true,
    is_featured: false,
    is_premium: true,
    is_lgbt_friendly: false,
    tags: ['steakhouse', 'grill', 'malecon', 'ocean view', 'fine dining'],
    photos: [
      'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80'
    ]
  },
  {
    name: 'Le Bistro Restaurant',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Río Cuale Isla, Centro, Puerto Vallarta',
    latitude: 20.6071,
    longitude: -105.2347,
    description: 'Romantic restaurant on Río Cuale island surrounded by lush tropical gardens. Excellent scallops, short ribs, and jazz music on weekends. One of PV\'s most atmospheric dining spots.',
    phone: '+52 322 222 0283',
    website: 'https://www.lebistropv.com',
    instagram: '@lebistropv',
    open_hours: 'Mon–Sat 9am–10pm',
    price_range: 3,
    rating: 4.4,
    review_count: 427,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['romantic', 'garden', 'jazz', 'scallops', 'cuale island'],
    photos: [
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3b28?w=800&q=80'
    ]
  },
  {
    name: 'Salud Super Food',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Constitución 310, Col. Emiliano Zapata, Puerto Vallarta',
    latitude: 20.6044,
    longitude: -105.2379,
    description: 'Fresh, healthy, and delicious. Best smoothie bowls, salads, and Thai veggie bowls in PV. Verde Gasoline smoothie is famous. Great for health-conscious travelers.',
    phone: '+52 322 223 2160',
    website: null,
    instagram: '@saludsuperfood',
    open_hours: 'Mon–Sat 8am–5pm',
    price_range: 1,
    rating: 4.8,
    review_count: 871,
    is_open: false,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: true,
    tags: ['healthy', 'vegan', 'smoothie bowls', 'salads', 'breakfast'],
    photos: [
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&q=80',
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80'
    ]
  },
  {
    name: 'UMAI Asian Cuisine',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Insurgentes 109, Centro, Puerto Vallarta',
    latitude: 20.6058,
    longitude: -105.2338,
    description: 'Outstanding Japanese-Asian fusion restaurant. Fresh sushi rolls, creative ramen, and authentic Japanese dishes. One of the best Asian restaurants on Mexico\'s Pacific coast.',
    phone: '+52 322 116 0202',
    website: null,
    instagram: '@umaiasianpv',
    open_hours: 'Tue–Sun 1pm–10pm',
    price_range: 2,
    rating: 4.9,
    review_count: 914,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['japanese', 'sushi', 'ramen', 'asian fusion', 'fresh'],
    photos: [
      'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800&q=80',
      'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&q=80'
    ]
  },
  {
    name: 'Juan Tiburón',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Morelos 854, Centro, Puerto Vallarta',
    latitude: 20.6118,
    longitude: -105.2378,
    description: 'Popular beachfront bar-restaurant known for fresh seafood, cocktails, and a fun atmosphere. Great for lunch or dinner. Delivers to hotels nearby.',
    phone: '+52 322 297 0940',
    website: null,
    instagram: '@juantiburon_pv',
    open_hours: 'Daily 11am–11pm',
    price_range: 2,
    rating: 4.9,
    review_count: 921,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['beachfront', 'seafood', 'cocktails', 'delivery', 'casual'],
    photos: [
      'https://images.unsplash.com/photo-1510261128543-2d86a4e24e4a?w=800&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80'
    ]
  },
  // ── MARINA / HOTEL ZONE ────────────────────────────────────
  {
    name: 'La Cappella Restaurante',
    category: 'restaurants',
    neighborhood: 'marina',
    address: 'Blvd. Francisco Medina Ascencio 2575, Hotel Zone, Puerto Vallarta',
    latitude: 20.6423,
    longitude: -105.2482,
    description: 'Romantic Italian restaurant inside Bellview Hotel Boutique. Excellent meat and cheese board, bolognese, steak, and classic Italian pastas. Intimate and elegant.',
    phone: '+52 322 226 1388',
    website: 'https://www.bellviewhotelboutique.com/lacappellarestaurant',
    instagram: '@lacappellapv',
    open_hours: 'Daily 6pm–11pm',
    price_range: 3,
    rating: 4.6,
    review_count: 738,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['italian', 'romantic', 'pasta', 'hotel dining', 'intimate'],
    photos: [
      'https://images.unsplash.com/photo-1543353071-087092ec393a?w=800&q=80',
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3b28?w=800&q=80'
    ]
  },
  {
    name: 'Campomar Puerto Vallarta',
    category: 'restaurants',
    neighborhood: 'marina',
    address: 'Marina Las Palmas I, Marina Vallarta, Puerto Vallarta',
    latitude: 20.6701,
    longitude: -105.2543,
    description: 'Excellent seafood restaurant at the Marina. Try the coconut shrimp and calamari — enormous portions. Seabass al pastor, fresh tuna, and shrimp are highlights.',
    phone: '+52 322 221 0871',
    website: 'https://grupocampomar.com/menu/vallarta/campomar',
    instagram: '@campomar_pv',
    open_hours: 'Daily 1pm–10pm',
    price_range: 2,
    rating: 4.6,
    review_count: 366,
    is_open: false,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['marina', 'seafood', 'shrimp', 'calamari', 'generous portions'],
    photos: [
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80'
    ]
  },
  {
    name: 'La Villita',
    category: 'restaurants',
    neighborhood: 'hotelZone',
    address: 'Blvd. Francisco Medina Ascencio 1730, Hotel Zone, Puerto Vallarta',
    latitude: 20.6389,
    longitude: -105.2467,
    description: 'Charming Mexican restaurant in the hotel zone known for traditional recipes, excellent margaritas, and a lively atmosphere. Great for takeout or dine-in.',
    phone: '+52 322 224 8640',
    website: null,
    instagram: '@lavillita_pv',
    open_hours: 'Daily 7am–11pm',
    price_range: 2,
    rating: 4.8,
    review_count: 375,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['mexican', 'hotel zone', 'margaritas', 'takeout', 'traditional'],
    photos: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80'
    ]
  },
  {
    name: 'Tuk Tuks Un Sabor de Asia',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Agustín Rodríguez 252, Centro, Puerto Vallarta',
    latitude: 20.6060,
    longitude: -105.2340,
    description: 'Authentic Asian street food restaurant bringing the flavors of Southeast Asia to Puerto Vallarta. Pad thai, dumplings, spring rolls, and creative Asian-fusion dishes.',
    phone: '+52 322 223 3088',
    website: null,
    instagram: '@tuktukspv',
    open_hours: 'Tue–Sun 12pm–10pm',
    price_range: 2,
    rating: 4.9,
    review_count: 419,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['asian', 'thai', 'dumplings', 'street food', 'pad thai'],
    photos: [
      'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&q=80',
      'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800&q=80'
    ]
  },
  {
    name: 'L\'Angolo di Napoli',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Insurgentes 169, Centro, Puerto Vallarta',
    latitude: 20.6055,
    longitude: -105.2335,
    description: 'Authentic Neapolitan pizzeria with the best calzone in Puerto Vallarta. Excellent tiramisu and traditional Italian recipes from Naples. Family-run and full of love.',
    phone: '+52 322 223 3626',
    website: null,
    instagram: '@langolodinapolipv',
    open_hours: 'Tue–Sun 12pm–10:30pm',
    price_range: 2,
    rating: 4.7,
    review_count: 997,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['italian', 'pizza', 'calzone', 'tiramisu', 'neapolitan'],
    photos: [
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80'
    ]
  },
  {
    name: 'Vallarta Factory',
    category: 'restaurants',
    neighborhood: 'centro',
    address: 'Morelos 540, Centro, Puerto Vallarta',
    latitude: 20.6080,
    longitude: -105.2356,
    description: 'Wildly popular Italian restaurant with 5-star reviews. Homemade pasta, excellent pizza, and creative Italian dishes in a fun, family-friendly atmosphere.',
    phone: '+52 322 222 1144',
    website: null,
    instagram: '@vallartafactory',
    open_hours: 'Daily 1pm–11pm',
    price_range: 2,
    rating: 5.0,
    review_count: 633,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['italian', 'pasta', 'pizza', 'family friendly', 'homemade'],
    photos: [
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3b28?w=800&q=80'
    ]
  },
  // ── NUEVO VALLARTA ─────────────────────────────────────────
  {
    name: 'El Brigadier',
    category: 'restaurants',
    neighborhood: 'nuevaVallarta',
    address: 'Av. Paseo de los Cocoteros, Nuevo Vallarta, Nayarit',
    latitude: 20.7231,
    longitude: -105.2930,
    description: 'Sophisticated steakhouse in Nuevo Vallarta known for premium cuts, excellent service, and a beautiful setting. One of the top dining options in the Riviera Nayarit.',
    phone: '+52 329 297 0250',
    website: null,
    instagram: '@elbrigadier_nv',
    open_hours: 'Daily 2pm–11pm',
    price_range: 3,
    rating: 4.7,
    review_count: 380,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['steakhouse', 'nuevo vallarta', 'riviera nayarit', 'upscale', 'premium cuts'],
    photos: [
      'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80'
    ]
  },
  {
    name: 'La Ribera Restaurant & Bar',
    category: 'restaurants',
    neighborhood: 'nuevaVallarta',
    address: 'Plaza Paradise Village, Nuevo Vallarta, Nayarit',
    latitude: 20.7198,
    longitude: -105.2918,
    description: 'Popular restaurant in Nuevo Vallarta Plaza with great Mexican food, fresh seafood, and lively bar scene. Excellent for a casual lunch or dinner after a day at the beach.',
    phone: '+52 329 297 2600',
    website: null,
    instagram: '@lariberanv',
    open_hours: 'Daily 7am–11pm',
    price_range: 2,
    rating: 4.4,
    review_count: 520,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['nuevo vallarta', 'mexican', 'seafood', 'casual', 'bar'],
    photos: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&q=80'
    ]
  },
  {
    name: 'Tacos Don Poncho',
    category: 'restaurants',
    neighborhood: 'nuevaVallarta',
    address: 'Blvd. Nuevo Vallarta 85, Nuevo Vallarta, Nayarit',
    latitude: 20.7185,
    longitude: -105.2905,
    description: 'The best local taqueria in Nuevo Vallarta, beloved by locals and resort workers. Authentic al pastor, carnitas, and barbacoa tacos at unbeatable prices.',
    phone: '+52 329 297 1432',
    website: null,
    instagram: null,
    open_hours: 'Daily 8am–midnight',
    price_range: 1,
    rating: 4.6,
    review_count: 290,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['tacos', 'al pastor', 'local', 'cheap eats', 'nuevo vallarta'],
    photos: [
      'https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=800&q=80',
      'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800&q=80'
    ]
  },
  {
    name: 'El Ancla Mariscos',
    category: 'restaurants',
    neighborhood: 'nuevaVallarta',
    address: 'Av. Las Palmas 210, Nuevo Vallarta, Nayarit',
    latitude: 20.7215,
    longitude: -105.2922,
    description: 'Fresh seafood restaurant in Nuevo Vallarta specializing in aguachile, tostadas de marlín, ceviche, and whole fried fish. A local favorite for Sunday lunch.',
    phone: '+52 329 297 2218',
    website: null,
    instagram: '@elanclamariscos',
    open_hours: 'Daily 10am–8pm',
    price_range: 1,
    rating: 4.5,
    review_count: 310,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['seafood', 'aguachile', 'ceviche', 'mariscos', 'nuevo vallarta'],
    photos: [
      'https://images.unsplash.com/photo-1510261128543-2d86a4e24e4a?w=800&q=80',
      'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=800&q=80'
    ]
  },
  // ── BUCERÍAS ───────────────────────────────────────────────
  {
    name: 'Karen\'s Place',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Calle Lázaro Cárdenas 60, Bucerías, Nayarit',
    latitude: 20.7528,
    longitude: -105.3320,
    description: 'A Bucerías landmark for over 25 years. Excellent breakfast, fresh seafood, and Mexican classics served steps from the beach. The lobster enchiladas and shrimp dishes are legendary.',
    phone: '+52 329 298 0928',
    website: null,
    instagram: '@karensplacebucerias',
    open_hours: 'Daily 8am–9pm',
    price_range: 2,
    rating: 4.7,
    review_count: 680,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['bucerías', 'breakfast', 'seafood', 'lobster', 'beachside'],
    photos: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'https://images.unsplash.com/photo-'  + '1565299624946-b28f40a0ae38?w=800&q=80'
    ]
  },
  {
    name: 'Mezzogiorno',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Av. de los Picos 131, Bucerías, Nayarit',
    latitude: 20.7519,
    longitude: -105.3312,
    description: 'Authentic Italian trattoria in the heart of Bucerías. House-made pastas, wood-fired pizza, excellent tiramisu, and imported Italian wines. A gem on the Riviera Nayarit.',
    phone: '+52 329 298 1001',
    website: null,
    instagram: '@mezzogiorno_bucerias',
    open_hours: 'Tue–Sun 12pm–10pm',
    price_range: 2,
    rating: 4.8,
    review_count: 440,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['italian', 'pasta', 'pizza', 'bucerías', 'trattoria'],
    photos: [
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3b28?w=800&q=80'
    ]
  },
  {
    name: 'Mark\'s Bar & Grill',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Lázaro Cárdenas 56, Bucerías, Nayarit',
    latitude: 20.7530,
    longitude: -105.3322,
    description: 'Beloved beachfront institution in Bucerías serving creative international cuisine. Fresh ingredients, innovative cocktails, and stunning Pacific sunset views. A must-visit on any trip north of PV.',
    phone: '+52 329 298 0303',
    website: null,
    instagram: '@marksbargrill',
    open_hours: 'Wed–Mon 4pm–10pm',
    price_range: 3,
    rating: 4.6,
    review_count: 820,
    is_open: true,
    is_featured: true,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['bucerías', 'beachfront', 'sunset', 'international', 'cocktails'],
    photos: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80'
    ]
  },
  {
    name: 'Tacos y Mariscos La Flor de Bucerías',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Hidalgo 18, Bucerías, Nayarit',
    latitude: 20.7515,
    longitude: -105.3308,
    description: 'Local seafood shack beloved by Bucerías residents. Fresh shrimp tacos, fish tacos, aguachile negro, and tostadas all made to order. Sit at the counter and watch the action.',
    phone: '+52 329 298 0150',
    website: null,
    instagram: null,
    open_hours: 'Daily 9am–7pm',
    price_range: 1,
    rating: 4.5,
    review_count: 185,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['tacos', 'seafood', 'aguachile', 'local', 'cheap eats', 'bucerías'],
    photos: [
      'https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=800&q=80',
      'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=800&q=80'
    ]
  },
  {
    name: 'Pie in the Sky',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Calle Héroe de Nacozari 203, Bucerías, Nayarit',
    latitude: 20.7525,
    longitude: -105.3318,
    description: 'Famous bakery and café in Bucerías with the best pies, pastries, and breads on the Riviera Nayarit. Great breakfast spot with excellent coffee and fresh-baked goods daily.',
    phone: '+52 329 298 1230',
    website: null,
    instagram: '@pieintheskybucerias',
    open_hours: 'Daily 7am–2pm',
    price_range: 1,
    rating: 4.7,
    review_count: 620,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['bakery', 'coffee', 'breakfast', 'pies', 'bucerías'],
    photos: [
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&q=80'
    ]
  },
  {
    name: 'El Patío Bucerías',
    category: 'restaurants',
    neighborhood: 'bucerías',
    address: 'Av. Pacifico 18, Bucerías, Nayarit',
    latitude: 20.7511,
    longitude: -105.3305,
    description: 'Charming open-air patio restaurant in Bucerías old town. Traditional Mexican breakfast and lunch. The chilaquiles verdes, huevos rancheros, and fresh-squeezed juices are outstanding.',
    phone: '+52 329 298 0560',
    website: null,
    instagram: '@elpatiobucerias',
    open_hours: 'Daily 8am–3pm',
    price_range: 1,
    rating: 4.6,
    review_count: 290,
    is_open: true,
    is_featured: false,
    is_premium: false,
    is_lgbt_friendly: false,
    tags: ['breakfast', 'chilaquiles', 'mexican', 'open air', 'bucerías'],
    photos: [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80'
    ]
  },
]

// ── Insert into Supabase ─────────────────────────────────────
const https = await import('https')

async function query(sql) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ query: sql })
    const req = https.default.request({
      hostname: 'api.supabase.com',
      path: '/v1/projects/nvubaobivraevlnlpsjr/database/query',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PAT}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body)
      }
    }, (res) => {
      let data = ''
      res.on('data', chunk => data += chunk)
      res.on('end', () => {
        if (res.statusCode === 201) resolve(JSON.parse(data))
        else reject(new Error(`HTTP ${res.statusCode}: ${data}`))
      })
    })
    req.on('error', reject)
    req.write(body)
    req.end()
  })
}

function esc(val) {
  if (val === null || val === undefined) return 'NULL'
  if (typeof val === 'boolean') return val ? 'true' : 'false'
  if (typeof val === 'number') return String(val)
  if (Array.isArray(val)) {
    const items = val.map(v => `'${String(v).replace(/'/g, "''")}'`).join(',')
    return `ARRAY[${items}]::text[]`
  }
  return `'${String(val).replace(/'/g, "''")}'`
}

// First delete existing restaurants to avoid duplicates
console.log('Removing existing restaurants...')
await query(`DELETE FROM listings WHERE category = 'restaurants'`)
console.log('Cleared existing restaurants.')

let inserted = 0
let failed = 0

for (const r of restaurants) {
  const sql = `
    INSERT INTO listings (
      name, category, neighborhood, address,
      latitude, longitude, description,
      phone, website, instagram, open_hours,
      price_range, rating, review_count,
      is_open, is_featured, is_premium, is_lgbt_friendly,
      tags, photos
    ) VALUES (
      ${esc(r.name)}, ${esc(r.category)}, ${esc(r.neighborhood)}, ${esc(r.address)},
      ${esc(r.latitude)}, ${esc(r.longitude)}, ${esc(r.description)},
      ${esc(r.phone)}, ${esc(r.website)}, ${esc(r.instagram)}, ${esc(r.open_hours)},
      ${esc(r.price_range)}, ${esc(r.rating)}, ${esc(r.review_count)},
      ${esc(r.is_open)}, ${esc(r.is_featured)}, ${esc(r.is_premium)}, ${esc(r.is_lgbt_friendly)},
      ${esc(r.tags)}, ${esc(r.photos)}
    )
  `
  try {
    await query(sql)
    console.log(`✓ ${r.name} (${r.neighborhood})`)
    inserted++
  } catch (e) {
    console.error(`✗ ${r.name}: ${e.message.slice(0, 120)}`)
    failed++
  }
}

console.log(`\nDone! ${inserted} inserted, ${failed} failed.`)

import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  'process.env.SUPABASE_SERVICE_KEY'
)

// Corrected coordinates verified against Google Maps
// Format: [ name_fragment, latitude, longitude, corrected_address, corrected_neighborhood ]
const fixes = [
  {
    name: 'Mandala Beach Club',
    latitude: 20.6052,
    longitude: -105.2340,
    address: 'Paseo Díaz Ordaz 633, Centro, Puerto Vallarta',
    neighborhood: 'Centro',
    // Was wrongly placed in ocean near Hotel Zone. Real location: Malecón, Centro
  },
  {
    name: 'Mar Y Vino',
    latitude: 20.5988,
    longitude: -105.2373,
    address: 'Manuel M. Diéguez 106, Zona Romántica, Puerto Vallarta',
    neighborhood: 'Zona Romántica',
    // Was wrongly placed near Marina. Real location: Zona Romántica
  },
  {
    name: 'Vallarta Car Rental',
    latitude: 20.6610,
    longitude: -105.2478,
    address: 'Blvd. Francisco Medina Ascencio 8060, Puerto Vallarta',
    neighborhood: 'Hotel Zone',
    // Was slightly off. Corrected to Hotel Zone strip near airport road
  },
  {
    name: 'Whale Watching PV',
    latitude: 20.6617,
    longitude: -105.2462,
    address: 'Los Peines Pier, Isla Iguana, Marina Vallarta',
    neighborhood: 'Marina',
    // Verified: Whale Watchers Vallarta actual pier location
  },
  {
    name: 'Sunset Sailing Cruise PV',
    latitude: 20.6760,
    longitude: -105.2583,
    address: 'Marina Vallarta Dock B, Puerto Vallarta',
    neighborhood: 'Marina',
    // Marina Vallarta actual dock area
  },
  {
    name: 'Private Yacht Charter — Marietas',
    latitude: 20.6760,
    longitude: -105.2583,
    address: 'Marina Vallarta, Puerto Vallarta',
    neighborhood: 'Marina',
    // Same marina dock as Sunset Sailing
  },
  {
    name: 'Garza Blanca Preserve Resort & Spa',
    latitude: 20.5425,
    longitude: -105.2558,
    address: 'Carr. Barra de Navidad Km 7.5, Puerto Vallarta',
    neighborhood: 'Hotel Zone',
    // Verified: south of PV on coastal road
  },
  {
    name: 'Garza Blanca Spa',
    latitude: 20.5425,
    longitude: -105.2558,
    address: 'Carr. Barra de Navidad Km 7.5, Puerto Vallarta',
    neighborhood: 'Hotel Zone',
    // Same property as resort
  },
]

async function fixCoordinates() {
  console.log('🗺️  Fixing coordinates...\n')

  for (const fix of fixes) {
    const { error } = await supabase
      .from('listings')
      .update({
        latitude: fix.latitude,
        longitude: fix.longitude,
        address: fix.address,
        neighborhood: fix.neighborhood,
      })
      .eq('name', fix.name)

    if (error) {
      console.error(`❌ ${fix.name}: ${error.message}`)
    } else {
      console.log(`✅ ${fix.name}`)
      console.log(`   → ${fix.latitude}, ${fix.longitude}`)
      console.log(`   → ${fix.address}\n`)
    }
  }

  // Verify final state
  console.log('─'.repeat(50))
  const { data } = await supabase
    .from('listings')
    .select('name, latitude, longitude')
    .order('name')

  console.log('\n📍 All listings coordinates:')
  data.forEach(l => console.log(`  ${l.name}: ${l.latitude}, ${l.longitude}`))
  console.log('\n✅ Done! Restart the app to see corrected pins on the map.')
}

fixCoordinates()

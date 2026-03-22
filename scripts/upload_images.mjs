import { createClient } from '@supabase/supabase-js'
import https from 'https'

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY)

// Verified working Wikimedia Commons URLs (tested with curl, all return 200)
const CATEGORY_PHOTOS = {
  'Restaurants':       'https://upload.wikimedia.org/wikipedia/commons/5/5c/Mexican_food.jpg',
  'Bars & Nightlife':  'https://upload.wikimedia.org/wikipedia/commons/8/86/Cocktails.jpg',
  'Hotels':            'https://upload.wikimedia.org/wikipedia/commons/8/8a/Swimming_pool.jpg',
  'Activities':        'https://upload.wikimedia.org/wikipedia/commons/6/6a/Humpback_whale_jumping.jpg',
  'Yacht Rentals':     'https://upload.wikimedia.org/wikipedia/commons/d/dc/Catamaran.jpg',
  'Car & Moto Rental': 'https://upload.wikimedia.org/wikipedia/commons/0/07/Motorcycle.jpg',
  'Beaches':           'https://upload.wikimedia.org/wikipedia/commons/f/f5/Puerto_Vallarta%2C_Jalisco.jpg',
  'Shopping':          'https://upload.wikimedia.org/wikipedia/commons/1/19/Mexican_market.jpg',
  'Spas & Wellness':   'https://upload.wikimedia.org/wikipedia/commons/4/44/Massage.jpg',
}

const SPECIFIC = {
  'Playa Sayulita':            'https://upload.wikimedia.org/wikipedia/commons/d/d0/Sayulita_Nayarit.jpg',
  'Playa Conchas Chinas':      'https://upload.wikimedia.org/wikipedia/commons/c/cd/Playa_Conchas_Chinas.jpg',
  'Playa Mismaloya':           'https://upload.wikimedia.org/wikipedia/commons/c/cd/Playa_Conchas_Chinas.jpg',
  'Sport Fishing Charter PV':  'https://upload.wikimedia.org/wikipedia/commons/f/ff/Fishing.jpg',
  'Horseback Riding Sierra Madre': 'https://upload.wikimedia.org/wikipedia/commons/9/97/Horseback_riding.jpg',
  'Butterfly Sanctuary & Museum': 'https://upload.wikimedia.org/wikipedia/commons/7/77/Butterfly.jpg',
}

function download(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' }, timeout: 30000 }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return download(res.headers.location).then(resolve).catch(reject)
      }
      if (res.statusCode !== 200) return reject(new Error('HTTP ' + res.statusCode))
      const chunks = []
      res.on('data', c => chunks.push(c))
      res.on('end', () => {
        const buf = Buffer.concat(chunks)
        if (buf.length < 5000) return reject(new Error('too small: ' + buf.length))
        resolve({ buffer: buf, type: res.headers['content-type'] || 'image/jpeg' })
      })
    })
    req.on('error', reject)
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')) })
  })
}

async function run() {
  const { data: listings, error } = await supabase.from('listings').select('id, name, category, photos')
  if (error) { console.error('DB error:', error.message); process.exit(1) }
  console.log('Processing ' + listings.length + ' listings...\n')
  let ok = 0, skip = 0, fail = 0

  for (const l of listings) {
    if (l.photos && l.photos.length > 0 && l.photos[0].includes('supabase')) {
      console.log('  SKIP: ' + l.name)
      skip++
      continue
    }
    const url = SPECIFIC[l.name] || CATEGORY_PHOTOS[l.category]
    if (!url) { console.log('  NO URL: ' + l.name); continue }
    try {
      const { buffer, type } = await download(url)
      const ext = type.includes('png') ? 'png' : 'jpg'
      const path = 'listings/' + l.id + '.' + ext
      const { error: upErr } = await supabase.storage.from('listings').upload(path, buffer, { contentType: type, upsert: true })
      if (upErr) throw upErr
      const { data: { publicUrl } } = supabase.storage.from('listings').getPublicUrl(path)
      await supabase.from('listings').update({ photos: [publicUrl] }).eq('id', l.id)
      console.log('  OK: ' + l.name)
      ok++
    } catch (e) {
      console.log('  FAIL: ' + l.name + ' — ' + e.message)
      fail++
    }
  }
  console.log('\nDone: ' + ok + ' uploaded, ' + skip + ' skipped, ' + fail + ' failed')
}

run().catch(console.error)

import { createClient } from '@supabase/supabase-js'
import https from 'https'

const sb = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY)

const EVENT_PHOTOS = {
  'Vallarta Pride 2026':           'https://upload.wikimedia.org/wikipedia/commons/4/43/Tequila.jpg',
  'Moonlight Jazz at the Marina':  'https://upload.wikimedia.org/wikipedia/commons/8/86/Cocktails.jpg',
  'Sayulita Surf Competition':     'https://upload.wikimedia.org/wikipedia/commons/d/d0/Sayulita_Nayarit.jpg',
  'Gourmet Food & Wine Festival':  'https://upload.wikimedia.org/wikipedia/commons/5/5c/Mexican_food.jpg',
  'Thursday Night Art Walk':       'https://upload.wikimedia.org/wikipedia/commons/1/19/Mexican_market.jpg',
  'Sunset Beach Party — Blue Chairs': 'https://upload.wikimedia.org/wikipedia/commons/f/f5/Puerto_Vallarta%2C_Jalisco.jpg',
}

function download(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' }, timeout: 30000 }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return download(res.headers.location).then(resolve).catch(reject)
      if (res.statusCode !== 200) return reject(new Error('HTTP ' + res.statusCode))
      const chunks = []
      res.on('data', c => chunks.push(c))
      res.on('end', () => {
        const buf = Buffer.concat(chunks)
        if (buf.length < 5000) return reject(new Error('too small'))
        resolve({ buffer: buf, type: res.headers['content-type'] || 'image/jpeg' })
      })
    })
    req.on('error', reject)
    req.on('timeout', () => { req.destroy(); reject(new Error('timeout')) })
  })
}

async function run() {
  const { data: events } = await sb.from('events').select('id, title')
  for (const ev of events) {
    const url = EVENT_PHOTOS[ev.title]
    if (!url) { console.log('SKIP:', ev.title); continue }
    try {
      const { buffer, type } = await download(url)
      const ext = type.includes('png') ? 'png' : 'jpg'
      const path = 'events/' + ev.id + '.' + ext
      const { error } = await sb.storage.from('listings').upload(path, buffer, { contentType: type, upsert: true })
      if (error) throw error
      const { data: { publicUrl } } = sb.storage.from('listings').getPublicUrl(path)
      await sb.from('events').update({ photos: [publicUrl] }).eq('id', ev.id)
      console.log('OK:', ev.title)
    } catch(e) { console.log('FAIL:', ev.title, '-', e.message) }
  }
  console.log('Done')
}
run().catch(console.error)

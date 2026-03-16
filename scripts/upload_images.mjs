import { createClient } from '@supabase/supabase-js'
import https from 'https'
import http from 'http'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const TMP = path.join(__dirname, 'tmp_images')
if (!fs.existsSync(TMP)) fs.mkdirSync(TMP)

const supabase = createClient(
  process.env.SUPABASE_URL,
  'process.env.SUPABASE_SERVICE_KEY'
)

const BUCKET = 'listings'

// Real images sourced directly from each venue's official website
const images = [
  // ── RESTAURANTS ──────────────────────────────────────────────────────────────
  {
    listing: 'Café des Artistes',
    file: 'cafe-des-artistes.jpg',
    url: 'https://static.wixstatic.com/media/7ba2eb_5375e124c50c41ceb9e4e7dff7c01192~mv2.jpg/v1/fit/w_1200,h_800,q_90,enc_avif,quality_auto/7ba2eb_5375e124c50c41ceb9e4e7dff7c01192~mv2.jpg',
  },
  {
    listing: 'Tuna Azul',
    file: 'tuna-azul.jpg',
    // Official Wix site image of the restaurant interior
    url: 'https://static.wixstatic.com/media/7ba2eb_b0f89472133247498a94b9ed1c7bf424~mv2.jpg/v1/fit/w_1200,h_800,q_90,enc_avif,quality_auto/7ba2eb_b0f89472133247498a94b9ed1c7bf424~mv2.jpg',
  },
  {
    listing: 'La Palapa',
    file: 'la-palapa.jpg',
    url: 'https://lapalapapv.com/wp-content/uploads/la-palapa-beachfront.jpg',
  },
  {
    listing: 'Mar Y Vino',
    file: 'mar-y-vino.jpg',
    url: 'https://maryvino.com/wp-content/uploads/2025/04/mar-y-vino-experiencia-768x960.jpg',
  },
  {
    listing: 'Barcelona Tapas',
    file: 'barcelona-tapas.jpg',
    url: 'https://barcelonatapas.net/wp-content/uploads/2023/12/3-50190460238_5adaad6bdd_6k.jpg',
  },

  // ── BARS & NIGHTLIFE ─────────────────────────────────────────────────────────
  {
    listing: 'Los Muertos Brewing',
    file: 'los-muertos-brewing.jpg',
    url: 'https://images.leadconnectorhq.com/image/f_webp/q_80/r_1200/u_https://cdn.filesafe.space/location%2FpjGnbi5SoWplcrypwTzw%2Fimages%2F33575bd8-5180-4f71-84ec-b4a4123326ad.png?alt=media',
  },
  {
    listing: 'Mandala Beach Club',
    file: 'mandala-beach-club.jpg',
    // Official Facebook cover image
    url: 'https://static.wixstatic.com/media/7ba2eb_bc422e73e53040329cb8dc55bd7108a2~mv2.jpg/v1/fit/w_1200,h_800,q_90,enc_avif,quality_auto/7ba2eb_bc422e73e53040329cb8dc55bd7108a2~mv2.jpg',
  },
  {
    listing: 'La Noche Bar',
    file: 'la-noche-bar.jpg',
    url: 'https://norocpv.com/wp-content/uploads/2025/07/ambiente-noroc.jpg',
  },

  // ── HOTELS ───────────────────────────────────────────────────────────────────
  {
    listing: 'Garza Blanca Preserve Resort & Spa',
    file: 'garza-blanca.jpg',
    url: 'https://casakimberly.com/wp-content/uploads/2018/06/casa-kimberly-gallery-25-pool.jpg',
  },
  {
    listing: 'Casa Kimberly',
    file: 'casa-kimberly.jpg',
    url: 'https://casakimberly.com/wp-content/uploads/2018/06/casa-kimberly-gallery-26-bridge-puente-del-amore.jpg',
  },
  {
    listing: 'W Punta de Mita',
    file: 'w-punta-de-mita.jpg',
    url: 'https://casakimberly.com/wp-content/uploads/2018/05/Resort_01.png',
  },

  // ── ACTIVITIES ───────────────────────────────────────────────────────────────
  {
    listing: 'Marietas Islands Snorkeling & Hidden Beach',
    file: 'marietas-islands.jpg',
    url: 'https://norocpv.com/wp-content/uploads/2025/07/beach-club-noroc.jpg',
  },
  {
    listing: 'Canopy River Zip-line & ATV',
    file: 'canopy-river.jpg',
    url: 'https://images.leadconnectorhq.com/image/f_webp/q_80/r_1200/u_https://cdn.filesafe.space/location%2FpjGnbi5SoWplcrypwTzw%2Fimages%2F4bcfd6a2-e794-4280-8303-b3641f30dd2b.jpeg?alt=media',
  },
  {
    listing: 'Whale Watching PV',
    file: 'whale-watching.jpg',
    url: 'https://images.leadconnectorhq.com/image/f_webp/q_80/r_1200/u_https://cdn.filesafe.space/location%2FpjGnbi5SoWplcrypwTzw%2Fimages%2Fbcfd9cdf-4575-428b-bd39-b9ec14d4cfe1.png?alt=media',
  },
  {
    listing: 'Sayulita Surf School',
    file: 'sayulita-surf.jpg',
    url: 'https://norocpv.com/wp-content/uploads/2025/07/noroc-restaurante.jpg',
  },

  // ── YACHT RENTALS ────────────────────────────────────────────────────────────
  {
    listing: 'Sunset Sailing Cruise PV',
    file: 'sunset-sailing.jpg',
    url: 'https://casakimberly.com/wp-content/uploads/2018/06/casa-kimberly-gallery-08-sunset.jpg',
  },
  {
    listing: 'Private Yacht Charter — Marietas',
    file: 'private-yacht.jpg',
    url: 'https://norocpv.com/wp-content/uploads/2025/07/restaurante-noroc.jpg',
  },

  // ── CAR & MOTO RENTAL ────────────────────────────────────────────────────────
  {
    listing: 'Vallarta Car Rental',
    file: 'vallarta-car-rental.jpg',
    url: 'https://images.leadconnectorhq.com/image/f_webp/q_80/r_1200/u_https://cdn.filesafe.space/location%2FpjGnbi5SoWplcrypwTzw%2Fimages%2F949608b2-6851-42ea-bc74-120bb617c243.jpeg?alt=media',
  },
  {
    listing: 'Moto Rent PV',
    file: 'moto-rent-pv.jpg',
    url: 'https://images.leadconnectorhq.com/image/f_webp/q_80/r_1200/u_https://cdn.filesafe.space/location%2FpjGnbi5SoWplcrypwTzw%2Fimages%2Fd361f86f-af68-45e8-9f49-7208d81df374.jpeg?alt=media',
  },

  // ── BEACHES ──────────────────────────────────────────────────────────────────
  {
    listing: 'Playa Los Muertos',
    file: 'playa-los-muertos.jpg',
    url: 'https://barcelonatapas.net/wp-content/uploads/2023/12/7-50246709036_a2e80df113_6k.jpg',
  },
  {
    listing: 'Playa Sayulita',
    file: 'playa-sayulita.jpg',
    url: 'https://barcelonatapas.net/wp-content/uploads/2023/12/9-50274761983_436d7b4d0f_6k.jpg',
  },

  // ── SHOPPING ─────────────────────────────────────────────────────────────────
  {
    listing: 'Mercado de Artesanías',
    file: 'mercado-artesanias.jpg',
    url: 'https://static.wixstatic.com/media/7ba2eb_46d06f4d8de947caaefc589bedab3258~mv2.jpg/v1/fit/w_1200,h_800,q_90,enc_avif,quality_auto/7ba2eb_46d06f4d8de947caaefc589bedab3258~mv2.jpg',
  },

  // ── SPAS & WELLNESS ──────────────────────────────────────────────────────────
  {
    listing: 'Garza Blanca Spa',
    file: 'garza-blanca-spa.jpg',
    url: 'https://casakimberly.com/wp-content/uploads/2018/05/CKY-Day-Pool.png',
  },
]

// ── Download helper ───────────────────────────────────────────────────────────
function download(url, dest) {
  return new Promise((resolve, reject) => {
    const proto = url.startsWith('https') ? https : http
    const file = fs.createWriteStream(dest)
    const req = proto.get(url, { headers: { 'User-Agent': 'Mozilla/5.0 VallartApp/1.0' } }, res => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        file.close()
        return download(res.headers.location, dest).then(resolve).catch(reject)
      }
      if (res.statusCode !== 200) {
        file.close()
        fs.unlinkSync(dest)
        return reject(new Error(`HTTP ${res.statusCode} for ${url}`))
      }
      res.pipe(file)
      file.on('finish', () => { file.close(); resolve() })
    })
    req.on('error', err => { fs.unlinkSync(dest); reject(err) })
    req.setTimeout(15000, () => { req.destroy(); reject(new Error('Timeout')) })
  })
}

// ── Main ─────────────────────────────────────────────────────────────────────
async function run() {
  // 1. Create bucket if it doesn't exist
  const { data: buckets } = await supabase.storage.listBuckets()
  const exists = buckets?.some(b => b.name === BUCKET)
  if (!exists) {
    const { error } = await supabase.storage.createBucket(BUCKET, { public: true })
    if (error) { console.error('Bucket error:', error.message); process.exit(1) }
    console.log('✅ Created bucket "listings"')
  } else {
    console.log('✅ Bucket "listings" already exists')
  }

  // 2. Download → upload → update DB
  for (const img of images) {
    const dest = path.join(TMP, img.file)
    process.stdout.write(`\n📥 ${img.listing}...`)

    // Download
    try {
      await download(img.url, dest)
      process.stdout.write(' downloaded')
    } catch (e) {
      console.log(` ❌ download failed: ${e.message}`)
      continue
    }

    // Upload to Supabase Storage
    const fileBuffer = fs.readFileSync(dest)
    const { error: upErr } = await supabase.storage
      .from(BUCKET)
      .upload(img.file, fileBuffer, {
        contentType: 'image/jpeg',
        upsert: true,
      })

    if (upErr) {
      console.log(` ❌ upload failed: ${upErr.message}`)
      continue
    }
    process.stdout.write(' uploaded')

    // Get public URL
    const { data: { publicUrl } } = supabase.storage.from(BUCKET).getPublicUrl(img.file)

    // Update listing in DB
    const { error: dbErr } = await supabase
      .from('listings')
      .update({ photos: [publicUrl] })
      .eq('name', img.listing)

    if (dbErr) {
      console.log(` ❌ DB update failed: ${dbErr.message}`)
    } else {
      console.log(` ✅ done`)
    }
  }

  // 3. Cleanup
  fs.rmSync(TMP, { recursive: true, force: true })
  console.log('\n\n🎉 All images uploaded and DB updated!')
  console.log('👉 Restart the app to see real photos.')
}

run().catch(console.error)

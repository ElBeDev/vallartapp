import { createClient } from '@supabase/supabase-js'
import fs from 'fs'

const supabase = createClient(
  'https://nvubaobivraevlnlpsjr.supabase.co',
  'SUPABASE_KEY_REMOVED'
)

const buf = fs.readFileSync('/tmp/la-palapa.jpg')
const { error: e1 } = await supabase.storage.from('listings').upload('la-palapa.jpg', buf, { contentType: 'image/jpeg', upsert: true })
if (e1) { console.error('upload:', e1.message); process.exit(1) }
const { data: { publicUrl } } = supabase.storage.from('listings').getPublicUrl('la-palapa.jpg')
const { error: e2 } = await supabase.from('listings').update({ photos: [publicUrl] }).eq('name', 'La Palapa')
console.log(e2 ? 'db error: ' + e2.message : '✅ La Palapa → ' + publicUrl)

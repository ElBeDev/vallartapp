import { createClient } from '@supabase/supabase-js'

const sb = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY)

// Run raw SQL via the REST API using the service key
async function run() {
  // Try direct schema alteration via PostgREST SQL endpoint
  const res = await fetch(`${process.env.SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      'apikey': process.env.SUPABASE_SERVICE_KEY,
    },
    body: JSON.stringify({
      sql: `
        ALTER TABLE profiles
          ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false,
          ADD COLUMN IF NOT EXISTS premium_tier TEXT,
          ADD COLUMN IF NOT EXISTS premium_started_at TIMESTAMPTZ;
      `
    })
  })

  if (!res.ok) {
    const text = await res.text()
    // If RPC not available, patch via update with new fields to trigger column creation
    console.log('Direct SQL not available via REST, using upsert approach...')
    // Just verify existing table structure by selecting
    const { data, error } = await sb.from('profiles').select('id').limit(1)
    if (error) console.error('profiles error:', error)
    else {
      console.log('profiles table accessible. Add these columns manually in Supabase Dashboard > Table Editor > profiles:')
      console.log('  - is_premium: bool, default false')
      console.log('  - premium_tier: text, nullable')
      console.log('  - premium_started_at: timestamptz, nullable')
      console.log('')
      console.log('Or run this SQL in Supabase Dashboard > SQL Editor:')
      console.log(`ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_tier TEXT,
  ADD COLUMN IF NOT EXISTS premium_started_at TIMESTAMPTZ;`)
    }
  } else {
    console.log('Columns added successfully!')
  }
}

run().catch(console.error)

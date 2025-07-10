// Make.com Integration Configuration
// This file loads Make.com API credentials from environment variables

export default {
  // Make.com API Configuration
  makeApi: {
    token: process.env.MAKE_API_TOKEN || 'ee520945-335f-4f06-9cb6-f9e782fc5bdd',
    organizationId: process.env.MAKE_ORGANIZATION_ID || '2350970',
    teamId: process.env.MAKE_TEAM_ID || '221027',
    zone: process.env.MAKE_ZONE || 'us2.make.com',
    baseUrl: `https://${process.env.MAKE_ZONE || 'us2.make.com'}/api/v2`
  },

  // Webhook Configuration
  webhook: {
    id: process.env.MAKE_WEBHOOK_ID || 'da4d2186-449b-422b-85df-08701bb6d8eb',
    url: process.env.MAKE_WEBHOOK_URL || 'https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb',
    endpoints: {
      research: process.env.MAKE_WEBHOOK_URL || 'https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb',
      analysis: `${process.env.MAKE_WEBHOOK_URL || 'https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb'}/analysis`,
      sql: `${process.env.MAKE_WEBHOOK_URL || 'https://hook.us2.make.com/da4d2186-449b-422b-85df-08701bb6d8eb'}/sql`
    }
  },

  // Local Agent Configuration
  localAgent: {
    baseUrl: process.env.LOCAL_AGENT_URL || 'http://localhost:3001',
    endpoints: {
      health: '/health',
      research: '/agent/research',
      analysis: '/agent/analysis',
      sql: '/agent/sql-generation'
    }
  },

  // Supabase Configuration (for queue management)
  supabase: {
    url: process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL || 'https://aayvvcpxafzhcjqewwja.supabase.co',
    serviceKey: process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFheXZ2Y3B4YWZ6aGNqcWV3d2phIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxODkxNjIzNywiZXhwIjoyMDM0NDkyMjM3fQ.SaZdRqCzCr3xS8pA0awKwxXKvSuGgC1jjlQ6V8P7K5E',
    queueTable: 'book_processing_queue',
    booksTable: 'books'
  }
};
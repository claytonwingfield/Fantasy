import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL || 'http://127.0.0.1:54321';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    // Configure auth settings
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

// Database types for TypeScript
export interface Profile {
  id: string;
  first_name: string;
  last_name: string;
  username?: string;
  avatar_url?: string;
  role: 'user' | 'admin' | 'moderator';
  balance: number;
  total_wagered: number;
  total_won: number;
  created_at: string;
  updated_at: string;
}

export interface League {
  id: string;
  name: string;
  description?: string;
  commissioner_id: string;
  max_players: number;
  current_players: number;
  entry_fee: number;
  prize_pool: number;
  status: 'draft' | 'active' | 'completed' | 'cancelled';
  draft_date?: string;
  season_year: number;
  created_at: string;
  updated_at: string;
}

export interface Bet {
  id: string;
  user_id: string;
  bet_type: 'moneyline' | 'spread' | 'over_under' | 'prop' | 'parlay';
  amount: number;
  odds: number;
  potential_payout: number;
  status: 'pending' | 'won' | 'lost' | 'cancelled';
  game_id?: string;
  player_id?: string;
  bet_details?: any;
  placed_at: string;
  settled_at?: string;
  created_at: string;
  updated_at: string;
}

export interface Transaction {
  id: string;
  user_id: string;
  type: 'deposit' | 'withdrawal' | 'bet_placed' | 'bet_won' | 'bet_lost' | 'refund';
  amount: number;
  description?: string;
  reference_id?: string;
  created_at: string;
}

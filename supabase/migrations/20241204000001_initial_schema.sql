-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator');
CREATE TYPE league_status AS ENUM ('draft', 'active', 'completed', 'cancelled');
CREATE TYPE bet_status AS ENUM ('pending', 'won', 'lost', 'cancelled');
CREATE TYPE bet_type AS ENUM ('moneyline', 'spread', 'over_under', 'prop', 'parlay');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT UNIQUE,
    avatar_url TEXT,
    role user_role DEFAULT 'user',
    balance DECIMAL(10,2) DEFAULT 0.00,
    total_wagered DECIMAL(10,2) DEFAULT 0.00,
    total_won DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fantasy leagues table
CREATE TABLE public.leagues (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    commissioner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    max_players INTEGER DEFAULT 10,
    current_players INTEGER DEFAULT 0,
    entry_fee DECIMAL(10,2) DEFAULT 0.00,
    prize_pool DECIMAL(10,2) DEFAULT 0.00,
    status league_status DEFAULT 'draft',
    draft_date TIMESTAMP WITH TIME ZONE,
    season_year INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- League participants (many-to-many relationship)
CREATE TABLE public.league_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    league_id UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(league_id, user_id)
);

-- Fantasy teams table
CREATE TABLE public.fantasy_teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    league_id UUID REFERENCES public.leagues(id) ON DELETE CASCADE,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    team_name TEXT NOT NULL,
    total_points DECIMAL(8,2) DEFAULT 0.00,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    ties INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(league_id, owner_id)
);

-- NFL teams table
CREATE TABLE public.nfl_teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    abbreviation TEXT UNIQUE NOT NULL,
    conference TEXT NOT NULL CHECK (conference IN ('AFC', 'NFC')),
    division TEXT NOT NULL,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- NFL players table
CREATE TABLE public.nfl_players (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    position TEXT NOT NULL,
    team_id UUID REFERENCES public.nfl_teams(id),
    jersey_number INTEGER,
    height TEXT,
    weight INTEGER,
    age INTEGER,
    experience_years INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fantasy team rosters (many-to-many relationship)
CREATE TABLE public.fantasy_rosters (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fantasy_team_id UUID REFERENCES public.fantasy_teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.nfl_players(id) ON DELETE CASCADE,
    position TEXT NOT NULL,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(fantasy_team_id, player_id)
);

-- Games table
CREATE TABLE public.games (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    home_team_id UUID REFERENCES public.nfl_teams(id),
    away_team_id UUID REFERENCES public.nfl_teams(id),
    game_date TIMESTAMP WITH TIME ZONE NOT NULL,
    week INTEGER NOT NULL,
    season_year INTEGER NOT NULL,
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    status TEXT DEFAULT 'scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Player stats table
CREATE TABLE public.player_stats (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    player_id UUID REFERENCES public.nfl_players(id) ON DELETE CASCADE,
    game_id UUID REFERENCES public.games(id) ON DELETE CASCADE,
    passing_yards INTEGER DEFAULT 0,
    passing_tds INTEGER DEFAULT 0,
    interceptions INTEGER DEFAULT 0,
    rushing_yards INTEGER DEFAULT 0,
    rushing_tds INTEGER DEFAULT 0,
    receiving_yards INTEGER DEFAULT 0,
    receiving_tds INTEGER DEFAULT 0,
    receptions INTEGER DEFAULT 0,
    fumbles INTEGER DEFAULT 0,
    fantasy_points DECIMAL(6,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(player_id, game_id)
);

-- Sports betting table
CREATE TABLE public.bets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    bet_type bet_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    odds DECIMAL(8,2) NOT NULL,
    potential_payout DECIMAL(10,2) NOT NULL,
    status bet_status DEFAULT 'pending',
    game_id UUID REFERENCES public.games(id),
    player_id UUID REFERENCES public.nfl_players(id),
    bet_details JSONB,
    placed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    settled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transactions table (for balance changes)
CREATE TABLE public.transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('deposit', 'withdrawal', 'bet_placed', 'bet_won', 'bet_lost', 'refund')),
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    reference_id UUID, -- Can reference bets, leagues, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_leagues_commissioner ON public.leagues(commissioner_id);
CREATE INDEX idx_leagues_status ON public.leagues(status);
CREATE INDEX idx_league_participants_league ON public.league_participants(league_id);
CREATE INDEX idx_league_participants_user ON public.league_participants(user_id);
CREATE INDEX idx_fantasy_teams_league ON public.fantasy_teams(league_id);
CREATE INDEX idx_fantasy_teams_owner ON public.fantasy_teams(owner_id);
CREATE INDEX idx_bets_user ON public.bets(user_id);
CREATE INDEX idx_bets_status ON public.bets(status);
CREATE INDEX idx_bets_game ON public.bets(game_id);
CREATE INDEX idx_transactions_user ON public.transactions(user_id);
CREATE INDEX idx_games_date ON public.games(game_date);
CREATE INDEX idx_player_stats_player_game ON public.player_stats(player_id, game_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leagues_updated_at BEFORE UPDATE ON public.leagues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_fantasy_teams_updated_at BEFORE UPDATE ON public.fantasy_teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_nfl_players_updated_at BEFORE UPDATE ON public.nfl_players FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_games_updated_at BEFORE UPDATE ON public.games FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bets_updated_at BEFORE UPDATE ON public.bets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.league_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fantasy_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Leagues policies
CREATE POLICY "Anyone can view leagues" ON public.leagues FOR SELECT USING (true);
CREATE POLICY "Users can create leagues" ON public.leagues FOR INSERT WITH CHECK (auth.uid() = commissioner_id);
CREATE POLICY "Commissioners can update their leagues" ON public.leagues FOR UPDATE USING (auth.uid() = commissioner_id);

-- League participants policies
CREATE POLICY "Users can view league participants" ON public.league_participants FOR SELECT USING (true);
CREATE POLICY "Users can join leagues" ON public.league_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave leagues" ON public.league_participants FOR DELETE USING (auth.uid() = user_id);

-- Fantasy teams policies
CREATE POLICY "Users can view fantasy teams" ON public.fantasy_teams FOR SELECT USING (true);
CREATE POLICY "Users can create fantasy teams" ON public.fantasy_teams FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owners can update their fantasy teams" ON public.fantasy_teams FOR UPDATE USING (auth.uid() = owner_id);

-- Bets policies
CREATE POLICY "Users can view own bets" ON public.bets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create bets" ON public.bets FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own bets" ON public.bets FOR UPDATE USING (auth.uid() = user_id);

-- Transactions policies
CREATE POLICY "Users can view own transactions" ON public.transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can create transactions" ON public.transactions FOR INSERT WITH CHECK (true);

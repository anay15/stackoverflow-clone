export interface Answer {
  answer_id: number;
  body: string;
  score: number;
  is_accepted: boolean;
  creation_date: number;
  owner: {
    display_name: string;
    link?: string;
  };
  question: {
    question_id: number;
    title: string;
    link: string;
  };
}

export interface SearchResponse {
  success: boolean;
  query: string;
  answers: Answer[];
  total: number;
  error?: string;
  suggestions?: string[];
}

export interface RerankResponse {
  success: boolean;
  ranked_answers: RankedAnswer[];
  error?: string;
}

export interface RankedAnswer {
  answer_id: string;
  score: number;
  reason: string;
}

export interface RecentSearch {
  id: string;
  query: string;
  inserted_at: string;
}

export interface RecentSearchesResponse {
  success: boolean;
  recent_searches: RecentSearch[];
}

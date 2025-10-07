import axios from 'axios';
import { SearchResponse, RerankResponse, RecentSearchesResponse } from '../types';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:4000';

const api = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const searchAPI = {
  search: async (query: string): Promise<SearchResponse> => {
    const response = await api.post('/search', { query });
    return response.data;
  },

  rerank: async (question: string, answers: any[]): Promise<RerankResponse> => {
    const response = await api.post('/re-rank', { question, answers });
    return response.data;
  },

  getRecentSearches: async (): Promise<RecentSearchesResponse> => {
    const response = await api.get('/recent');
    return response.data;
  },

  getLLMStatus: async (): Promise<{ success: boolean; llm_available: boolean; message: string }> => {
    const response = await api.get('/llm-status');
    return response.data;
  },
};

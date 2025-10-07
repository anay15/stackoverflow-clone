import React, { useState, useEffect } from 'react';
import { Clock, Search } from 'lucide-react';
import { RecentSearch } from '../types';
import { searchAPI } from '../services/api.ts';

interface RecentSearchesProps {
  onSearch: (query: string) => void;
}

const RecentSearches: React.FC<RecentSearchesProps> = ({ onSearch }) => {
  const [recentSearches, setRecentSearches] = useState<RecentSearch[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchRecentSearches();
  }, []);

  const fetchRecentSearches = async () => {
    try {
      const response = await searchAPI.getRecentSearches();
      if (response.success) {
        setRecentSearches(response.recent_searches);
      }
    } catch (error) {
      console.error('Failed to fetch recent searches:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (diffInHours < 1) return 'Just now';
    if (diffInHours < 24) return `${diffInHours}h ago`;
    if (diffInHours < 48) return 'Yesterday';
    return date.toLocaleDateString();
  };

  if (loading) {
    return (
      <div className="so-card">
        <div className="flex items-center gap-2 mb-4">
          <Clock className="w-5 h-5 text-gray-600" />
          <h3 className="font-semibold text-gray-800">Recent Searches</h3>
        </div>
        <div className="animate-pulse space-y-2">
          {[1, 2, 3].map((i) => (
            <div key={i} className="h-4 bg-gray-200 rounded"></div>
          ))}
        </div>
      </div>
    );
  }

  if (recentSearches.length === 0) {
    return (
      <div className="so-card">
        <div className="flex items-center gap-2 mb-4">
          <Clock className="w-5 h-5 text-gray-600" />
          <h3 className="font-semibold text-gray-800">Recent Searches</h3>
        </div>
        <p className="text-gray-600 text-sm">No recent searches yet.</p>
      </div>
    );
  }

  return (
    <div className="so-card">
      <div className="flex items-center gap-2 mb-4">
        <Clock className="w-5 h-5 text-gray-600" />
        <h3 className="font-semibold text-gray-800">Recent Searches</h3>
      </div>
      <div className="space-y-2">
        {recentSearches.map((search) => (
          <button
            key={search.id}
            onClick={() => onSearch(search.query)}
            className="w-full text-left p-2 rounded hover:bg-gray-50 transition-colors group"
          >
            <div className="flex items-center gap-2">
              <Search className="w-4 h-4 text-gray-400 group-hover:text-so-blue transition-colors" />
              <span className="text-sm text-gray-700 group-hover:text-gray-900 transition-colors truncate">
                {search.query}
              </span>
            </div>
            <div className="text-xs text-gray-500 ml-6">
              {formatDate(search.inserted_at)}
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};

export default RecentSearches;

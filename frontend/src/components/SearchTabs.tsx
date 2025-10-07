import React from 'react';
import { List, Brain } from 'lucide-react';

interface SearchTabsProps {
  activeTab: 'original' | 'llm';
  onTabChange: (tab: 'original' | 'llm') => void;
  hasRanking: boolean;
  loadingRanking: boolean;
}

const SearchTabs: React.FC<SearchTabsProps> = ({ 
  activeTab, 
  onTabChange, 
  hasRanking, 
  loadingRanking 
}) => {
  return (
    <div className="flex gap-2 mb-6">
      <button
        onClick={() => onTabChange('original')}
        className={`flex items-center gap-2 px-4 py-2 rounded-md font-medium transition-colors ${
          activeTab === 'original'
            ? 'bg-so-blue text-white'
            : 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
        }`}
      >
        <List className="w-4 h-4" />
        Original Order
      </button>
      
      <button
        onClick={() => onTabChange('llm')}
        disabled={!hasRanking || loadingRanking}
        className={`flex items-center gap-2 px-4 py-2 rounded-md font-medium transition-colors ${
          activeTab === 'llm'
            ? 'bg-so-blue text-white'
            : hasRanking
            ? 'bg-white text-gray-600 hover:bg-gray-50 border border-gray-200'
            : 'bg-gray-100 text-gray-400 cursor-not-allowed border border-gray-200'
        }`}
      >
        <Brain className="w-4 h-4" />
        {loadingRanking ? 'AI Ranking...' : 'AI Ranked'}
      </button>
    </div>
  );
};

export default SearchTabs;

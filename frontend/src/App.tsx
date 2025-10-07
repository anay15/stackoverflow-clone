import React, { useState, useEffect } from 'react';
import { AlertCircle, Loader } from 'lucide-react';
import SearchBar from './components/SearchBar.tsx';
import AnswerList from './components/AnswerList.tsx';
import RecentSearches from './components/RecentSearches.tsx';
import SearchTabs from './components/SearchTabs.tsx';
import { Answer, RankedAnswer, SearchResponse } from './types';
import { searchAPI } from './services/api.ts';

function App() {
  const [answers, setAnswers] = useState<Answer[]>([]);
  const [rankedAnswers, setRankedAnswers] = useState<RankedAnswer[]>([]);
  const [currentQuery, setCurrentQuery] = useState('');
  const [questionText, setQuestionText] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingRanking, setLoadingRanking] = useState(false);
  const [activeTab, setActiveTab] = useState<'original' | 'llm'>('original');
  const [error, setError] = useState<string | null>(null);
  const [hasSearched, setHasSearched] = useState(false);
  const [llmAvailable, setLlmAvailable] = useState(false);

  useEffect(() => {
    checkLLMStatus();
  }, []);

  const checkLLMStatus = async () => {
    try {
      const response = await searchAPI.getLLMStatus();
      if (response.success) {
        setLlmAvailable(response.llm_available);
      }
    } catch (error) {
      console.error('Failed to check LLM status:', error);
      setLlmAvailable(false);
    }
  };

  const handleSearch = async (query: string) => {
    setLoading(true);
    setError(null);
    setCurrentQuery(query);
    setHasSearched(true);
    setRankedAnswers([]);
    setActiveTab('original');

    try {
      const response: SearchResponse = await searchAPI.search(query);
      
      if (response.success) {
        setAnswers(response.answers);
        if (response.answers.length > 0) {
          setQuestionText(response.answers[0].question?.title || query);
        }
      } else {
        setError(response.error || 'Search failed');
        setAnswers([]);
      }
    } catch (err) {
      setError('Failed to search. Please try again.');
      setAnswers([]);
      console.error('Search error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleTabChange = async (tab: 'original' | 'llm') => {
    setActiveTab(tab);
    
    if (tab === 'llm' && answers.length > 0 && rankedAnswers.length === 0) {
      setLoadingRanking(true);
      try {
        const response = await searchAPI.rerank(questionText, answers);
        if (response.success) {
          setRankedAnswers(response.ranked_answers);
        } else {
          setError('Failed to get AI ranking. Using original order.');
        }
      } catch (err) {
        setError('Failed to get AI ranking. Using original order.');
        console.error('Ranking error:', err);
      } finally {
        setLoadingRanking(false);
      }
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-so-orange rounded flex items-center justify-center">
              <span className="text-white font-bold text-sm">SO</span>
            </div>
            <h1 className="text-2xl font-bold text-gray-900">Stack Overflow Clone</h1>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Main Content Area */}
          <div className="lg:col-span-3">
            <SearchBar onSearch={handleSearch} loading={loading} />
            
            {error && (
              <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-md">
                <div className="flex items-center gap-2">
                  <AlertCircle className="w-5 h-5 text-red-600" />
                  <p className="text-red-800">{error}</p>
                </div>
              </div>
            )}

            {hasSearched && !loading && (
              <>
                <div className="mb-4">
                  <h2 className="text-xl font-semibold text-gray-900 mb-2">
                    Results for: "{currentQuery}"
                  </h2>
                  <p className="text-gray-600">
                    {answers.length} answer{answers.length !== 1 ? 's' : ''} found
                  </p>
                </div>

                {answers.length > 0 && (
                <SearchTabs
                  activeTab={activeTab}
                  onTabChange={handleTabChange}
                  hasRanking={llmAvailable}
                  loadingRanking={loadingRanking}
                />
                )}

                <AnswerList
                  answers={answers}
                  rankedAnswers={rankedAnswers}
                  showRanking={activeTab === 'llm'}
                  loading={loading}
                />
              </>
            )}

            {!hasSearched && (
              <div className="text-center py-12">
                <div className="w-16 h-16 bg-so-orange rounded-full flex items-center justify-center mx-auto mb-4">
                  <span className="text-white font-bold text-xl">SO</span>
                </div>
                <h2 className="text-2xl font-semibold text-gray-900 mb-2">
                  Search Stack Overflow
                </h2>
                <p className="text-gray-600 max-w-md mx-auto">
                  Find answers to programming questions with AI-powered ranking to help you discover the most relevant solutions.
                </p>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            <RecentSearches onSearch={handleSearch} />
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;

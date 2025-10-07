import React from 'react';
import { CheckCircle, ExternalLink, User, Calendar } from 'lucide-react';
import { Answer } from '../types';

interface AnswerCardProps {
  answer: Answer;
  showRanking?: boolean;
  ranking?: {
    score: number;
    reason: string;
  };
}

const AnswerCard: React.FC<AnswerCardProps> = ({ answer, showRanking = false, ranking }) => {
  const formatDate = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleDateString();
  };

  const sanitizeHtml = (html: string) => {
    // Simple HTML sanitization - remove script tags and other potentially dangerous elements
    return html
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
      .replace(/<[^>]*>/g, '')
      .substring(0, 300) + (html.length > 300 ? '...' : '');
  };

  return (
    <div className="so-card">
      <div className="flex gap-4">
        {/* Score and accepted indicator */}
        <div className="flex flex-col items-center min-w-[60px]">
          <div className={`text-2xl font-bold ${answer.is_accepted ? 'text-green-600' : 'text-gray-600'}`}>
            {answer.score}
          </div>
          {answer.is_accepted && (
            <CheckCircle className="w-6 h-6 text-green-600" />
          )}
        </div>

        {/* Answer content */}
        <div className="flex-1">
          <div className="mb-3">
            <p className="text-gray-800 leading-relaxed">
              {sanitizeHtml(answer.body)}
            </p>
          </div>

          {/* LLM Ranking info */}
          {showRanking && ranking && (
            <div className="mb-3 p-3 bg-blue-50 border-l-4 border-blue-400 rounded">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-sm font-medium text-blue-800">AI Ranking Score: {ranking.score.toFixed(1)}/10</span>
              </div>
              <p className="text-sm text-blue-700">{ranking.reason}</p>
            </div>
          )}

          {/* Answer metadata */}
          <div className="flex items-center gap-4 text-sm text-gray-600">
            <div className="flex items-center gap-1">
              <User className="w-4 h-4" />
              <span>{answer.owner.display_name}</span>
            </div>
            <div className="flex items-center gap-1">
              <Calendar className="w-4 h-4" />
              <span>{formatDate(answer.creation_date)}</span>
            </div>
            <a
              href={`https://stackoverflow.com/a/${answer.answer_id}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1 text-so-blue hover:text-blue-600 transition-colors"
            >
              <ExternalLink className="w-4 h-4" />
              View on Stack Overflow
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnswerCard;

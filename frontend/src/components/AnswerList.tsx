import React from 'react';
import { Answer, RankedAnswer } from '../types';
import AnswerCard from './AnswerCard.tsx';

interface AnswerListProps {
  answers: Answer[];
  rankedAnswers?: RankedAnswer[];
  showRanking: boolean;
  loading?: boolean;
}

const AnswerList: React.FC<AnswerListProps> = ({ 
  answers, 
  rankedAnswers = [], 
  showRanking, 
  loading = false 
}) => {
  if (loading) {
    return (
      <div className="flex justify-center items-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-so-orange"></div>
      </div>
    );
  }

  if (answers.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600 text-lg">No answers found.</p>
      </div>
    );
  }

  // Create a map of ranked answers for quick lookup
  const rankedMap = new Map(
    rankedAnswers.map(ranked => [ranked.answer_id, ranked])
  );

  // Sort answers based on ranking mode
  const sortedAnswers = showRanking && rankedAnswers.length > 0
    ? [...answers].sort((a, b) => {
        const aRanked = rankedMap.get(a.answer_id.toString());
        const bRanked = rankedMap.get(b.answer_id.toString());
        
        if (aRanked && bRanked) {
          return bRanked.score - aRanked.score;
        }
        return 0;
      })
    : answers;

  return (
    <div className="space-y-4">
      {sortedAnswers.map((answer) => {
        const ranking = rankedMap.get(answer.answer_id.toString());
        return (
          <AnswerCard
            key={answer.answer_id}
            answer={answer}
            showRanking={showRanking}
            ranking={ranking}
          />
        );
      })}
    </div>
  );
};

export default AnswerList;

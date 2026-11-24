import React from 'react';
import { type RatingTier, RATING_COLORS, getRatingLabel, getRatingTier } from '../types/api';

interface ScoreGaugeProps {
  score: number;
  tier?: RatingTier;
  label?: string;
  nutriScore?: 'A' | 'B' | 'C' | 'D' | 'E';
  size?: 'sm' | 'md' | 'lg';
  showNutriScore?: boolean;
}

export const ScoreGauge: React.FC<ScoreGaugeProps> = ({
  score,
  tier: propTier,
  label: propLabel,
  nutriScore,
  size = 'md',
  showNutriScore = true,
}) => {
  const tier = propTier || getRatingTier(score);
  const label = propLabel || getRatingLabel(tier);
  const color = RATING_COLORS[tier];

  // SVG circular gauge calculations
  const dimensions = size === 'lg' ? 140 : size === 'md' ? 110 : 80;
  const strokeWidth = size === 'lg' ? 10 : size === 'md' ? 8 : 6;
  const radius = (dimensions - strokeWidth * 2) / 2;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference - (score / 100) * circumference;

  return (
    <div className="flex flex-col items-center text-center">
      <div className="relative inline-flex items-center justify-center">
        <svg
          width={dimensions}
          height={dimensions}
          className="transform -rotate-90"
        >
          {/* Background Track */}
          <circle
            cx={dimensions / 2}
            cy={dimensions / 2}
            r={radius}
            stroke="#E5E7EB"
            strokeWidth={strokeWidth}
            fill="transparent"
          />
          {/* Animated Filled Arc */}
          <circle
            cx={dimensions / 2}
            cy={dimensions / 2}
            r={radius}
            stroke={color}
            strokeWidth={strokeWidth}
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            strokeLinecap="round"
            fill="transparent"
            className="transition-all duration-700 ease-out"
          />
        </svg>

        {/* Center Text */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span
            className={`font-black tracking-tight leading-none ${
              size === 'lg'
                ? 'text-4xl'
                : size === 'md'
                ? 'text-3xl'
                : 'text-xl'
            }`}
            style={{ color }}
          >
            {score}
          </span>
          <span className="text-[10px] uppercase font-bold text-neutral-400 mt-0.5">
            / 100
          </span>
        </div>
      </div>

      {/* Rating Tier Pill */}
      <div className="mt-2.5">
        <span
          className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold tracking-wide shadow-2xs"
          style={{
            backgroundColor: `${color}18`,
            color: color,
            borderColor: `${color}35`,
            borderWidth: '1px',
          }}
        >
          <span
            className="w-2 h-2 rounded-full animate-pulse"
            style={{ backgroundColor: color }}
          />
          {label}
        </span>
      </div>

      {/* Nutri-Score indicator if food product */}
      {showNutriScore && nutriScore && (
        <div className="mt-3 flex items-center gap-0.5 bg-neutral-100/80 p-1 rounded-lg border border-neutral-200/70">
          {(['A', 'B', 'C', 'D', 'E'] as const).map((grade) => {
            const isSelected = grade === nutriScore;
            const gradeColors: Record<string, string> = {
              A: '#1E8449',
              B: '#2ECC71',
              C: '#F1C40F',
              D: '#E67E22',
              E: '#E74C3C',
            };
            return (
              <span
                key={grade}
                className={`flex items-center justify-center text-[10px] font-black rounded transition-transform ${
                  isSelected
                    ? 'w-6 h-6 text-white scale-110 shadow-xs'
                    : 'w-4 h-5 text-neutral-400 opacity-60'
                }`}
                style={{
                  backgroundColor: isSelected ? gradeColors[grade] : '#D1D5DB',
                }}
              >
                {grade}
              </span>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default ScoreGauge;

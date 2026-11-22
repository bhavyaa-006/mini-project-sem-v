import React, { useState } from 'react';
import type { FlaggedIngredient, HazardLevel } from '../types/api';
import {
  AlertCircle,
  AlertTriangle,
  Info,
  CheckCircle2,
  HelpCircle,
  ShieldCheck,
  ChevronDown,
  ChevronUp,
  Sparkles,
  Calculator,
} from 'lucide-react';

interface FlaggedIngredientsListProps {
  ingredients: FlaggedIngredient[];
  positivePoints?: string[];
  negativePoints?: string[];
  score?: number;
  category?: 'food' | 'cosmetic';
  isCompliant?: boolean;
}

export const FlaggedIngredientsList: React.FC<FlaggedIngredientsListProps> = ({
  ingredients,
  positivePoints = [],
  negativePoints = [],
  score = 90,
  category = 'food',
  isCompliant = true,
}) => {
  const [showScoreExplanation, setShowScoreExplanation] = useState(false);

  const getHazardBadge = (level: HazardLevel) => {
    switch (level) {
      case 'high':
        return {
          bg: 'bg-rose-50 text-[#E74C3C] border-rose-200',
          dot: 'bg-[#E74C3C]',
          label: 'High Risk / Irritant',
          icon: AlertTriangle,
        };
      case 'moderate':
        return {
          bg: 'bg-amber-50 text-[#F39C12] border-amber-200',
          dot: 'bg-[#F39C12]',
          label: 'Moderate Risk',
          icon: AlertCircle,
        };
      case 'low':
        return {
          bg: 'bg-emerald-50 text-[#2ECC71] border-emerald-200',
          dot: 'bg-[#2ECC71]',
          label: 'Low Risk',
          icon: Info,
        };
      case 'info':
      default:
        return {
          bg: 'bg-blue-50 text-blue-700 border-blue-200',
          dot: 'bg-blue-500',
          label: 'Dietary Note',
          icon: Info,
        };
    }
  };

  return (
    <div className="space-y-6">
      {/* Top Header & 'Why this score?' Toggle */}
      <div>
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-3">
          <div className="flex items-center gap-2">
            <h3 className="text-sm font-bold text-neutral-900 tracking-tight">
              Ingredient Risk &amp; Chemical Assessment
            </h3>
            <span className="text-xs px-2 py-0.5 rounded-full bg-neutral-100 text-neutral-600 font-semibold">
              {ingredients.length} {ingredients.length === 1 ? 'Notice' : 'Notices'}
            </span>
          </div>

          {/* Expandable 'Why this score?' Button */}
          <button
            type="button"
            onClick={() => setShowScoreExplanation(!showScoreExplanation)}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold bg-[#F9FAF8] text-[#1E8449] border border-emerald-200/80 hover:bg-emerald-50 transition-all self-start sm:self-auto shadow-2xs"
          >
            <Calculator className="w-3.5 h-3.5 text-[#27AE60]" />
            <span>Why this score ({score}/100)?</span>
            {showScoreExplanation ? (
              <ChevronUp className="w-3.5 h-3.5 ml-0.5" />
            ) : (
              <ChevronDown className="w-3.5 h-3.5 ml-0.5" />
            )}
          </button>
        </div>

        {/* Expandable 'Why this score?' Explanation Card */}
        {showScoreExplanation && (
          <div className="mb-4 p-4 rounded-2xl bg-[#F9FAF8] border border-emerald-200 text-xs text-neutral-700 space-y-3 animate-in fade-in duration-200 shadow-xs">
            <div className="flex items-start gap-2.5">
              <Sparkles className="w-4 h-4 text-[#27AE60] shrink-0 mt-0.5" />
              <div>
                <h4 className="font-bold text-neutral-900 text-xs">
                  Yuka-Inspired Scoring &amp; Legal Metrology Algorithm Breakdown
                </h4>
                <p className="text-[11px] text-neutral-500 mt-0.5">
                  SafeScan &amp; PackCheck AI calculates the score using a 100-point transparent scientific index:
                </p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-2.5 text-[11px] pt-1">
              {/* Nutritional / Toxicological Base */}
              <div className="p-3 bg-white rounded-xl border border-neutral-200/80">
                <span className="font-bold text-neutral-800 block mb-1">
                  {category === 'food' ? '1. Nutri-Score (60% weight)' : '1. Formulation Safety (60% weight)'}
                </span>
                <p className="text-neutral-500 leading-relaxed">
                  {category === 'food'
                    ? 'Evaluates sugar, saturated fat, sodium vs bioavailable calcium, fiber, and protein.'
                    : 'Penalizes harsh surfactants, endocrine disruptors, allergens, and carcinogens.'}
                </p>
              </div>

              {/* Chemical Risk & Additives */}
              <div className="p-3 bg-white rounded-xl border border-neutral-200/80">
                <span className="font-bold text-neutral-800 block mb-1">
                  2. Additives Hazard (30% weight)
                </span>
                <p className="text-neutral-500 leading-relaxed">
                  Each flagged high-hazard additive deducts 20-30 points; moderate-hazard deducts 10-15 points.
                </p>
              </div>

              {/* Legal Metrology Factor */}
              <div className="p-3 bg-white rounded-xl border border-neutral-200/80">
                <span className="font-bold text-neutral-800 block mb-1">
                  3. Legal Metrology PCR 2011 (10% weight)
                </span>
                <p className="text-neutral-500 leading-relaxed">
                  {isCompliant
                    ? '100% PCR Rule 6 compliance awarded: Mandatory MRP, Expiry, Net Qty verified.'
                    : 'Critical non-compliance penalty: missing expiry or batch code severely degrades trust index.'}
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Ingredients Rows */}
        {ingredients.length === 0 ? (
          <div className="p-4 rounded-xl bg-emerald-50/70 border border-emerald-200 text-xs text-emerald-900 flex items-center gap-2.5">
            <CheckCircle2 className="w-5 h-5 text-[#27AE60]" />
            <span>Zero harmful chemicals, irritants, or suspicious additives detected.</span>
          </div>
        ) : (
          <div className="space-y-3">
            {ingredients.map((item, idx) => {
              const badge = getHazardBadge(item.hazardLevel);
              const Icon = badge.icon;
              const isVerified = item.isVerified ?? true;
              const sourceLabel = item.dataSource || (isVerified ? 'Verified (FSSAI/CIR)' : 'Uncertain / General INCI');

              return (
                <div
                  key={idx}
                  className="p-4 rounded-xl bg-[#F9FAF8] border border-neutral-200/80 hover:border-neutral-300 transition-all shadow-2xs"
                >
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 mb-2">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className={`w-2.5 h-2.5 rounded-full ${badge.dot} shrink-0`} />
                      <h4 className="text-sm font-bold text-neutral-900">
                        {item.name}
                      </h4>
                      {item.eNumber && (
                        <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-neutral-200 text-neutral-700">
                          {item.eNumber}
                        </span>
                      )}

                      {/* Verified vs. Uncertain Data Source Pill Badge */}
                      <span
                        className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold border ${
                          isVerified
                            ? 'bg-emerald-50 text-[#1E8449] border-emerald-200'
                            : 'bg-amber-50 text-amber-800 border-amber-200'
                        }`}
                        title={isVerified ? 'Data verified against official panel standards' : 'Unverified against official testing monograph'}
                      >
                        {isVerified ? (
                          <ShieldCheck className="w-3 h-3 text-[#27AE60]" />
                        ) : (
                          <HelpCircle className="w-3 h-3 text-amber-600" />
                        )}
                        <span>{sourceLabel}</span>
                      </span>
                    </div>

                    <div className="flex items-center gap-2 self-start sm:self-auto">
                      {item.category && (
                        <span className="text-[11px] text-neutral-500 font-medium">
                          {item.category}
                        </span>
                      )}
                      <span
                        className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-bold border ${badge.bg}`}
                      >
                        <Icon className="w-3 h-3" />
                        {badge.label}
                      </span>
                    </div>
                  </div>

                  <p className="text-xs text-neutral-700 leading-relaxed">
                    {item.reason}
                  </p>

                  {(item.scientificDetails || item.regulatoryStatus) && (
                    <div className="mt-2.5 pt-2 border-t border-neutral-200/60 grid grid-cols-1 sm:grid-cols-2 gap-2 text-[11px]">
                      {item.scientificDetails && (
                        <div className="text-neutral-500">
                          <strong className="text-neutral-700">Scientific Impact: </strong>
                          {item.scientificDetails}
                        </div>
                      )}
                      {item.regulatoryStatus && (
                        <div className="text-neutral-500">
                          <strong className="text-neutral-700">Regulatory Status: </strong>
                          {item.regulatoryStatus}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Positives & Negatives Summary */}
      {(positivePoints.length > 0 || negativePoints.length > 0) && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
          {/* Positives */}
          {positivePoints.length > 0 && (
            <div className="p-4 rounded-xl bg-emerald-50/50 border border-emerald-100">
              <h4 className="text-xs font-bold uppercase tracking-wider text-[#1E8449] mb-2.5 flex items-center gap-1.5">
                <CheckCircle2 className="w-3.5 h-3.5 text-[#27AE60]" />
                Positive Highlights ({positivePoints.length})
              </h4>
              <ul className="space-y-1.5">
                {positivePoints.map((point, i) => (
                  <li key={i} className="text-xs text-neutral-700 flex items-start gap-2">
                    <span className="text-[#27AE60] font-bold leading-none mt-0.5">✓</span>
                    <span>{point}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Negatives */}
          {negativePoints.length > 0 && (
            <div className="p-4 rounded-xl bg-rose-50/50 border border-rose-100">
              <h4 className="text-xs font-bold uppercase tracking-wider text-rose-700 mb-2.5 flex items-center gap-1.5">
                <AlertTriangle className="w-3.5 h-3.5 text-[#E74C3C]" />
                Risks &amp; Drawbacks ({negativePoints.length})
              </h4>
              <ul className="space-y-1.5">
                {negativePoints.map((point, i) => (
                  <li key={i} className="text-xs text-neutral-700 flex items-start gap-2">
                    <span className="text-[#E74C3C] font-bold leading-none mt-0.5">✕</span>
                    <span>{point}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default FlaggedIngredientsList;

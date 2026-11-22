import React from 'react';
import { type AlternativeProduct, RATING_COLORS } from '../types/api';
import { Sparkles, ArrowRight, Check } from 'lucide-react';

interface AlternativeProductsSectionProps {
  alternatives: AlternativeProduct[];
  category?: 'food' | 'cosmetic';
}

export const AlternativeProductsSection: React.FC<AlternativeProductsSectionProps> = ({
  alternatives,
  category = 'food',
}) => {
  if (!alternatives || alternatives.length === 0) {
    return null;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-sm font-bold text-neutral-900 tracking-tight flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-[#27AE60]" />
            <span>Healthier &amp; Cleaner Alternatives</span>
          </h3>
          <p className="text-xs text-neutral-500 mt-0.5">
            Better evaluated {category === 'food' ? 'nutritional' : 'toxicological'} alternatives
            with transparent packaging.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {alternatives.map((alt) => {
          const scoreColor = RATING_COLORS[alt.ratingTier] || '#27AE60';

          return (
            <div
              key={alt.id}
              className="group p-4 rounded-2xl bg-[#F9FAF8] border border-neutral-200/80 hover:border-emerald-300 hover:shadow-md transition-all flex flex-col justify-between"
            >
              <div>
                <div className="flex items-start justify-between gap-3 mb-3">
                  <div className="flex items-center gap-3">
                    {alt.imageUrl && (
                      <img
                        src={alt.imageUrl}
                        alt={alt.name}
                        className="w-14 h-14 object-cover rounded-xl border border-neutral-200 shrink-0"
                      />
                    )}
                    <div>
                      <span className="text-[11px] font-bold uppercase tracking-wider text-neutral-400">
                        {alt.brand}
                      </span>
                      <h4 className="text-sm font-bold text-neutral-900 leading-snug group-hover:text-[#1E8449] transition-colors">
                        {alt.name}
                      </h4>
                      {(alt.mrp || alt.netQuantity) && (
                        <div className="flex items-center gap-2 text-xs text-neutral-500 mt-0.5">
                          {alt.mrp && <span className="font-semibold text-neutral-800">{alt.mrp}</span>}
                          {alt.mrp && alt.netQuantity && <span>•</span>}
                          {alt.netQuantity && <span>{alt.netQuantity}</span>}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Yuka-style Score Pill */}
                  <div
                    className="flex flex-col items-center justify-center px-2.5 py-1.5 rounded-xl border shrink-0 text-white font-black text-xs shadow-2xs"
                    style={{
                      backgroundColor: scoreColor,
                      borderColor: scoreColor,
                    }}
                  >
                    <span>{alt.score}</span>
                    <span className="text-[9px] font-medium opacity-90 leading-none">/ 100</span>
                  </div>
                </div>

                {/* Highlight Reason Badge */}
                <div className="p-2.5 rounded-xl bg-white border border-neutral-200/70 text-xs text-neutral-700 leading-relaxed flex items-start gap-2">
                  <div className="w-4 h-4 rounded-full bg-emerald-100 text-[#1E8449] flex items-center justify-center shrink-0 mt-0.5">
                    <Check className="w-3 h-3 stroke-[3]" />
                  </div>
                  <span className="font-medium">{alt.highlightReason}</span>
                </div>
              </div>

              <div className="mt-4 pt-3 border-t border-neutral-200/60 flex items-center justify-between text-xs">
                <span className="text-emerald-700 font-semibold flex items-center gap-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#27AE60]" />
                  Verified Safe Alternative
                </span>
                <span className="text-[#1E8449] font-bold inline-flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Inspect Pack <ArrowRight className="w-3 h-3" />
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default AlternativeProductsSection;

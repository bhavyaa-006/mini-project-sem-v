import React from 'react';
import type { ProductAnalysis } from '../types/api';
import { mockFoodProduct, mockCosmeticProduct } from '../mockData';
import {
  Sparkles,
  ArrowRight,
  ShieldCheck,
  AlertTriangle,
  Check,
  Milk,
  Sparkle,
} from 'lucide-react';

/**
 * Sprout Mascot SVG - The friendly avocado/botanical leaf mascot for SafeScan
 */
export const SproutMascot: React.FC<{
  size?: number;
  mood?: 'happy' | 'curious' | 'waving' | 'alert';
  holding?: 'tote' | 'magnifier' | 'none';
  className?: string;
}> = ({
  size = 120,
  mood = 'happy',
  holding = 'tote',
  className = '',
}) => {
  return (
    <div
      style={{ width: size, height: size * 1.15 }}
      className={`relative inline-block select-none ${className}`}
    >
      <svg
        viewBox="0 0 100 115"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="w-full h-full overflow-visible"
      >
        <defs>
          <linearGradient id="sproutBodyGrad" x1="20" y1="20" x2="80" y2="95" gradientUnits="userSpaceOnUse">
            <stop stopColor="#2ECC71" />
            <stop offset="1" stopColor="#1E8449" />
          </linearGradient>
          <linearGradient id="toteGrad" x1="10" y1="65" x2="35" y2="95" gradientUnits="userSpaceOnUse">
            <stop stopColor="#FFF2D6" />
            <stop offset="1" stopColor="#FFE0A3" />
          </linearGradient>
          <filter id="softShadow" x="-10%" y="-10%" width="120%" height="130%">
            <feDropShadow dx="0" dy="3" stdDeviation="2.5" floodColor="#0E4522" floodOpacity="0.18" />
          </filter>
        </defs>

        {/* Shadow on ground */}
        <ellipse cx="50" cy="110" rx="26" ry="4" fill="#000" fillOpacity="0.08" />

        {/* Stick Legs */}
        <path d="M42 94V108" stroke="#145A32" strokeWidth="3" strokeLinecap="round" />
        <path d="M58 94V108" stroke="#145A32" strokeWidth="3" strokeLinecap="round" />
        {/* Cute Little Shoes */}
        <ellipse cx="40" cy="108" rx="4.5" ry="2.5" fill="#145A32" />
        <ellipse cx="60" cy="108" rx="4.5" ry="2.5" fill="#145A32" />

        {/* Sprout Head Twin Leaves */}
        <g filter="url(#softShadow)">
          <path
            d="M50 24C49 14 38 10 35 12C35 18 42 22 50 24Z"
            fill="#2ECC71"
            stroke="#196F3D"
            strokeWidth="1.8"
            strokeLinecap="round"
          />
          <path
            d="M50 24C52 14 63 12 66 16C65 22 58 24 50 24Z"
            fill="#27AE60"
            stroke="#196F3D"
            strokeWidth="1.8"
            strokeLinecap="round"
          />
          <path d="M50 26V21" stroke="#196F3D" strokeWidth="2.2" strokeLinecap="round" />
        </g>

        {/* Main Pear / Avocado Body */}
        <path
          d="M50 25C33 25 21 39 21 62C21 82 33 96 50 96C67 96 79 82 79 62C79 39 67 25 50 25Z"
          fill="url(#sproutBodyGrad)"
          stroke="#145A32"
          strokeWidth="3.2"
          filter="url(#softShadow)"
        />

        {/* Inner Light Mint Belly */}
        <path
          d="M50 33C37 33 28 44 28 63C28 79 37 90 50 90C63 90 72 79 72 63C72 44 63 33 50 33Z"
          fill="#EAF9EE"
        />

        {/* Golden Seed / Belly Pit */}
        <circle
          cx="50"
          cy="71"
          r="13"
          fill="#D4AC0D"
          stroke="#B7950B"
          strokeWidth="2"
        />
        <circle cx="46" cy="67" r="3.5" fill="#F9E79F" />

        {/* Facial Expressions based on Mood */}
        {mood === 'alert' ? (
          /* Surprised / Alert Eyes */
          <>
            <circle cx="40" cy="50" r="3.5" fill="#145A32" />
            <circle cx="60" cy="50" r="3.5" fill="#145A32" />
            <ellipse cx="50" cy="56" rx="2.5" ry="3.5" fill="#145A32" />
          </>
        ) : (
          /* Happy Curved Eyes (^ ^) */
          <>
            <path
              d="M37 50C38.5 47 42.5 47 44 50"
              stroke="#145A32"
              strokeWidth="3"
              strokeLinecap="round"
            />
            <path
              d="M56 50C57.5 47 61.5 47 63 50"
              stroke="#145A32"
              strokeWidth="3"
              strokeLinecap="round"
            />
            {/* Happy Smile */}
            <path
              d="M45 54C45 57.5 47.5 59 50 59C52.5 59 55 57.5 55 54"
              stroke="#145A32"
              strokeWidth="2.5"
              strokeLinecap="round"
            />
          </>
        )}

        {/* Rosy Cheeks */}
        <ellipse cx="34" cy="54" rx="4" ry="2.6" fill="#F1948A" opacity="0.85" />
        <ellipse cx="66" cy="54" rx="4" ry="2.6" fill="#F1948A" opacity="0.85" />

        {/* Left Arm: Holding Shopping Tote or Natural Curve */}
        {holding === 'tote' ? (
          <>
            {/* Bent Left Arm */}
            <path
              d="M23 60C17 62 15 70 20 76"
              stroke="#145A32"
              strokeWidth="3"
              strokeLinecap="round"
            />
            {/* Shopping Tote Bag */}
            <g transform="translate(8, 70)">
              {/* Tote Handle */}
              <path
                d="M7 3C7 -2 15 -2 15 3"
                stroke="#C0392B"
                strokeWidth="2"
                strokeLinecap="round"
                fill="none"
              />
              {/* Tote Body */}
              <rect
                x="3"
                y="3"
                width="16"
                height="18"
                rx="3"
                fill="url(#toteGrad)"
                stroke="#D4AC0D"
                strokeWidth="1.5"
              />
              {/* Organic Leaf Stamp on Bag */}
              <path
                d="M11 8C8 10 9 14 12 16C13 14 14 10 11 8Z"
                fill="#27AE60"
              />
              {/* Fresh Carrot sticking out of bag */}
              <path d="M14 0L17 5" stroke="#E67E22" strokeWidth="2.5" strokeLinecap="round" />
              <path d="M16 -2L17 0" stroke="#27AE60" strokeWidth="1.5" strokeLinecap="round" />
            </g>
          </>
        ) : (
          <path
            d="M23 60C15 65 17 76 22 78"
            stroke="#145A32"
            strokeWidth="3"
            strokeLinecap="round"
          />
        )}

        {/* Right Arm: Waving / Magnifying Glass */}
        {mood === 'waving' ? (
          /* High Friendly Wave */
          <>
            <path
              d="M77 60C85 54 89 42 85 36"
              stroke="#145A32"
              strokeWidth="3"
              strokeLinecap="round"
            />
            <circle cx="85" cy="35" r="3" fill="#145A32" />
          </>
        ) : holding === 'magnifier' ? (
          /* Holding Magnifying Glass */
          <>
            <path
              d="M77 62C84 66 85 75 80 80"
              stroke="#145A32"
              strokeWidth="3"
              strokeLinecap="round"
            />
            <g transform="translate(78, 64)">
              <circle cx="10" cy="10" r="7" stroke="#1E8449" strokeWidth="2" fill="#E8F8F5" fillOpacity="0.7" />
              <line x1="5" y1="15" x2="1" y2="21" stroke="#145A32" strokeWidth="3" strokeLinecap="round" />
              {/* Shine reflection on lens */}
              <path d="M7 7C8.5 5.5 11 5.5 12 6" stroke="white" strokeWidth="1.5" strokeLinecap="round" />
            </g>
          </>
        ) : (
          /* Gentle resting arm */
          <path
            d="M77 62C84 67 85 75 80 80"
            stroke="#145A32"
            strokeWidth="3"
            strokeLinecap="round"
          />
        )}
      </svg>
    </div>
  );
};

/**
 * Compact waving Sprout badge used in empty states, loading/OCR steps, and Profile/Login headers.
 */
export const MascotHelper: React.FC<{
  message?: string;
  mood?: 'happy' | 'alert' | 'waving';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}> = ({
  message,
  mood = 'waving',
  size = 'md',
  className = '',
}) => {
  const pixelSize = size === 'sm' ? 44 : size === 'lg' ? 84 : 60;

  return (
    <div className={`inline-flex items-center gap-3 select-none ${className}`}>
      <SproutMascot size={pixelSize} mood={mood} holding="none" />
      {message && (
        <div className="relative px-3.5 py-2 rounded-2xl bg-white border border-emerald-200/90 shadow-2xs text-xs font-semibold text-neutral-800 leading-snug">
          {/* Speech bubble pointer */}
          <div className="absolute -left-1.5 top-1/2 -translate-y-1/2 w-3 h-3 bg-white border-b border-l border-emerald-200/90 transform rotate-45" />
          <span className="relative z-10">{message}</span>
        </div>
      )}
    </div>
  );
};

/**
 * HeroMascotScene:
 * Organic soft pastel mint-blue (#EBF6F5) blob backdrop with floating faint food/cosmetic line icons,
 * a tilted interactive mobile app preview card showing a live product score (92/100 Excellent / 38/100 Poor),
 * and Sprout standing beside it holding a shopping tote.
 */
export const HeroMascotScene: React.FC<{
  activeProduct?: ProductAnalysis;
  onToggleProduct?: () => void;
}> = ({
  activeProduct = mockFoodProduct,
  onToggleProduct,
}) => {
  const isFood = activeProduct.category === 'food';

  return (
    <div className="relative w-full max-w-lg mx-auto lg:max-w-none flex items-center justify-center p-4 sm:p-6 lg:p-8 select-none">
      {/* Soft Pastel Mint-Blue Organic Blob Backdrop (#EBF6F5) */}
      <div className="absolute inset-0 flex items-center justify-center -z-10 overflow-hidden pointer-events-none">
        <svg
          viewBox="0 0 500 500"
          className="w-[125%] h-[125%] text-[#EBF6F5] opacity-90 animate-pulse duration-[8000ms]"
          fill="currentColor"
        >
          <path d="M421.5,310.5Q394,371,335.5,417Q277,463,205.5,441.5Q134,420,83,365.5Q32,311,54.5,237.5Q77,164,124,111Q171,58,245.5,58.5Q320,59,384.5,106.5Q449,154,449,202Q449,250,421.5,310.5Z" />
        </svg>

        {/* Faint Floating Food & Cosmetic Doodles */}
        <div className="absolute top-6 left-10 text-emerald-300/60 rotate-12">
          <Milk className="w-8 h-8" />
        </div>
        <div className="absolute bottom-12 left-16 text-emerald-400/50 -rotate-12">
          <Sparkles className="w-7 h-7" />
        </div>
        <div className="absolute top-12 right-12 text-teal-300/60 rotate-45">
          <Sparkle className="w-6 h-6" />
        </div>
        <div className="absolute bottom-20 right-10 text-emerald-300/50">
          <span className="font-handwritten text-2xl text-emerald-400">clean!</span>
        </div>
      </div>

      <div className="relative flex flex-col sm:flex-row items-center justify-center gap-6 w-full">
        {/* Tilted Interactive Mobile Phone Preview Card */}
        <div
          onClick={onToggleProduct}
          className="cursor-pointer group relative w-64 sm:w-72 bg-white rounded-3xl p-4 sm:p-5 border-2 border-white shadow-[0_16px_36px_rgba(39,174,96,0.14)] transform -rotate-3 transition-all duration-300 hover:rotate-0 hover:scale-[1.02] hover:shadow-[0_20px_45px_rgba(39,174,96,0.2)]"
        >
          {/* Card Header Status */}
          <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-400">
              Live Product Scan
            </span>
            <span className="inline-flex items-center gap-1 text-[10px] font-bold text-[#1E8449] bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-100">
              <span className="w-1.5 h-1.5 rounded-full bg-[#27AE60] animate-ping" />
              Tap to switch
            </span>
          </div>

          {/* Product Thumbnail & Score */}
          <div className="pt-3 flex items-center gap-3">
            <img
              src={activeProduct.imageUrl}
              alt={activeProduct.name}
              className="w-14 h-14 object-cover rounded-2xl border border-neutral-200 shrink-0 shadow-2xs"
            />
            <div className="min-w-0 flex-1 text-left">
              <span className="text-[10px] font-bold uppercase tracking-wider text-[#27AE60]">
                {activeProduct.brand}
              </span>
              <h4 className="text-xs font-bold text-neutral-900 truncate">
                {activeProduct.name}
              </h4>
              <p className="text-[11px] text-neutral-500 capitalize">
                {activeProduct.category} Item
              </p>
            </div>
          </div>

          {/* Yuka-Style Score Gauge Box */}
          <div
            className={`mt-3.5 p-3 rounded-2xl border flex items-center justify-between transition-colors ${
              activeProduct.score >= 75
                ? 'bg-emerald-50/80 border-emerald-200 text-[#1E8449]'
                : 'bg-rose-50/80 border-rose-200 text-rose-800'
            }`}
          >
            <div>
              <span className="text-[10px] font-bold uppercase tracking-wider block opacity-75">
                SafeScan Score
              </span>
              <div className="text-2xl font-black leading-none mt-0.5">
                {activeProduct.score}
                <span className="text-xs font-bold opacity-60">/100</span>
              </div>
            </div>

            <span
              className={`px-3 py-1 rounded-full text-xs font-extrabold text-white shadow-2xs ${
                activeProduct.score >= 75 ? 'bg-[#1E8449]' : 'bg-[#E74C3C]'
              }`}
            >
              {activeProduct.ratingLabel}
            </span>
          </div>

          {/* Floating Feature Pills */}
          <div className="mt-3 flex flex-wrap gap-1.5 pt-1 text-left">
            {isFood ? (
              <>
                <span className="inline-flex items-center gap-1 text-[10px] font-bold bg-[#F9FAF8] text-emerald-800 px-2 py-0.5 rounded-lg border border-emerald-100">
                  <Check className="w-3 h-3 text-[#27AE60]" />
                  Zero Added Cane Sugar
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-bold bg-[#F9FAF8] text-emerald-800 px-2 py-0.5 rounded-lg border border-emerald-100">
                  <ShieldCheck className="w-3 h-3 text-[#1E8449]" />
                  PCR 2011 Verified
                </span>
              </>
            ) : (
              <>
                <span className="inline-flex items-center gap-1 text-[10px] font-bold bg-rose-50 text-rose-700 px-2 py-0.5 rounded-lg border border-rose-200">
                  <AlertTriangle className="w-3 h-3 text-[#E74C3C]" />
                  Harsh SLES Surfactant
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-bold bg-rose-50 text-rose-700 px-2 py-0.5 rounded-lg border border-rose-200">
                  <AlertTriangle className="w-3 h-3 text-[#E74C3C]" />
                  Missing Expiry Date
                </span>
              </>
            )}
          </div>
        </div>

        {/* Sprout Standing Beside Tilted Card */}
        <div className="flex flex-col items-center">
          <SproutMascot size={135} mood="waving" holding="tote" />
          <span className="font-handwritten text-lg text-emerald-800 -mt-1 transform -rotate-6">
            Meet Sprout!
          </span>
        </div>
      </div>
    </div>
  );
};

/**
 * FeatureShowcaseCards:
 * Two alternating editorial feature blocks on the landing/scan view:
 * (1) "Evaluate the quality of your foods" with a product card surrounded by floating pill tags (92/100 Excellent, Zero added sugar, PCR 2011 Verified)
 * (2) "Also, check the quality of your cosmetics!" with floating warning pills (38/100 Poor, 2 Irritants, Missing Expiry)
 * Clicking either block loads that sample scan immediately.
 */
export const FeatureShowcaseCards: React.FC<{
  onSelectProduct: (product: ProductAnalysis) => void;
}> = ({ onSelectProduct }) => {
  return (
    <section className="space-y-12 sm:space-y-16 py-6 font-sans">
      {/* FEATURE 1: FOODS */}
      <div className="bg-gradient-to-br from-[#F9FAF8] via-white to-emerald-50/40 rounded-3xl border border-neutral-200/80 p-6 sm:p-10 shadow-xs">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          {/* Left Text */}
          <div className="lg:col-span-7 space-y-4 text-left">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-[#27AE60]/10 text-[#1E8449] border border-[#27AE60]/20">
              <Sparkles className="w-3.5 h-3.5" />
              Nutritional &amp; Statutory Analysis
            </span>

            <h2 className="text-2xl sm:text-4xl font-extrabold text-neutral-900 tracking-tight leading-snug">
              Evaluate the quality of your{' '}
              <span className="font-handwritten text-[#27AE60] text-4xl sm:text-5xl block sm:inline">
                foods
              </span>
            </h2>

            <p className="text-sm text-neutral-600 leading-relaxed max-w-xl">
              SafeScan decodes nutrition facts, hidden cane sugars, synthetic additives, and
              verifies mandatory Indian Legal Metrology declarations (MRP, Net Quantity, Expiry,
              and FSSAI License) in seconds.
            </p>

            <div className="pt-2">
              <button
                type="button"
                onClick={() => onSelectProduct(mockFoodProduct)}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs sm:text-sm font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all active:scale-[0.98]"
              >
                <span>Inspect Amul Taaza Food Sample</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Right Illustrated Product Card with Floating Pills */}
          <div className="lg:col-span-5 flex justify-center">
            <div
              onClick={() => onSelectProduct(mockFoodProduct)}
              className="cursor-pointer group relative p-5 bg-white rounded-3xl border border-emerald-200 shadow-md hover:shadow-lg transition-all duration-300 max-w-xs w-full text-center"
            >
              {/* Product Photo */}
              <div className="w-36 h-36 mx-auto rounded-2xl overflow-hidden bg-[#F9FAF8] p-2 border border-neutral-200/80 flex items-center justify-center">
                <img
                  src={mockFoodProduct.imageUrl}
                  alt={mockFoodProduct.name}
                  className="w-full h-full object-cover rounded-xl group-hover:scale-105 transition-transform"
                />
              </div>

              <span className="text-[10px] font-bold uppercase tracking-widest text-[#27AE60] mt-3 block">
                {mockFoodProduct.brand}
              </span>
              <h3 className="text-sm font-extrabold text-neutral-900 leading-tight">
                {mockFoodProduct.name}
              </h3>

              {/* Floating Pill Tags */}
              <div className="mt-3.5 flex flex-wrap gap-1.5 justify-center">
                <span className="inline-flex items-center gap-1 text-[11px] font-black bg-[#1E8449] text-white px-2.5 py-1 rounded-full shadow-2xs">
                  92/100 Excellent
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-semibold bg-emerald-50 text-emerald-800 px-2 py-0.5 rounded-lg border border-emerald-200">
                  <Check className="w-3 h-3 text-[#27AE60]" />
                  Zero Added Cane Sugar
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-semibold bg-emerald-50 text-emerald-800 px-2 py-0.5 rounded-lg border border-emerald-200">
                  <ShieldCheck className="w-3 h-3 text-[#1E8449]" />
                  PCR 2011 Verified
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* FEATURE 2: COSMETICS */}
      <div className="bg-gradient-to-br from-[#F9FAF8] via-white to-rose-50/40 rounded-3xl border border-neutral-200/80 p-6 sm:p-10 shadow-xs">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          {/* Left Illustrated Product Card with Floating Warning Pills */}
          <div className="lg:col-span-5 order-2 lg:order-1 flex justify-center">
            <div
              onClick={() => onSelectProduct(mockCosmeticProduct)}
              className="cursor-pointer group relative p-5 bg-white rounded-3xl border border-rose-200 shadow-md hover:shadow-lg transition-all duration-300 max-w-xs w-full text-center"
            >
              {/* Product Photo */}
              <div className="w-36 h-36 mx-auto rounded-2xl overflow-hidden bg-[#F9FAF8] p-2 border border-neutral-200/80 flex items-center justify-center">
                <img
                  src={mockCosmeticProduct.imageUrl}
                  alt={mockCosmeticProduct.name}
                  className="w-full h-full object-cover rounded-xl group-hover:scale-105 transition-transform"
                />
              </div>

              <span className="text-[10px] font-bold uppercase tracking-widest text-[#E74C3C] mt-3 block">
                {mockCosmeticProduct.brand}
              </span>
              <h3 className="text-sm font-extrabold text-neutral-900 leading-tight">
                {mockCosmeticProduct.name}
              </h3>

              {/* Floating Warning Pill Tags */}
              <div className="mt-3.5 flex flex-wrap gap-1.5 justify-center">
                <span className="inline-flex items-center gap-1 text-[11px] font-black bg-[#E74C3C] text-white px-2.5 py-1 rounded-full shadow-2xs">
                  38/100 Poor / Risky
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-semibold bg-rose-50 text-rose-800 px-2 py-0.5 rounded-lg border border-rose-200">
                  <AlertTriangle className="w-3 h-3 text-[#E74C3C]" />
                  2 High-Risk Irritants
                </span>
                <span className="inline-flex items-center gap-1 text-[10px] font-semibold bg-rose-50 text-rose-800 px-2 py-0.5 rounded-lg border border-rose-200">
                  <AlertTriangle className="w-3 h-3 text-[#E74C3C]" />
                  Missing Mandatory Expiry
                </span>
              </div>
            </div>
          </div>

          {/* Right Text */}
          <div className="lg:col-span-7 order-1 lg:order-2 space-y-4 text-left">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-rose-50 text-rose-700 border border-rose-200">
              <AlertTriangle className="w-3.5 h-3.5 text-[#E74C3C]" />
              Toxicological Risk Matrix
            </span>

            <h2 className="text-2xl sm:text-4xl font-extrabold text-neutral-900 tracking-tight leading-snug">
              Also, check the quality of your{' '}
              <span className="font-handwritten text-[#E74C3C] text-4xl sm:text-5xl block sm:inline">
                cosmetics!
              </span>
            </h2>

            <p className="text-sm text-neutral-600 leading-relaxed max-w-xl">
              Cross-reference personal care ingredients against international monographs (CIR,
              EU SCCS, BIS). Detect endocrine disruptors, skin-barrier stripping sulfates, and
              unlawful packaging missing required batch or expiry numbers.
            </p>

            <div className="pt-2">
              <button
                type="button"
                onClick={() => onSelectProduct(mockCosmeticProduct)}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs sm:text-sm font-bold bg-[#E74C3C] hover:bg-[#c0392b] text-white shadow-sm transition-all active:scale-[0.98]"
              >
                <span>Inspect Shampoo Hazard Report</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

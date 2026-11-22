import React from 'react';

interface LeafShieldLogoProps {
  className?: string;
  size?: number;
  showText?: boolean;
}

export const LeafShieldLogo: React.FC<LeafShieldLogoProps> = ({
  className = '',
  size = 40,
  showText = true,
}) => {
  return (
    <div className={`flex items-center gap-3 select-none ${className}`}>
      {/* Modern Yuka-Inspired Squircle Brand Mark */}
      <div
        className="relative flex items-center justify-center shrink-0 rounded-[13px] bg-gradient-to-br from-[#27AE60] to-[#1E8449] text-white shadow-[0_2px_10px_rgba(39,174,96,0.28)] ring-1 ring-emerald-300/40 transition-transform duration-200 hover:scale-105"
        style={{ width: size, height: size }}
      >
        <svg
          viewBox="0 0 32 32"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-full p-1.5 drop-shadow-[0_1px_2px_rgba(0,0,0,0.15)]"
        >
          {/* Subtle Scanning Grid / Barcode Accent Lines */}
          <line
            x1="6.5"
            y1="19.5"
            x2="6.5"
            y2="24.5"
            stroke="white"
            strokeWidth="1.2"
            strokeLinecap="round"
            opacity="0.45"
          />
          <line
            x1="9"
            y1="18"
            x2="9"
            y2="25"
            stroke="white"
            strokeWidth="1.6"
            strokeLinecap="round"
            opacity="0.65"
          />
          <line
            x1="11.5"
            y1="20"
            x2="11.5"
            y2="24.5"
            stroke="white"
            strokeWidth="1.2"
            strokeLinecap="round"
            opacity="0.45"
          />

          {/* Crisp Minimalist Botanical Leaf */}
          <path
            d="M8.5 23.5C7.5 17 10 10.5 16 6.5C19 4.5 23 4 25.5 4.5C25 7 24 11 21.5 14C17 19.5 13 23 8.5 23.5Z"
            fill="white"
            fillOpacity="0.95"
          />

          {/* Elegant Central Leaf Vein */}
          <path
            d="M10 22C12.5 16.5 16.5 11.5 24.5 5.5"
            stroke="#1E8449"
            strokeWidth="1.3"
            strokeLinecap="round"
          />

          {/* Dynamic Verification / Scan Checkmark Accent */}
          <path
            d="M14.5 21L18 24.5L26 16.5"
            stroke="white"
            strokeWidth="2.4"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>

      {showText && (
        <div className="flex flex-col text-left leading-none font-sans">
          <div className="flex items-center gap-1.5">
            <span className="text-[17px] sm:text-[18px] font-black tracking-[-0.03em] text-neutral-900">
              Safe<span className="text-[#27AE60]">Scan</span>
            </span>
            <span className="inline-flex items-center rounded-md bg-[#27AE60]/10 px-1.5 py-0.5 text-[9px] font-bold text-[#1E8449] border border-[#27AE60]/20 tracking-wide uppercase">
              AI
            </span>
          </div>
          <span className="text-[10px] font-semibold tracking-[0.14em] uppercase text-neutral-400 mt-1">
            PackCheck AI
          </span>
        </div>
      )}
    </div>
  );
};

export default LeafShieldLogo;

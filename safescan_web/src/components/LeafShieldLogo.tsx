import React from 'react';

interface LeafShieldLogoProps {
  className?: string;
  size?: number;
  showText?: boolean;
}

export const LeafShieldLogo: React.FC<LeafShieldLogoProps> = ({
  className = '',
  size = 42,
  showText = true,
}) => {
  return (
    <div className={`flex items-center gap-2.5 select-none ${className}`}>
      {/* Cute Mini-Mascot Sprout / Avocado Icon */}
      <div
        className="relative flex items-center justify-center shrink-0 transition-transform duration-300 hover:rotate-6 hover:scale-105"
        style={{ width: size, height: size }}
      >
        <svg
          viewBox="0 0 48 48"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-full drop-shadow-sm overflow-visible"
        >
          {/* Top Sprout Leaves */}
          <path
            d="M24 10C24 5 19 3 17 4C17 7 20 9 24 10Z"
            fill="#2ECC71"
            stroke="#1E8449"
            strokeWidth="1.2"
            strokeLinecap="round"
          />
          <path
            d="M24 10C25 5 30 4 32 6C31 9 28 10 24 10Z"
            fill="#27AE60"
            stroke="#1E8449"
            strokeWidth="1.2"
            strokeLinecap="round"
          />
          <path
            d="M24 13V9"
            stroke="#1E8449"
            strokeWidth="1.5"
            strokeLinecap="round"
          />

          {/* Avocado / Sprout Outer Body (Tilted Pear) */}
          <path
            d="M24 11C16.5 11 11 17 11 27C11 36 16.5 42 24 42C31.5 42 37 36 37 27C37 17 31.5 11 24 11Z"
            fill="url(#sproutGradient)"
            stroke="#196F3D"
            strokeWidth="2"
          />

          {/* Inner Light Mint / Cream Belly */}
          <path
            d="M24 15C18.5 15 14.5 19.5 14.5 28C14.5 35 18.5 39 24 39C29.5 39 33.5 35 33.5 28C33.5 19.5 29.5 15 24 15Z"
            fill="#E8F8F0"
          />

          {/* Center Nut / Warm Golden Seed */}
          <circle
            cx="24"
            cy="31.5"
            r="6"
            fill="#D4AC0D"
            stroke="#B7950B"
            strokeWidth="1"
          />
          <circle cx="22.5" cy="30" r="1.5" fill="#F9E79F" />

          {/* Happy Curved Mascot Eyes */}
          <path
            d="M19 22C19.5 20.8 21 20.8 21.5 22"
            stroke="#145A32"
            strokeWidth="1.8"
            strokeLinecap="round"
          />
          <path
            d="M26.5 22C27 20.8 28.5 20.8 29 22"
            stroke="#145A32"
            strokeWidth="1.8"
            strokeLinecap="round"
          />

          {/* Cute Rosy Cheeks */}
          <ellipse cx="17.5" cy="24.5" rx="1.8" ry="1.2" fill="#F1948A" opacity="0.8" />
          <ellipse cx="30.5" cy="24.5" rx="1.8" ry="1.2" fill="#F1948A" opacity="0.8" />

          {/* Happy Open Smile */}
          <path
            d="M22 24.5C22 25.8 23 26.5 24 26.5C25 26.5 26 25.8 26 24.5"
            stroke="#145A32"
            strokeWidth="1.4"
            strokeLinecap="round"
          />

          {/* Tiny Scan Checkmark Accent Pin */}
          <circle cx="34" cy="15" r="4.5" fill="#27AE60" stroke="white" strokeWidth="1.2" />
          <path
            d="M32.5 15L33.8 16.3L35.8 14"
            stroke="white"
            strokeWidth="1.2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* Gradient Definition */}
          <defs>
            <linearGradient id="sproutGradient" x1="12" y1="12" x2="36" y2="42" gradientUnits="userSpaceOnUse">
              <stop stopColor="#2ECC71" />
              <stop offset="1" stopColor="#1E8449" />
            </linearGradient>
          </defs>
        </svg>
      </div>

      {showText && (
        <div className="flex flex-col text-left leading-none font-sans">
          <div className="flex items-center gap-1.5">
            <span className="text-[19px] sm:text-[21px] font-black tracking-[-0.03em] text-neutral-900">
              Safe<span className="text-[#27AE60]">Scan</span>
            </span>
            <span className="inline-flex items-center rounded-md bg-[#27AE60]/10 px-1.5 py-0.5 text-[9px] font-extrabold text-[#1E8449] border border-[#27AE60]/20 tracking-wider uppercase">
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

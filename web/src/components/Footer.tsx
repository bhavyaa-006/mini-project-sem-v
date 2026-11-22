import React from 'react';
import { LeafShieldLogo } from './LeafShieldLogo';
import { AlertCircle, Shield, CheckCircle2, FileText } from 'lucide-react';
import { Link } from 'react-router-dom';

export const Footer: React.FC = () => {
  return (
    <footer className="mt-auto w-full bg-[#F9FAF8] border-t border-neutral-200/80 text-neutral-600 font-sans overflow-hidden">
      {/* Upper Content Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-12 pb-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start mb-10">
          {/* Brand Info & Mission */}
          <div className="lg:col-span-4 space-y-3.5">
            <LeafShieldLogo size={42} />
            <p className="text-xs leading-relaxed text-neutral-500 max-w-sm">
              Empowering Indian consumers with transparent, independent product intelligence.
              Evaluate food nutrition, cosmetic toxicity, and statutory Legal Metrology
              compliance in a single scan.
            </p>

            <div className="flex flex-wrap gap-2 pt-1">
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-white text-emerald-800 border border-emerald-100 shadow-2xs">
                <CheckCircle2 className="w-3 h-3 text-[#27AE60]" />
                FSSAI Standards
              </span>
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-white text-emerald-800 border border-emerald-100 shadow-2xs">
                <Shield className="w-3 h-3 text-[#1E8449]" />
                Legal Metrology PCR 2011
              </span>
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-white text-neutral-700 border border-neutral-200 shadow-2xs">
                <FileText className="w-3 h-3 text-neutral-500" />
                Yuka Nutri/Tox Model
              </span>
            </div>
          </div>

          {/* Clean 4-Column Links: Project, Scanner, Compliance, Platform */}
          <div className="lg:col-span-8 grid grid-cols-2 sm:grid-cols-4 gap-6 text-xs">
            {/* Column 1: Project */}
            <div className="space-y-2.5">
              <h4 className="font-bold text-neutral-900 uppercase text-[11px] tracking-wider">
                Project
              </h4>
              <ul className="space-y-2 text-neutral-500">
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    About SafeScan
                  </Link>
                </li>
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    Yuka-Inspired Model
                  </Link>
                </li>
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    100-Point Scoring
                  </Link>
                </li>
                <li>
                  <Link to="/history" className="hover:text-[#1E8449] transition-colors">
                    Public Scan Feeds
                  </Link>
                </li>
              </ul>
            </div>

            {/* Column 2: Scanner */}
            <div className="space-y-2.5">
              <h4 className="font-bold text-neutral-900 uppercase text-[11px] tracking-wider">
                Scanner
              </h4>
              <ul className="space-y-2 text-neutral-500">
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    Barcode EAN-13
                  </Link>
                </li>
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    Label Photo OCR
                  </Link>
                </li>
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    Nutri-Score Food
                  </Link>
                </li>
                <li>
                  <Link to="/" className="hover:text-[#1E8449] transition-colors">
                    Cosmetic Safety
                  </Link>
                </li>
              </ul>
            </div>

            {/* Column 3: Compliance */}
            <div className="space-y-2.5">
              <h4 className="font-bold text-neutral-900 uppercase text-[11px] tracking-wider">
                Compliance
              </h4>
              <ul className="space-y-2 text-neutral-500">
                <li>
                  <Link to="/admin" className="hover:text-[#1E8449] transition-colors">
                    Legal Metrology Act
                  </Link>
                </li>
                <li>
                  <Link to="/admin" className="hover:text-[#1E8449] transition-colors">
                    PCR 2011 Rule 6
                  </Link>
                </li>
                <li>
                  <Link to="/admin" className="hover:text-[#1E8449] transition-colors">
                    FSSAI Packaging
                  </Link>
                </li>
                <li>
                  <Link to="/admin" className="hover:text-[#1E8449] transition-colors">
                    Hazard Catalog
                  </Link>
                </li>
              </ul>
            </div>

            {/* Column 4: Platform */}
            <div className="space-y-2.5">
              <h4 className="font-bold text-neutral-900 uppercase text-[11px] tracking-wider">
                Platform
              </h4>
              <ul className="space-y-2 text-neutral-500">
                <li>
                  <Link to="/profile" className="hover:text-[#1E8449] transition-colors">
                    Health Profile
                  </Link>
                </li>
                <li>
                  <Link to="/profile" className="hover:text-[#1E8449] transition-colors">
                    Household Allergens
                  </Link>
                </li>
                <li>
                  <Link to="/login" className="hover:text-[#1E8449] transition-colors">
                    Consumer Login
                  </Link>
                </li>
                <li>
                  <Link to="/admin" className="hover:text-[#1E8449] transition-colors">
                    Admin Portal
                  </Link>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Informational Guidance Notice & Medical/Legal Disclaimer */}
        <div className="rounded-2xl bg-amber-50/70 border border-amber-200/60 p-4 text-xs text-amber-900/90 leading-relaxed shadow-xs mb-8">
          <div className="flex items-start gap-2.5">
            <AlertCircle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
            <div>
              <h5 className="font-bold text-amber-950 text-xs mb-1">
                Informational Guidance Notice &amp; Medical / Statutory Disclaimer
              </h5>
              <p className="text-[11px] leading-relaxed text-amber-900/80">
                SafeScan &amp; PackCheck AI scores, health evaluations, and package assessments are
                provided strictly as <strong>informational guidance only</strong> and do not
                constitute certified medical advice, clinical diagnosis, dermatological prescription,
                or statutory legal enforcement certification. Rating criteria are derived from
                public nutritional studies, scientific panels (CIR, SCCS, WHO), and Indian regulatory
                frameworks (FSSAI regulations, Legal Metrology Act 2009 &amp; Packaged Commodities Rules 2011).
                Always consult qualified healthcare professionals for medical decisions and verify
                physical packaging for official statutory compliance.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* FULL-WIDTH SCENIC ILLUSTRATED ROLLING-HILL SVG BOTTOM BORDER WITH SPROUT WAVING */}
      <div className="relative w-full overflow-hidden leading-none select-none">
        <svg
          viewBox="0 0 1440 220"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-full h-auto block -mb-1"
          preserveAspectRatio="none"
        >
          {/* Sky Gradient transition */}
          <rect width="1440" height="220" fill="#F9FAF8" />

          {/* Layer 1: Background Forest-Green Rolling Hill (#1E8449) */}
          <path
            d="M0 130C240 70 480 160 760 110C1040 60 1260 135 1440 100V220H0V130Z"
            fill="#1E8449"
          />

          {/* Minimalist Geometric Trees on Back Hill */}
          {/* Tree 1 */}
          <polygon points="180,95 195,125 165,125" fill="#145A32" />
          <rect x="178" y="125" width="4" height="8" fill="#0E3D22" />
          {/* Tree 2 */}
          <polygon points="215,85 232,120 198,120" fill="#196F3D" />
          <rect x="213" y="120" width="4" height="8" fill="#0E3D22" />
          {/* Tree 3 */}
          <polygon points="560,115 575,145 545,145" fill="#145A32" />
          <rect x="558" y="145" width="4" height="8" fill="#0E3D22" />
          {/* Tree 4 */}
          <circle cx="880" cy="88" r="16" fill="#145A32" />
          <rect x="878" y="104" width="4" height="12" fill="#0E3D22" />

          {/* Layer 2: Foreground Vibrant Leaf-Green Rolling Hill (#27AE60) */}
          <path
            d="M0 160C320 105 620 195 940 135C1180 90 1360 130 1440 125V220H0V160Z"
            fill="#27AE60"
          />

          {/* Winding Cream / Soft-Yellow Path (#FFF3CD) */}
          <path
            d="M480 220C540 180 620 185 680 155C720 135 770 142 820 125L845 127C795 145 745 140 705 160C645 190 565 195 500 220H480Z"
            fill="#FFF3CD"
            opacity="0.9"
          />

          {/* Minimalist Geometric Trees on Foreground Hill */}
          {/* Tree 5 */}
          <circle cx="340" cy="130" r="14" fill="#1E8449" />
          <rect x="338" y="144" width="4" height="10" fill="#145A32" />
          {/* Tree 6 */}
          <polygon points="680,140 695,165 665,165" fill="#1E8449" />
          <rect x="678" y="165" width="4" height="6" fill="#145A32" />
          {/* Tree 7 */}
          <circle cx="1060" cy="115" r="18" fill="#1E8449" />
          <rect x="1058" y="133" width="4" height="10" fill="#145A32" />

          {/* SPROUT WAVING HAPPILY ON THE RIGHT HILL (x: ~1240, y: ~75) */}
          <g transform="translate(1220, 68) scale(0.9)">
            {/* Sprout Shadow */}
            <ellipse cx="50" cy="100" rx="22" ry="3.5" fill="#145A32" fillOpacity="0.5" />
            {/* Legs */}
            <path d="M43 85V98" stroke="#145A32" strokeWidth="2.5" strokeLinecap="round" />
            <path d="M57 85V98" stroke="#145A32" strokeWidth="2.5" strokeLinecap="round" />
            <ellipse cx="41" cy="98" rx="4" ry="2" fill="#145A32" />
            <ellipse cx="59" cy="98" rx="4" ry="2" fill="#145A32" />

            {/* Twin Sprout Leaves */}
            <path d="M50 20C49 10 38 6 35 8C35 14 42 18 50 20Z" fill="#2ECC71" stroke="#145A32" strokeWidth="1.5" />
            <path d="M50 20C52 10 63 8 66 12C65 18 58 20 50 20Z" fill="#A9DFBF" stroke="#145A32" strokeWidth="1.5" />
            <path d="M50 22V17" stroke="#145A32" strokeWidth="2" strokeLinecap="round" />

            {/* Body */}
            <path
              d="M50 20C34 20 23 33 23 55C23 74 34 87 50 87C66 87 77 74 77 55C77 33 66 20 50 20Z"
              fill="#E8F8F0"
              stroke="#145A32"
              strokeWidth="2.8"
            />
            {/* Golden Belly Pit */}
            <circle cx="50" cy="62" r="11" fill="#D4AC0D" stroke="#B7950B" strokeWidth="1.5" />
            <circle cx="47" cy="59" r="3" fill="#F9E79F" />

            {/* Happy Curved Eyes */}
            <path d="M38 43C39.5 40 43 40 44.5 43" stroke="#145A32" strokeWidth="2.5" strokeLinecap="round" />
            <path d="M55.5 43C57 40 60.5 40 62 43" stroke="#145A32" strokeWidth="2.5" strokeLinecap="round" />
            {/* Smile */}
            <path d="M46 47C46 50 48 51.5 50 51.5C52 51.5 54 50 54 47" stroke="#145A32" strokeWidth="2" strokeLinecap="round" />
            {/* Cheeks */}
            <ellipse cx="36" cy="46" rx="3.5" ry="2" fill="#F1948A" opacity="0.8" />
            <ellipse cx="64" cy="46" rx="3.5" ry="2" fill="#F1948A" opacity="0.8" />

            {/* Left Hand: Resting */}
            <path d="M25 54C18 58 20 68 25 70" stroke="#145A32" strokeWidth="2.5" strokeLinecap="round" />
            {/* Right Hand: High Friendly Wave */}
            <path d="M75 54C83 48 88 36 84 30" stroke="#145A32" strokeWidth="2.8" strokeLinecap="round" />
            <circle cx="84" cy="29" r="2.5" fill="#145A32" />
          </g>

          {/* Playful Floating Message Pill near Sprout */}
          <g transform="translate(1120, 30)">
            <rect x="0" y="0" width="130" height="32" rx="16" fill="white" stroke="#27AE60" strokeWidth="1.5" />
            <polygon points="120,28 128,40 110,31" fill="white" />
            <text x="14" y="20" fill="#145A32" fontSize="13" fontWeight="bold" fontFamily="'Caveat', cursive">
              Eat clean, live well! 🌿
            </text>
          </g>
        </svg>

        {/* Bottom Bar: Copyright & Regulatory Compliance */}
        <div className="bg-[#27AE60] text-emerald-950/80 px-4 py-4 text-xs font-semibold text-center border-t border-emerald-500/30">
          <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-3 text-white/90">
            <p>© {new Date().getFullYear()} SafeScan &amp; PackCheck AI. Independent public health &amp; statutory compliance initiative.</p>
            <div className="flex items-center gap-4 text-emerald-100 text-[11px]">
              <span className="hover:text-white cursor-pointer transition-colors">
                FSSAI Standards 2011
              </span>
              <span>•</span>
              <span className="hover:text-white cursor-pointer transition-colors">
                Legal Metrology PCR
              </span>
              <span>•</span>
              <span className="hover:text-white cursor-pointer transition-colors">
                Privacy &amp; Data Ethics
              </span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;

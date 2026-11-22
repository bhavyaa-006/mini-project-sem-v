import React from 'react';
import { LeafShieldLogo } from './LeafShieldLogo';
import { AlertCircle, Shield, FileText, CheckCircle2 } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer className="mt-auto w-full bg-[#F9FAF8] border-t border-neutral-200/70 text-neutral-600 font-sans">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 lg:py-12">
        {/* Top Section: Brand + Mission */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-start mb-8">
          <div className="md:col-span-5 space-y-3">
            <LeafShieldLogo size={34} />
            <p className="text-xs leading-relaxed text-neutral-500 max-w-sm">
              Empowering Indian consumers with instant, transparent product intelligence.
              Decode complex food ingredient labels, cosmetic toxicity risks, and mandatory
              Legal Metrology compliance in seconds.
            </p>

            <div className="flex flex-wrap gap-2 pt-1">
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-white text-emerald-800 border border-emerald-100 shadow-2xs">
                <CheckCircle2 className="w-3 h-3 text-[#27AE60]" />
                FSSAI Standards
              </span>
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-white text-emerald-800 border border-emerald-100 shadow-2xs">
                <Shield className="w-3 h-3 text-[#1E8449]" />
                Legal Metrology PCR 2011
              </span>
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-medium bg-white text-neutral-700 border border-neutral-200/80 shadow-2xs">
                <FileText className="w-3 h-3 text-neutral-500" />
                Yuka Nutri/Tox Methodology
              </span>
            </div>
          </div>

          <div className="md:col-span-7 space-y-4">
            {/* Subtle Mandatory Disclaimer */}
            <div className="rounded-2xl bg-amber-50/70 border border-amber-200/60 p-4 text-xs text-amber-900/90 leading-relaxed shadow-xs">
              <div className="flex items-start gap-2.5">
                <AlertCircle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
                <div>
                  <h4 className="font-semibold text-amber-950 text-xs mb-1">
                    Informational Guidance Notice & Medical/Legal Disclaimer
                  </h4>
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
        </div>

        {/* Bottom Bar: Copyright & Regulatory Links */}
        <div className="pt-6 border-t border-neutral-200/60 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-neutral-400">
          <p>© {new Date().getFullYear()} SafeScan &amp; PackCheck AI. Independent consumer guidance initiative.</p>
          <div className="flex items-center space-x-5 text-neutral-500">
            <span className="hover:text-neutral-800 cursor-pointer transition-colors">
              Methodology &amp; Scoring Tiers
            </span>
            <span className="hover:text-neutral-800 cursor-pointer transition-colors">
              FSSAI Guidelines
            </span>
            <span className="hover:text-neutral-800 cursor-pointer transition-colors">
              Packaged Commodities Rules
            </span>
            <span className="hover:text-neutral-800 cursor-pointer transition-colors">
              Privacy &amp; Data Ethics
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;

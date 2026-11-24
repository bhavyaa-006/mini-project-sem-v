import React from 'react';
import type { LegalMetrology } from '../types/api';
import {
  ShieldCheck,
  AlertTriangle,
  IndianRupee,
  Scale,
  Calendar,
  Building2,
  PhoneCall,
  FileCheck2,
} from 'lucide-react';

interface LegalMetrologyCardProps {
  legalMetrology: LegalMetrology;
  category?: 'food' | 'cosmetic';
}

export const LegalMetrologyCard: React.FC<LegalMetrologyCardProps> = ({
  legalMetrology,
  category = 'food',
}) => {
  const isCompliant = legalMetrology.compliant;

  return (
    <div
      className={`rounded-2xl border transition-all overflow-hidden ${
        isCompliant
          ? 'bg-[#F9FAF8] border-emerald-200/80 shadow-xs'
          : 'bg-rose-50/40 border-rose-200/90 shadow-xs'
      }`}
    >
      {/* Header Banner */}
      <div
        className={`px-5 py-4 border-b flex items-center justify-between ${
          isCompliant
            ? 'bg-emerald-50/70 border-emerald-100 text-emerald-900'
            : 'bg-rose-100/60 border-rose-200 text-rose-950'
        }`}
      >
        <div className="flex items-center gap-2.5">
          {isCompliant ? (
            <div className="w-8 h-8 rounded-xl bg-[#27AE60] text-white flex items-center justify-center shadow-xs">
              <ShieldCheck className="w-5 h-5" />
            </div>
          ) : (
            <div className="w-8 h-8 rounded-xl bg-[#E74C3C] text-white flex items-center justify-center shadow-xs">
              <AlertTriangle className="w-5 h-5" />
            </div>
          )}

          <div>
            <h3 className="text-sm font-bold tracking-tight">
              Legal Metrology &amp; PackCheck Inspection
            </h3>
            <p className="text-[11px] opacity-80 font-medium">
              Packaged Commodities Rules (PCR) 2011 &amp; {category === 'food' ? 'FSSAI' : 'BIS/CDSCO'}
            </p>
          </div>
        </div>

        <span
          className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold tracking-wide ${
            isCompliant
              ? 'bg-[#27AE60] text-white shadow-2xs'
              : 'bg-[#E74C3C] text-white shadow-2xs'
          }`}
        >
          {isCompliant ? '100% Compliant' : 'Non-Compliant'}
        </span>
      </div>

      <div className="p-5 space-y-4">
        {/* Missing Fields Warning Banner if Non-Compliant */}
        {!isCompliant && legalMetrology.missingFields.length > 0 && (
          <div className="p-3.5 rounded-xl bg-rose-100/80 border border-rose-300/80 text-rose-900 text-xs">
            <div className="flex items-start gap-2">
              <AlertTriangle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
              <div>
                <span className="font-bold">Missing Mandatory Label Declarations:</span>
                <ul className="list-disc list-inside mt-1 space-y-0.5 text-rose-800">
                  {legalMetrology.missingFields.map((field, idx) => (
                    <li key={idx} className="font-medium">
                      {field}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        )}

        {/* Key Pack Parameters Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {/* MRP */}
          <div className="bg-white p-3 rounded-xl border border-neutral-200/70 shadow-2xs flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-emerald-50 text-[#1E8449] flex items-center justify-center shrink-0">
              <IndianRupee className="w-4 h-4" />
            </div>
            <div>
              <span className="text-[10px] uppercase font-bold text-neutral-400">
                Maximum Retail Price
              </span>
              <p className="text-sm font-bold text-neutral-900">
                {legalMetrology.mrp || 'Not Specified'}
              </p>
            </div>
          </div>

          {/* Net Quantity */}
          <div className="bg-white p-3 rounded-xl border border-neutral-200/70 shadow-2xs flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
              <Scale className="w-4 h-4" />
            </div>
            <div>
              <span className="text-[10px] uppercase font-bold text-neutral-400">
                Net Quantity
              </span>
              <p className="text-sm font-bold text-neutral-900">
                {legalMetrology.netQuantity || 'Missing'}
              </p>
            </div>
          </div>

          {/* Expiry Date */}
          <div
            className={`p-3 rounded-xl border shadow-2xs flex items-center gap-3 ${
              legalMetrology.expiryDate
                ? 'bg-white border-neutral-200/70'
                : 'bg-rose-50/80 border-rose-300'
            }`}
          >
            <div
              className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                legalMetrology.expiryDate
                  ? 'bg-amber-50 text-amber-700'
                  : 'bg-rose-100 text-rose-700'
              }`}
            >
              <Calendar className="w-4 h-4" />
            </div>
            <div>
              <span className="text-[10px] uppercase font-bold text-neutral-400">
                Expiry / Best Before
              </span>
              <p
                className={`text-sm font-bold ${
                  legalMetrology.expiryDate
                    ? 'text-neutral-900'
                    : 'text-rose-700'
                }`}
              >
                {legalMetrology.expiryDate || 'OMITTED (Violation)'}
              </p>
            </div>
          </div>

          {/* Manufacturer Name */}
          <div className="sm:col-span-2 bg-white p-3 rounded-xl border border-neutral-200/70 shadow-2xs flex items-start gap-3">
            <div className="w-8 h-8 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center shrink-0 mt-0.5">
              <Building2 className="w-4 h-4" />
            </div>
            <div className="min-w-0 flex-1">
              <span className="text-[10px] uppercase font-bold text-neutral-400">
                Packaged &amp; Manufactured By
              </span>
              <p className="text-xs font-bold text-neutral-900 truncate">
                {legalMetrology.manufacturerName || 'Unknown Manufacturer'}
              </p>
              {legalMetrology.manufacturerAddress && (
                <p className="text-[11px] text-neutral-500 mt-0.5 line-clamp-1">
                  {legalMetrology.manufacturerAddress}
                </p>
              )}
            </div>
          </div>

          {/* License / Care Details */}
          <div className="bg-white p-3 rounded-xl border border-neutral-200/70 shadow-2xs flex items-start gap-3">
            <div className="w-8 h-8 rounded-lg bg-teal-50 text-teal-600 flex items-center justify-center shrink-0 mt-0.5">
              {legalMetrology.fssaiLicenseNumber ? (
                <FileCheck2 className="w-4 h-4" />
              ) : (
                <PhoneCall className="w-4 h-4" />
              )}
            </div>
            <div className="min-w-0">
              <span className="text-[10px] uppercase font-bold text-neutral-400">
                {legalMetrology.fssaiLicenseNumber
                  ? 'FSSAI License'
                  : 'Consumer Care'}
              </span>
              <p className="text-xs font-bold text-neutral-900 truncate">
                {legalMetrology.fssaiLicenseNumber ||
                  legalMetrology.consumerCareDetails?.split('|')[0] ||
                  'Available'}
              </p>
            </div>
          </div>
        </div>

        {/* Regulatory Auditor Note */}
        {legalMetrology.notes && (
          <div className="p-3 bg-white/80 rounded-xl border border-neutral-200/60 text-[11px] text-neutral-600 leading-relaxed">
            <span className="font-semibold text-neutral-800">Compliance Audit Summary: </span>
            {legalMetrology.notes}
          </div>
        )}
      </div>
    </div>
  );
};

export default LegalMetrologyCard;

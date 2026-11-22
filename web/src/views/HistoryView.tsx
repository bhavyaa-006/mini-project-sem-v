import React, { useState } from 'react';
import { mockScanHistory } from '../mockData';
import { RATING_COLORS, type ScanHistoryItem } from '../types/api';
import { downloadAuditReport } from '../api/client';
import {
  History,
  Search,
  Filter,
  CheckCircle2,
  AlertTriangle,
  ArrowRight,
  Calendar,
  FileDown,
  RefreshCw,
  CheckCircle,
} from 'lucide-react';

interface HistoryViewProps {
  onSelectProduct?: (productId: string) => void;
}

export const HistoryView: React.FC<HistoryViewProps> = ({ onSelectProduct }) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState<'all' | 'food' | 'cosmetic'>('all');
  const [complianceFilter, setComplianceFilter] = useState<'all' | 'compliant' | 'violating'>('all');
  const [downloadingId, setDownloadingId] = useState<string | null>(null);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const filteredHistory = mockScanHistory.filter((item) => {
    const matchesSearch =
      item.productName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.brand.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory =
      categoryFilter === 'all' || item.category === categoryFilter;

    const matchesCompliance =
      complianceFilter === 'all' ||
      (complianceFilter === 'compliant' && item.isCompliant) ||
      (complianceFilter === 'violating' && !item.isCompliant);

    return matchesSearch && matchesCategory && matchesCompliance;
  });

  const handleRowPdfDownload = async (item: ScanHistoryItem) => {
    setDownloadingId(item.id);
    try {
      await downloadAuditReport(item.productId);
      setToastMessage(`Downloaded PDF audit report for "${item.productName}".`);
    } catch {
      setToastMessage('Download failed. Please try again.');
    } finally {
      setDownloadingId(null);
      setTimeout(() => setToastMessage(null), 3000);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8 font-sans">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-[#27AE60]/10 text-[#1E8449] border border-[#27AE60]/20 mb-1.5">
            <History className="w-3.5 h-3.5" />
            <span>Inspection Timeline</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-neutral-900 tracking-tight">
            Scan &amp; Metrology History
          </h1>
          <p className="text-xs sm:text-sm text-neutral-500 mt-1">
            Review and export your previously analyzed consumer packages and statutory compliance reports.
          </p>
        </div>

        <div className="flex items-center gap-2 text-xs font-semibold text-neutral-600 bg-[#F9FAF8] px-3.5 py-2 rounded-xl border border-neutral-200">
          <span>Total Scans Logged:</span>
          <span className="font-bold text-neutral-900 bg-white px-2 py-0.5 rounded-lg border border-neutral-200 shadow-2xs">
            {mockScanHistory.length}
          </span>
        </div>
      </div>

      {toastMessage && (
        <div className="p-3.5 rounded-xl bg-emerald-50 text-[#1E8449] text-xs font-bold flex items-center gap-2 animate-in fade-in border border-emerald-200 shadow-2xs">
          <CheckCircle className="w-4 h-4 text-[#27AE60]" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Filter and Search Bar */}
      <div className="p-4 rounded-2xl bg-white border border-neutral-200/80 shadow-xs space-y-3">
        <div className="flex flex-col md:flex-row gap-3">
          {/* Search Input */}
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search by product name, brand (e.g. Amul, Silk)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 text-xs sm:text-sm rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] focus:border-transparent transition-all"
            />
          </div>

          {/* Category Filter Pills */}
          <div className="flex items-center gap-1.5 bg-[#F9FAF8] p-1 rounded-xl border border-neutral-200/80 shrink-0">
            {(['all', 'food', 'cosmetic'] as const).map((cat) => (
              <button
                key={cat}
                type="button"
                onClick={() => setCategoryFilter(cat)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition-all ${
                  categoryFilter === cat
                    ? 'bg-white text-neutral-900 shadow-2xs'
                    : 'text-neutral-500 hover:text-neutral-900'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          {/* Compliance Filter Pills */}
          <div className="flex items-center gap-1.5 bg-[#F9FAF8] p-1 rounded-xl border border-neutral-200/80 shrink-0">
            {(['all', 'compliant', 'violating'] as const).map((comp) => (
              <button
                key={comp}
                type="button"
                onClick={() => setComplianceFilter(comp)}
                className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition-all ${
                  complianceFilter === comp
                    ? 'bg-white text-neutral-900 shadow-2xs'
                    : 'text-neutral-500 hover:text-neutral-900'
                }`}
              >
                {comp === 'violating' ? 'Non-Compliant' : comp}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* History Items Feed */}
      <div className="space-y-3">
        {filteredHistory.length === 0 ? (
          <div className="p-12 text-center bg-white rounded-3xl border border-neutral-200/80">
            <Filter className="w-8 h-8 text-neutral-300 mx-auto mb-2" />
            <h3 className="text-sm font-bold text-neutral-800">No scanned items match your filter</h3>
            <p className="text-xs text-neutral-500 mt-1">Try clearing filters or search terms.</p>
          </div>
        ) : (
          filteredHistory.map((item: ScanHistoryItem) => {
            const scoreColor = RATING_COLORS[item.ratingTier] || '#27AE60';
            const isDownloading = downloadingId === item.id;

            return (
              <div
                key={item.id}
                className="p-4 sm:p-5 rounded-2xl bg-white border border-neutral-200/80 hover:border-emerald-300 hover:shadow-md transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-4"
              >
                {/* Left: Product Thumbnail & Details */}
                <div className="flex items-center gap-4">
                  {item.thumbnailUrl && (
                    <img
                      src={item.thumbnailUrl}
                      alt={item.productName}
                      className="w-14 h-14 sm:w-16 sm:h-16 object-cover rounded-xl border border-neutral-200 shrink-0"
                    />
                  )}

                  <div>
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-400">
                        {item.brand}
                      </span>
                      <span className="text-neutral-300">•</span>
                      <span className="text-[10px] font-semibold uppercase text-neutral-500">
                        {item.category}
                      </span>
                    </div>

                    <h3 className="text-sm sm:text-base font-bold text-neutral-900 mt-0.5 leading-snug">
                      {item.productName}
                    </h3>

                    <div className="flex flex-wrap items-center gap-2 text-xs text-neutral-500 mt-1">
                      <span className="flex items-center gap-1 text-[11px]">
                        <Calendar className="w-3 h-3 text-neutral-400" />
                        {item.timestamp}
                      </span>

                      <span>•</span>

                      {item.isCompliant ? (
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-[#1E8449]">
                          <CheckCircle2 className="w-3 h-3 text-[#27AE60]" />
                          Compliant Metrology
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-[#E74C3C]">
                          <AlertTriangle className="w-3 h-3 text-[#E74C3C]" />
                          Metrology Violation
                        </span>
                      )}

                      <span>•</span>

                      <span className="text-[11px] text-neutral-500">
                        {item.flaggedCount === 0
                          ? 'Clean formulation'
                          : `${item.flaggedCount} flagged ingredient${item.flaggedCount > 1 ? 's' : ''}`}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Right: Score Pill & Action Buttons (Download PDF + View Report) */}
                <div className="flex flex-wrap items-center justify-between sm:justify-end gap-2.5 self-end sm:self-center w-full sm:w-auto pt-2 sm:pt-0 border-t sm:border-0 border-neutral-100">
                  <div
                    className="flex flex-col items-center justify-center px-3 py-1.5 rounded-xl border text-white font-black text-xs shadow-2xs"
                    style={{
                      backgroundColor: scoreColor,
                      borderColor: scoreColor,
                    }}
                  >
                    <span>{item.score}</span>
                    <span className="text-[9px] font-medium opacity-90 leading-none">/ 100</span>
                  </div>

                  {/* 'Download PDF' pill button on every history row */}
                  <button
                    type="button"
                    onClick={() => handleRowPdfDownload(item)}
                    disabled={isDownloading}
                    className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-bold bg-white text-[#1E8449] border border-emerald-300 hover:bg-emerald-50 transition-colors shadow-2xs disabled:opacity-50"
                    title="Download Statutory PDF Audit Report"
                  >
                    {isDownloading ? (
                      <RefreshCw className="w-3 h-3 animate-spin text-[#27AE60]" />
                    ) : (
                      <FileDown className="w-3.5 h-3.5 text-[#27AE60]" />
                    )}
                    <span>Download PDF</span>
                  </button>

                  {/* View Report Link */}
                  <a
                    href="/"
                    onClick={(e) => {
                      if (onSelectProduct) {
                        e.preventDefault();
                        onSelectProduct(item.productId);
                      }
                    }}
                    className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold bg-[#F9FAF8] text-neutral-700 border border-neutral-200 hover:bg-neutral-100 hover:text-neutral-900 transition-colors"
                  >
                    <span>View Report</span>
                    <ArrowRight className="w-3 h-3" />
                  </a>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};

export default HistoryView;

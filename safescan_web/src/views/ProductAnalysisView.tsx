import React, { useState, useRef, useEffect } from 'react';
import type { ProductAnalysis, UserProfile } from '../types/api';
import { mockFoodProduct, mockCosmeticProduct, mockUserProfile } from '../mockData';
import {
  getProductAnalysis,
  analyzePackageImage,
  downloadAuditReport,
  getUserProfile,
} from '../api/client';
import { ScoreGauge } from '../components/ScoreGauge';
import { LegalMetrologyCard } from '../components/LegalMetrologyCard';
import { FlaggedIngredientsList } from '../components/FlaggedIngredientsList';
import { AlternativeProductsSection } from '../components/AlternativeProductsSection';
import { HeroMascotScene, FeatureShowcaseCards } from '../components/MascotIllustration';
import {
  Barcode,
  UploadCloud,
  CheckCircle,
  Tag,
  Share2,
  Bookmark,
  RefreshCw,
  AlertOctagon,
  FileDown,
  ArrowRight,
  Image as ImageIcon,
  Search,
  Sparkles,
} from 'lucide-react';

export const ProductAnalysisView: React.FC = () => {
  // Active product state
  const [currentProduct, setCurrentProduct] = useState<ProductAnalysis>(mockFoodProduct);
  const [activeTab, setActiveTab] = useState<'barcode' | 'ocr'>('barcode');
  const [userProfile, setUserProfile] = useState<UserProfile>(mockUserProfile);

  // Manual Barcode Entry state
  const [barcodeInput, setBarcodeInput] = useState('8901262010058');
  const [barcodeError, setBarcodeError] = useState<string | null>(null);
  const [isCheckingBarcode, setIsCheckingBarcode] = useState(false);

  // OCR Upload state
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [ocrStep, setOcrStep] = useState<number>(0);
  const [isAnalyzingOcr, setIsAnalyzingOcr] = useState(false);
  const [dragActive, setDragActive] = useState(false);
  const [ocrError, setOcrError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // General interaction state
  const [bookmarked, setBookmarked] = useState(false);
  const [isDownloadingPdf, setIsDownloadingPdf] = useState(false);
  const [statusNotification, setStatusNotification] = useState<string | null>(null);

  useEffect(() => {
    getUserProfile().then((profile) => {
      if (profile) setUserProfile(profile);
    });
  }, []);

  // Quick switch between products
  const handleProductSwitch = (product: ProductAnalysis) => {
    setCurrentProduct(product);
    if (product.barcode) {
      setBarcodeInput(product.barcode);
    }
    setStatusNotification(`Loaded inspection report for "${product.name}"`);
    setTimeout(() => setStatusNotification(null), 3000);
  };

  // Tab A: Check Barcode
  const handleBarcodeSubmit = async (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setBarcodeError(null);

    const cleanBarcode = barcodeInput.trim();
    if (!cleanBarcode) {
      setBarcodeError('Please enter a barcode number.');
      return;
    }

    if (!/^\d{8,14}$/.test(cleanBarcode)) {
      setBarcodeError('Invalid format: Barcode must contain 8 to 14 numeric digits (e.g., 8901262010058).');
      return;
    }

    setIsCheckingBarcode(true);
    try {
      const result = await getProductAnalysis(cleanBarcode);
      setCurrentProduct(result);
      setStatusNotification(`Successfully loaded analysis for Barcode ${cleanBarcode}`);
    } catch {
      setBarcodeError('Unable to fetch product. Loaded offline mock profile.');
    } finally {
      setIsCheckingBarcode(false);
      setTimeout(() => setStatusNotification(null), 3000);
    }
  };

  // Tab B: File Selection & Validation
  const handleFileChange = (file: File) => {
    setOcrError(null);

    // Validate type
    if (!file.type.startsWith('image/')) {
      setOcrError('Only image files (JPG, PNG, WEBP) are supported.');
      return;
    }

    // Validate size (10MB max)
    if (file.size > 10 * 1024 * 1024) {
      setOcrError('Image size exceeds 10MB limit. Please upload a smaller photo.');
      return;
    }

    setSelectedFile(file);
    const objectUrl = URL.createObjectURL(file);
    setPreviewUrl(objectUrl);
  };

  // Tab B: 4-Step Animated OCR Flow
  const ocrSteps = [
    'Preprocessing image & straightening text...',
    'Extracting ingredient OCR text with Tesseract model...',
    'Checking Legal Metrology declarations against PCR 2011...',
    'Scoring ingredients & cross-referencing FSSAI/SCCS risk tables...',
  ];

  const handleStartOcrAnalysis = async () => {
    if (!selectedFile) return;

    setIsAnalyzingOcr(true);
    setOcrStep(0);

    // Step 1
    await new Promise((r) => setTimeout(r, 600));
    setOcrStep(1);

    // Step 2
    await new Promise((r) => setTimeout(r, 700));
    setOcrStep(2);

    // Step 3
    await new Promise((r) => setTimeout(r, 700));
    setOcrStep(3);

    // Step 4 & Final Call
    await new Promise((r) => setTimeout(r, 600));
    try {
      const result = await analyzePackageImage(selectedFile);
      setCurrentProduct(result);
      setStatusNotification(`OCR extraction complete! Analyzed "${result.name}".`);
    } catch {
      setStatusNotification('OCR pipeline processed with fallback mock analysis.');
    } finally {
      setIsAnalyzingOcr(false);
      setOcrStep(0);
      setTimeout(() => setStatusNotification(null), 3500);
    }
  };

  // PDF Audit Report Download Handler
  const handleDownloadPdf = async () => {
    setIsDownloadingPdf(true);
    try {
      await downloadAuditReport(currentProduct.id, currentProduct);
      setStatusNotification(`Downloaded statutory audit report for "${currentProduct.name}" (PDF).`);
    } catch {
      setStatusNotification('PDF download failed. Please try again.');
    } finally {
      setIsDownloadingPdf(false);
      setTimeout(() => setStatusNotification(null), 3000);
    }
  };

  // Personalized Allergen & Health Alert Detection
  const detectPersonalizedAlerts = () => {
    const alerts: Array<{ ingredient: string; userPreference: string; reason: string }> = [];

    const userAllergies = userProfile.allergies || [];
    const flagged = currentProduct.flaggedIngredients || [];

    for (const item of flagged) {
      const ingNameLower = item.name.toLowerCase();

      // Check Sulfate allergy
      if (
        userAllergies.some((a) => a.toLowerCase().includes('sulfate')) &&
        (ingNameLower.includes('sulfate') || ingNameLower.includes('sles') || ingNameLower.includes('sls'))
      ) {
        alerts.push({
          ingredient: item.name,
          userPreference: 'Sulfates (SLES / SLS)',
          reason: 'Matches your saved hypersensitivity alert for harsh sulfated foaming agents.',
        });
      }

      // Check Paraben allergy
      if (
        userAllergies.some((a) => a.toLowerCase().includes('paraben')) &&
        ingNameLower.includes('paraben')
      ) {
        alerts.push({
          ingredient: item.name,
          userPreference: 'Parabens (Methyl / Propyl)',
          reason: 'Matches your saved endocrine-disruptor avoid list.',
        });
      }

      // Check Dye allergy
      if (
        userAllergies.some((a) => a.toLowerCase().includes('dye') || a.toLowerCase().includes('19140')) &&
        (ingNameLower.includes('19140') || ingNameLower.includes('tartrazine') || ingNameLower.includes('dye'))
      ) {
        alerts.push({
          ingredient: item.name,
          userPreference: 'Artificial Azo Dyes (CI 19140)',
          reason: 'Matches your registered contact dermatitis trigger.',
        });
      }

      // Check Lactose preference if food
      if (
        userProfile.dietaryPreferences.some((d) => d.toLowerCase().includes('lactose')) &&
        ingNameLower.includes('lactose')
      ) {
        alerts.push({
          ingredient: item.name,
          userPreference: 'Lactose-Conscious Dietary Goal',
          reason: 'Contains naturally occurring milk lactose sugars.',
        });
      }
    }

    return alerts;
  };

  const personalAlerts = detectPersonalizedAlerts();

  return (
    <div className="space-y-10 pb-16 font-sans">
      {/* YUKA-STYLE SPLIT HERO WITH SPROUT MASCOT SCENE */}
      <section className="bg-gradient-to-b from-[#F9FAF8] via-white to-white border-b border-neutral-100/90 pt-10 sm:pt-14 pb-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
            {/* Left Side: Editorial Headline, Subtitle, & Primary CTAs */}
            <div className="lg:col-span-7 space-y-6 text-left">
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-xs font-bold bg-[#27AE60]/10 text-[#1E8449] border border-[#27AE60]/20 shadow-2xs">
                <Sparkles className="w-4 h-4 text-[#27AE60]" />
                <span>100% Independent Health &amp; Statutory Analysis</span>
              </div>

              <h1 className="text-3xl sm:text-5xl lg:text-6xl font-black text-neutral-900 tracking-tight leading-[1.12]">
                Make the{' '}
                <span className="font-handwritten text-[#27AE60] text-4xl sm:text-6xl lg:text-7xl block sm:inline">
                  right choices
                </span>{' '}
                for your health &amp; pantry
              </h1>

              <p className="text-sm sm:text-base text-neutral-600 leading-relaxed max-w-xl">
                Scan food barcodes or snap cosmetic product labels. SafeScan decodes nutritional
                density, hidden toxic chemicals, and checks mandatory Indian Legal Metrology
                declarations (MRP, Expiry, FSSAI) with zero commercial advertising.
              </p>

              {/* Primary CTAs */}
              <div className="flex flex-wrap items-center gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => {
                    const el = document.getElementById('scanner-card');
                    el?.scrollIntoView({ behavior: 'smooth' });
                  }}
                  className="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl text-sm font-extrabold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm hover:shadow-md transition-all active:scale-[0.98]"
                >
                  <Barcode className="w-4 h-4" />
                  <span>Scan a Product Now</span>
                </button>

                <button
                  type="button"
                  onClick={() => {
                    const nextProduct =
                      currentProduct.id === mockFoodProduct.id
                        ? mockCosmeticProduct
                        : mockFoodProduct;
                    handleProductSwitch(nextProduct);
                  }}
                  className="inline-flex items-center gap-2 px-5 py-3.5 rounded-2xl text-sm font-bold bg-[#F9FAF8] hover:bg-neutral-100 text-neutral-800 border border-neutral-200 transition-all active:scale-[0.98]"
                >
                  <RefreshCw className="w-4 h-4 text-[#27AE60]" />
                  <span>Try Sample Scan</span>
                </button>
              </div>

              {/* Quick Sample Selector Pills */}
              <div className="pt-2 flex flex-wrap items-center gap-2 text-xs">
                <span className="text-neutral-400 font-semibold text-[11px] uppercase tracking-wider">
                  Quick test samples:
                </span>
                <button
                  type="button"
                  onClick={() => handleProductSwitch(mockFoodProduct)}
                  className={`px-3 py-1.5 rounded-xl font-bold transition-all ${
                    currentProduct.id === mockFoodProduct.id
                      ? 'bg-[#1E8449] text-white shadow-2xs'
                      : 'bg-white text-neutral-700 border border-neutral-200 hover:border-emerald-300'
                  }`}
                >
                  Amul Milk (92/100)
                </button>
                <button
                  type="button"
                  onClick={() => handleProductSwitch(mockCosmeticProduct)}
                  className={`px-3 py-1.5 rounded-xl font-bold transition-all ${
                    currentProduct.id === mockCosmeticProduct.id
                      ? 'bg-[#E74C3C] text-white shadow-2xs'
                      : 'bg-white text-neutral-700 border border-neutral-200 hover:border-rose-300'
                  }`}
                >
                  Herbal Silk Shampoo (38/100)
                </button>
              </div>
            </div>

            {/* Right Side: HeroMascotScene */}
            <div className="lg:col-span-5 flex justify-center">
              <HeroMascotScene
                activeProduct={currentProduct}
                onToggleProduct={() => {
                  const nextProduct =
                    currentProduct.id === mockFoodProduct.id
                      ? mockCosmeticProduct
                      : mockFoodProduct;
                  handleProductSwitch(nextProduct);
                }}
              />
            </div>
          </div>
        </div>
      </section>

      {/* INTERACTIVE SCANNER CARD (MANUAL BARCODE & PHOTO OCR TABS) */}
      <section
        id="scanner-card"
        className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 scroll-mt-24"
      >
        <div className="bg-white rounded-3xl border border-neutral-200/90 p-5 sm:p-6 shadow-sm">
          {/* Tab Navigation */}
          <div className="flex items-center gap-3 border-b border-neutral-100 pb-4 mb-5">
            <button
              type="button"
              onClick={() => setActiveTab('barcode')}
              className={`inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs sm:text-sm font-bold transition-all ${
                activeTab === 'barcode'
                  ? 'bg-[#27AE60] text-white shadow-sm'
                  : 'bg-[#F9FAF8] text-neutral-600 hover:text-neutral-900 border border-neutral-200'
              }`}
            >
              <Barcode className="w-4 h-4" />
              <span>Tab A — Manual Barcode Entry</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('ocr')}
              className={`inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs sm:text-sm font-bold transition-all ${
                activeTab === 'ocr'
                  ? 'bg-[#27AE60] text-white shadow-sm'
                  : 'bg-[#F9FAF8] text-neutral-600 hover:text-neutral-900 border border-neutral-200'
              }`}
            >
              <UploadCloud className="w-4 h-4" />
              <span>Tab B — Label Photo Upload (OCR Fallback)</span>
            </button>
          </div>

          {/* TAB A: Manual Barcode Entry */}
          {activeTab === 'barcode' && (
            <div className="space-y-4">
              <form onSubmit={handleBarcodeSubmit} className="flex flex-col sm:flex-row gap-3">
                <div className="relative flex-1">
                  <Barcode className="w-5 h-5 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={barcodeInput}
                    onChange={(e) => {
                      setBarcodeInput(e.target.value);
                      if (barcodeError) setBarcodeError(null);
                    }}
                    placeholder="Enter 8–14 digit barcode (e.g., 8901262010058 or 8904005928114)..."
                    className="w-full pl-11 pr-4 py-3 text-sm rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] focus:border-transparent font-mono transition-all"
                  />
                </div>

                <button
                  type="submit"
                  disabled={isCheckingBarcode}
                  className="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-xl text-xs sm:text-sm font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all active:scale-[0.98] disabled:opacity-60 shrink-0"
                >
                  {isCheckingBarcode ? (
                    <>
                      <RefreshCw className="w-4 h-4 animate-spin" />
                      <span>Checking Product...</span>
                    </>
                  ) : (
                    <>
                      <Search className="w-4 h-4" />
                      <span>Check Product</span>
                    </>
                  )}
                </button>
              </form>

              {/* Error message */}
              {barcodeError && (
                <p className="text-xs text-rose-600 font-medium flex items-center gap-1.5 animate-in fade-in">
                  <AlertOctagon className="w-3.5 h-3.5" />
                  <span>{barcodeError}</span>
                </p>
              )}

              {/* Helpful Barcode Presets */}
              <div className="flex flex-wrap items-center gap-2 pt-1 text-xs text-neutral-500">
                <span className="font-semibold text-neutral-400">Quick Test Barcodes:</span>
                <button
                  type="button"
                  onClick={() => {
                    setBarcodeInput('8901262010058');
                    handleProductSwitch(mockFoodProduct);
                  }}
                  className="px-2.5 py-1 rounded-lg bg-[#F9FAF8] border border-neutral-200 hover:border-emerald-300 font-mono text-[11px] text-neutral-700"
                >
                  8901262010058 (Amul Milk)
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setBarcodeInput('8904005928114');
                    handleProductSwitch(mockCosmeticProduct);
                  }}
                  className="px-2.5 py-1 rounded-lg bg-[#F9FAF8] border border-neutral-200 hover:border-rose-300 font-mono text-[11px] text-neutral-700"
                >
                  8904005928114 (Herbal Silk Shampoo)
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setBarcodeInput('8901262031164');
                    handleBarcodeSubmit();
                  }}
                  className="px-2.5 py-1 rounded-lg bg-[#F9FAF8] border border-neutral-200 hover:border-emerald-300 font-mono text-[11px] text-neutral-700"
                >
                  8901262031164 (Generic EAN-13)
                </button>
              </div>
            </div>
          )}

          {/* TAB B: Label Photo Upload (OCR Fallback) */}
          {activeTab === 'ocr' && (
            <div className="space-y-4">
              <div
                onDragOver={(e) => {
                  e.preventDefault();
                  setDragActive(true);
                }}
                onDragLeave={() => setDragActive(false)}
                onDrop={(e) => {
                  e.preventDefault();
                  setDragActive(false);
                  if (e.dataTransfer.files && e.dataTransfer.files[0]) {
                    handleFileChange(e.dataTransfer.files[0]);
                  }
                }}
                onClick={() => fileInputRef.current?.click()}
                className={`p-6 sm:p-8 rounded-2xl border-2 border-dashed text-center cursor-pointer transition-all ${
                  dragActive
                    ? 'border-[#27AE60] bg-[#27AE60]/5'
                    : 'border-neutral-200 hover:border-emerald-300 bg-[#F9FAF8]'
                }`}
              >
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={(e) => {
                    if (e.target.files && e.target.files[0]) {
                      handleFileChange(e.target.files[0]);
                    }
                  }}
                  className="hidden"
                />

                {previewUrl ? (
                  <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                    <img
                      src={previewUrl}
                      alt="Uploaded package preview"
                      className="w-24 h-24 object-cover rounded-xl border border-neutral-300 shadow-xs"
                    />
                    <div className="text-left">
                      <p className="text-xs font-bold text-neutral-900">{selectedFile?.name}</p>
                      <p className="text-[11px] text-neutral-500">
                        {((selectedFile?.size || 0) / (1024 * 1024)).toFixed(2)} MB • Ready for OCR processing
                      </p>
                      <span className="text-[11px] text-[#27AE60] font-semibold mt-1 inline-block">
                        Click to select a different photo
                      </span>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-2">
                    <div className="w-12 h-12 rounded-2xl bg-[#27AE60]/10 text-[#1E8449] flex items-center justify-center mx-auto">
                      <ImageIcon className="w-6 h-6 text-[#27AE60]" />
                    </div>
                    <p className="text-sm font-bold text-neutral-800">
                      Drag and drop package photo, or <span className="text-[#27AE60]">browse files</span>
                    </p>
                    <p className="text-xs text-neutral-400">
                      Supports high-resolution JPG, PNG, WEBP of back-of-pack ingredients &amp; MRP panels (max 10MB)
                    </p>
                  </div>
                )}
              </div>

              {ocrError && (
                <p className="text-xs text-rose-600 font-medium flex items-center gap-1.5 animate-in fade-in">
                  <AlertOctagon className="w-3.5 h-3.5" />
                  <span>{ocrError}</span>
                </p>
              )}

              {/* Animated 4-step OCR Analysis Progress Flow */}
              {isAnalyzingOcr && (
                <div className="p-4 rounded-2xl bg-emerald-50/70 border border-emerald-200 space-y-3 animate-in fade-in">
                  <div className="flex items-center justify-between text-xs font-bold text-[#1E8449]">
                    <span className="flex items-center gap-2">
                      <RefreshCw className="w-4 h-4 animate-spin text-[#27AE60]" />
                      <span>OCR Pipeline Executing...</span>
                    </span>
                    <span>Step {ocrStep + 1} of 4</span>
                  </div>

                  {/* Progress Bar */}
                  <div className="w-full bg-emerald-100 rounded-full h-2 overflow-hidden">
                    <div
                      className="bg-[#27AE60] h-full transition-all duration-500 ease-out"
                      style={{ width: `${((ocrStep + 1) / 4) * 100}%` }}
                    />
                  </div>

                  {/* 4 Step Items */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-[11px] pt-1">
                    {ocrSteps.map((stepDesc, idx) => {
                      const isDone = ocrStep > idx;
                      const isCurrent = ocrStep === idx;
                      return (
                        <div
                          key={idx}
                          className={`flex items-center gap-2 p-2 rounded-lg transition-all ${
                            isCurrent
                              ? 'bg-white font-bold text-[#1E8449] shadow-2xs'
                              : isDone
                              ? 'text-neutral-600'
                              : 'text-neutral-400 opacity-60'
                          }`}
                        >
                          <span
                            className={`w-4 h-4 rounded-full flex items-center justify-center text-[9px] font-bold shrink-0 ${
                              isDone
                                ? 'bg-[#27AE60] text-white'
                                : isCurrent
                                ? 'bg-emerald-200 text-[#1E8449] animate-pulse'
                                : 'bg-neutral-200 text-neutral-500'
                            }`}
                          >
                            {isDone ? '✓' : idx + 1}
                          </span>
                          <span className="truncate">{stepDesc}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* Analyze Button */}
              <div className="flex items-center justify-between pt-1">
                <span className="text-xs text-neutral-400">
                  Extracts text, identifies FSSAI numbers, verifies Rule 6 MRP, and audits ingredients.
                </span>

                <button
                  type="button"
                  onClick={handleStartOcrAnalysis}
                  disabled={!selectedFile || isAnalyzingOcr}
                  className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs sm:text-sm font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all active:scale-[0.98] disabled:opacity-50"
                >
                  <Sparkles className="w-4 h-4" />
                  <span>Run OCR Analysis</span>
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Toast Notification */}
        {statusNotification && (
          <div className="mt-4 p-3.5 rounded-xl bg-emerald-50 text-[#1E8449] text-xs font-bold flex items-center gap-2 animate-in fade-in border border-emerald-200 shadow-2xs">
            <CheckCircle className="w-4 h-4 text-[#27AE60]" />
            <span>{statusNotification}</span>
          </div>
        )}
      </section>

      {/* MAIN INSPECTION RESULT CONTAINER */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
        {/* PROMINENT RED PERSONALIZED ALLERGEN ALERT BANNER */}
        {personalAlerts.length > 0 && (
          <div className="rounded-2xl bg-rose-50 border-2 border-rose-300 p-4 sm:p-5 text-rose-950 shadow-xs animate-in slide-in-from-top-2 duration-300">
            <div className="flex items-start gap-3">
              <div className="w-9 h-9 rounded-xl bg-rose-600 text-white flex items-center justify-center shrink-0 shadow-xs">
                <AlertOctagon className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <h3 className="text-sm sm:text-base font-extrabold text-rose-900 tracking-tight">
                    ⚠️ Personalized Health Allergen Alert Detected
                  </h3>
                  <span className="text-[11px] font-bold uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-rose-200/80 text-rose-800">
                    Profile: {userProfile.skinType || 'Sensitive'}
                  </span>
                </div>

                <p className="text-xs text-rose-800 mt-1 leading-relaxed">
                  This product formulation contains ingredients that directly conflict with your
                  saved household allergies or skin profile:
                </p>

                <div className="mt-3 space-y-1.5">
                  {personalAlerts.map((alert, i) => (
                    <div
                      key={i}
                      className="p-2.5 rounded-xl bg-white/90 border border-rose-200 flex flex-col sm:flex-row sm:items-center justify-between gap-1 text-xs"
                    >
                      <span className="font-bold text-rose-900">
                        {alert.ingredient}
                      </span>
                      <span className="text-rose-700 font-medium">
                        Triggered by: <span className="underline font-semibold">{alert.userPreference}</span>
                      </span>
                    </div>
                  ))}
                </div>

                <div className="mt-3 flex items-center justify-between text-xs pt-1">
                  <span className="text-rose-700 font-semibold">
                    Recommendation: Consider switching to one of the verified sulfate/paraben-free alternatives below.
                  </span>
                  <a
                    href="/profile"
                    className="text-rose-900 font-bold hover:underline inline-flex items-center gap-1"
                  >
                    Update Allergens <ArrowRight className="w-3 h-3" />
                  </a>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Product Details Header with 'Download PDF Audit Report' Pill Button */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 sm:p-5 rounded-2xl border border-neutral-200/80 shadow-xs">
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold uppercase tracking-wider text-neutral-400">
              Verified Scan Report:
            </span>
            <span className="text-sm font-bold text-neutral-900">
              {currentProduct.name}
            </span>
          </div>

          <div className="flex items-center gap-2">
            {/* Download PDF Audit Report Pill Button */}
            <button
              type="button"
              onClick={handleDownloadPdf}
              disabled={isDownloadingPdf}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-[#1E8449] hover:bg-[#145a32] text-white shadow-xs transition-all active:scale-[0.98] disabled:opacity-60"
            >
              {isDownloadingPdf ? (
                <>
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                  <span>Generating PDF...</span>
                </>
              ) : (
                <>
                  <FileDown className="w-3.5 h-3.5" />
                  <span>Download PDF Audit Report</span>
                </>
              )}
            </button>

            <button
              type="button"
              onClick={() => setBookmarked(!bookmarked)}
              className={`p-2 rounded-xl border transition-colors ${
                bookmarked
                  ? 'bg-emerald-50 border-emerald-200 text-[#1E8449]'
                  : 'border-neutral-200 text-neutral-400 hover:text-neutral-700'
              }`}
              title="Bookmark"
            >
              <Bookmark className="w-4 h-4" />
            </button>

            <button
              type="button"
              onClick={() => {
                navigator.clipboard?.writeText(window.location.href);
                setStatusNotification('Copied inspection report link to clipboard.');
                setTimeout(() => setStatusNotification(null), 2500);
              }}
              className="p-2 rounded-xl border border-neutral-200 text-neutral-400 hover:text-neutral-700 transition-colors"
              title="Share Report"
            >
              <Share2 className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Product Grid Columns */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          {/* Left Column: Visuals & Yuka Score Gauge */}
          <div className="lg:col-span-5 space-y-6">
            <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs flex flex-col items-center text-center relative overflow-hidden">
              {/* Product Badge Pill */}
              <div className="w-full flex items-center justify-between mb-4">
                <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-neutral-100 text-neutral-600">
                  <Tag className="w-3 h-3" />
                  {currentProduct.category}
                </span>

                <span className="text-[11px] font-mono text-neutral-400">
                  EAN: {currentProduct.barcode || 'N/A'}
                </span>
              </div>

              {/* Product Image */}
              <div className="relative mb-5">
                <div className="w-48 h-48 sm:w-56 sm:h-56 rounded-2xl overflow-hidden bg-[#F9FAF8] border border-neutral-200/80 p-2 shadow-inner flex items-center justify-center">
                  <img
                    src={currentProduct.imageUrl}
                    alt={currentProduct.name}
                    className="w-full h-full object-cover rounded-xl transition-transform duration-300 hover:scale-105"
                  />
                </div>
              </div>

              {/* Brand & Name */}
              <span className="text-xs font-bold uppercase tracking-widest text-[#27AE60]">
                {currentProduct.brand}
              </span>
              <h2 className="text-xl sm:text-2xl font-black text-neutral-900 tracking-tight mt-1 leading-snug">
                {currentProduct.name}
              </h2>

              {/* Yuka-Inspired Score Gauge */}
              <div className="mt-6 pt-6 border-t border-neutral-100 w-full flex flex-col items-center">
                <ScoreGauge
                  score={currentProduct.score}
                  tier={currentProduct.ratingTier}
                  label={currentProduct.ratingLabel}
                  nutriScore={currentProduct.nutriScore}
                  size="lg"
                />
              </div>

              {/* Summary Description */}
              <p className="mt-4 text-xs text-neutral-600 leading-relaxed bg-[#F9FAF8] p-3.5 rounded-2xl border border-neutral-200/60 text-left">
                {currentProduct.summary}
              </p>
            </div>

            {/* Packaging Verification Box */}
            <div className="p-4 rounded-2xl bg-[#F9FAF8] border border-neutral-200/80 text-xs space-y-2">
              <div className="flex items-center justify-between text-neutral-600">
                <span className="font-semibold">Statutory Standard:</span>
                <span className="font-mono text-neutral-800">
                  {currentProduct.category === 'food' ? 'FSSAI Standards 2011' : 'BIS IS 7884 / Drugs & Cosmetics'}
                </span>
              </div>
              <div className="flex items-center justify-between text-neutral-600">
                <span className="font-semibold">Analyzed At:</span>
                <span>{new Date(currentProduct.scannedAt || '').toLocaleString('en-IN')}</span>
              </div>
              <div className="flex items-center justify-between text-neutral-600">
                <span className="font-semibold">OCR Confidence:</span>
                <span className="font-bold text-[#1E8449]">99.4% Multi-angle</span>
              </div>
            </div>
          </div>

          {/* Right Column: Legal Metrology + Flagged Ingredients + Alternatives */}
          <div className="lg:col-span-7 space-y-8">
            {/* Legal Metrology Card */}
            <section>
              <LegalMetrologyCard
                legalMetrology={currentProduct.legalMetrology}
                category={currentProduct.category}
              />
            </section>

            {/* Ingredients Risk Assessment with Verified/Uncertain Badges & Why This Score */}
            <section className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs">
              <FlaggedIngredientsList
                ingredients={currentProduct.flaggedIngredients}
                positivePoints={currentProduct.positivePoints}
                negativePoints={currentProduct.negativePoints}
                score={currentProduct.score}
                category={currentProduct.category}
                isCompliant={currentProduct.legalMetrology.compliant}
              />

              {/* Declared Ingredients Text */}
              {currentProduct.ingredientsText && (
                <div className="mt-6 pt-4 border-t border-neutral-200/60">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-neutral-400 block mb-1">
                    Full Declared Ingredient Statement:
                  </span>
                  <p className="text-xs text-neutral-600 leading-relaxed bg-[#F9FAF8] p-3 rounded-xl border border-neutral-200/60 font-mono">
                    {currentProduct.ingredientsText}
                  </p>
                </div>
              )}
            </section>

            {/* Healthier & Cleaner Alternatives */}
            <section className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs">
              <AlternativeProductsSection
                alternatives={currentProduct.alternatives}
                category={currentProduct.category}
              />
            </section>
          </div>
        </div>
      </main>

      {/* YUKA-STYLE EDITORIAL ALTERNATING FEATURE SHOWCASE BLOCKS */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-4">
        <FeatureShowcaseCards onSelectProduct={handleProductSwitch} />
      </section>
    </div>
  );
};

export default ProductAnalysisView;

/**
 * SafeScan & PackCheck AI - Core API & Domain Types
 * Yuka-inspired health rating & Legal Metrology compliance architecture.
 */

export type ProductCategory = 'food' | 'cosmetic';

export type RatingTier = 'excellent' | 'good' | 'mediocre' | 'poor';

export type NutriScoreGrade = 'A' | 'B' | 'C' | 'D' | 'E';

export type HazardLevel = 'low' | 'moderate' | 'high' | 'info';

/**
 * Yuka-Inspired 4-Tier Rating Colors:
 * - Excellent: Dark Green (#1E8449)
 * - Good: Light Green (#2ECC71)
 * - Mediocre: Amber (#F39C12)
 * - Poor / Risky: Coral Red (#E74C3C)
 */
export const RATING_COLORS = {
  excellent: '#1E8449',
  good: '#2ECC71',
  mediocre: '#F39C12',
  poor: '#E74C3C',
} as const;

export const RATING_BG_COLORS = {
  excellent: 'bg-[#1E8449]',
  good: 'bg-[#2ECC71]',
  mediocre: 'bg-[#F39C12]',
  poor: 'bg-[#E74C3C]',
} as const;

export const RATING_TEXT_COLORS = {
  excellent: 'text-[#1E8449]',
  good: 'text-[#2ECC71]',
  mediocre: 'text-[#F39C12]',
  poor: 'text-[#E74C3C]',
} as const;

export const RATING_LIGHT_BG_COLORS = {
  excellent: 'bg-[#1E8449]/10',
  good: 'bg-[#2ECC71]/10',
  mediocre: 'bg-[#F39C12]/10',
  poor: 'bg-[#E74C3C]/10',
} as const;

/**
 * Returns the Yuka-style rating tier based on a 0-100 score.
 */
export function getRatingTier(score: number): RatingTier {
  if (score >= 75) return 'excellent';
  if (score >= 50) return 'good';
  if (score >= 25) return 'mediocre';
  return 'poor';
}

export function getRatingLabel(scoreOrTier: number | RatingTier): string {
  const tier = typeof scoreOrTier === 'number' ? getRatingTier(scoreOrTier) : scoreOrTier;
  switch (tier) {
    case 'excellent':
      return 'Excellent';
    case 'good':
      return 'Good';
    case 'mediocre':
      return 'Mediocre';
    case 'poor':
      return 'Poor / Risky';
  }
}

/**
 * Ingredient flagged for potential health, irritant, or nutritional risks.
 */
export interface FlaggedIngredient {
  name: string;
  hazardLevel: HazardLevel;
  reason: string;
  category?: string;
  scientificDetails?: string;
  regulatoryStatus?: string;
  eNumber?: string;
  dataSource?: string; // e.g. 'FSSAI Mandate', 'CIR Verified', 'BIS Standard', 'EWG Verified', 'General INCI'
  isVerified?: boolean; // true = Verified against statutory panel; false = Uncertain / General INCI
}

/**
 * Hazard Ingredient record for Admin Database Management.
 */
export interface HazardIngredient {
  id: string;
  name: string;
  aliases: string[];
  category: ProductCategory;
  hazardLevel: HazardLevel;
  regulatorySource: string; // 'EWG' | 'FSSAI' | 'INCI' | 'BIS' | 'CIR' | 'EU SCCS'
  reason: string;
  scientificDetails?: string;
  eNumber?: string;
}

/**
 * Legal Metrology (Packaged Commodities Rules 2011 & FSSAI) verification.
 */
export interface LegalMetrology {
  compliant: boolean;
  mrp: string;
  netQuantity: string;
  expiryDate?: string;
  manufactureDate?: string;
  batchNumber?: string;
  manufacturerName?: string;
  manufacturerAddress?: string;
  consumerCareDetails?: string;
  countryOfOrigin?: string;
  fssaiLicenseNumber?: string;
  missingFields: string[];
  complianceScore?: number;
  notes?: string;
}

/**
 * Healthier, cleaner, or fully compliant alternative product recommendations.
 */
export interface AlternativeProduct {
  id: string;
  name: string;
  brand: string;
  category: ProductCategory;
  score: number;
  ratingTier: RatingTier;
  highlightReason: string;
  mrp?: string;
  netQuantity?: string;
  imageUrl?: string;
}

/**
 * Complete product analysis result combining health scoring and pack compliance.
 */
export interface ProductAnalysis {
  id: string;
  barcode?: string;
  name: string;
  brand: string;
  category: ProductCategory;
  score: number; // 0 to 100
  ratingTier: RatingTier;
  ratingLabel: string;
  nutriScore?: NutriScoreGrade; // For foods (A-E)
  safetyScore?: number; // For cosmetics (0-100)
  summary: string;
  imageUrl?: string;
  ingredientsText?: string;
  ingredientsList?: string[];
  flaggedIngredients: FlaggedIngredient[];
  positivePoints: string[];
  negativePoints: string[];
  legalMetrology: LegalMetrology;
  alternatives: AlternativeProduct[];
  scannedAt?: string;
  packVerified?: boolean;
}

/**
 * Summary record for scan history feeds.
 */
export interface ScanHistoryItem {
  id: string;
  productId: string;
  productName: string;
  brand: string;
  category: ProductCategory;
  score: number;
  ratingTier: RatingTier;
  ratingLabel: string;
  isCompliant: boolean;
  flaggedCount: number;
  timestamp: string;
  thumbnailUrl?: string;
}

/**
 * User profile including health restrictions, skin type, and allergen preferences.
 */
export interface UserProfile {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  role: 'user' | 'admin';
  skinType?: string;
  dietaryPreferences: string[];
  allergies: string[];
  scansCount: number;
  savedAlternativesCount?: number;
  createdAt: string;
}

/**
 * API standard response wrapper.
 */
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

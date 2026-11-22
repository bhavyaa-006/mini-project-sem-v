import type {
  ProductAnalysis,
  ScanHistoryItem,
  UserProfile,
  HazardIngredient,
} from './types/api';

/**
 * Rich, realistic Indian Food Product: Amul Taaza Pasteurised Toned Milk
 * - Nutri-Score A, 92/100
 * - Compliant Legal Metrology with MRP ₹32, Net Qty 500ml, Expiry 25 Dec 2026,
 *   Manufacturer Gujarat Co-operative Milk Marketing Federation
 * - 1 minor added sugar note
 * - 2 cleaner alternatives
 */
export const mockFoodProduct: ProductAnalysis = {
  id: 'prod-amul-taaza-001',
  barcode: '8901262010058',
  name: 'Amul Taaza Pasteurised Toned Milk',
  brand: 'Amul',
  category: 'food',
  score: 92,
  ratingTier: 'excellent',
  ratingLabel: 'Excellent',
  nutriScore: 'A',
  summary:
    'Fresh, pasteurised toned milk with excellent nutritional density. Naturally rich in bioavailable calcium, potassium, and essential proteins, processed under stringent FSSAI food safety norms with zero harmful chemical adulterants.',
  imageUrl:
    'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=800&q=80',
  ingredientsText:
    'Toned Milk, Vitamin A (Retinyl Acetate), Vitamin D2 (Ergocalciferol). Minimum 3.0% Milk Fat, Minimum 8.5% Milk SNF (Solids-Not-Fat).',
  ingredientsList: [
    'Toned Milk (3.0% Fat, 8.5% SNF)',
    'Fortified Vitamin A',
    'Fortified Vitamin D2',
  ],
  flaggedIngredients: [
    {
      name: 'Naturally Occurring Milk Sugars (Lactose ~4.7g/100ml)',
      hazardLevel: 'info',
      reason:
        'Contains naturally occurring milk sugar (lactose). No added refined cane sugars, high fructose corn syrup, or artificial sweeteners detected.',
      category: 'Carbohydrates & Sugars',
      scientificDetails:
        'Lactose has a low glycemic index (~46). Note for individuals with diagnosed lactose intolerance or sensitivity.',
      regulatoryStatus:
        'Compliant with FSSAI Food Safety and Standards (Food Products Standards and Food Additives) Regulations',
      dataSource: 'FSSAI Mandate / Codex',
      isVerified: true,
    },
  ],
  positivePoints: [
    'Excellent Nutri-Score A with minimal saturated fat (1.9g/100ml)',
    'High natural calcium content (125mg per 100ml)',
    'Zero artificial preservatives, emulsifiers, or synthetic colors',
    'Fortified with essential Vitamin A & Vitamin D2 as per FSSAI directives',
    'Pasteurised at 72°C to eliminate pathogenic microorganisms',
  ],
  negativePoints: [
    'Contains natural lactose (not suitable for severe lactose intolerance)',
  ],
  legalMetrology: {
    compliant: true,
    mrp: '₹32.00',
    netQuantity: '500ml',
    expiryDate: '25 Dec 2026',
    manufactureDate: '23 Dec 2026',
    batchNumber: 'BT-AMUL-500-24B',
    manufacturerName:
      'Gujarat Co-operative Milk Marketing Federation Ltd. (Amul)',
    manufacturerAddress:
      'Amul Dairy Road, Anand - 388001, Gujarat, India',
    consumerCareDetails:
      '1800-258-3333 | customercare@amul.coop | www.amul.com',
    countryOfOrigin: 'India',
    fssaiLicenseNumber: '10012021000071',
    missingFields: [],
    complianceScore: 100,
    notes:
      'Full compliance verified under Legal Metrology (Packaged Commodities) Rules, 2011 and FSSAI (Packaging & Labelling) Regulations.',
  },
  alternatives: [
    {
      id: 'alt-cd-001',
      name: 'Pure Desi Cow Milk',
      brand: 'Country Delight',
      category: 'food',
      score: 96,
      ratingTier: 'excellent',
      mrp: '₹42.00',
      netQuantity: '500ml',
      highlightReason:
        'Direct farm-to-doorstep raw chilled cow milk with pure A2 protein profile, zero reconstituted milk powder, and zero preservatives.',
      imageUrl:
        'https://images.unsplash.com/photo-1527153857715-3908f2ae5e81?auto=format&fit=crop&w=400&q=80',
    },
    {
      id: 'alt-ak-002',
      name: 'Organic Whole Cow Milk',
      brand: 'Akshayakalpa Organic',
      category: 'food',
      score: 98,
      ratingTier: 'excellent',
      mrp: '₹48.00',
      netQuantity: '500ml',
      highlightReason:
        'India’s first certified organic dairy from pasture-grazed cattle. 0 antibiotic residues, 0 synthetic hormones, untouched by human hands.',
      imageUrl:
        'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=400&q=80',
    },
  ],
  scannedAt: '2026-11-22T09:15:00Z',
  packVerified: true,
};

/**
 * Rich, realistic Indian Cosmetic Product: Herbal Silk Anti-Dandruff Shampoo
 * - Safety Score 38/100 (Poor / Risky)
 * - Non-Compliant missing expiry date
 * - Flags Sodium Laureth Sulfate and Methylparaben with skin irritation/endocrine warnings
 * - 2 sulfate-free alternatives
 */
export const mockCosmeticProduct: ProductAnalysis = {
  id: 'prod-herbal-silk-002',
  barcode: '8904005928114',
  name: 'Herbal Silk Anti-Dandruff Shampoo',
  brand: 'Herbal Silk',
  category: 'cosmetic',
  score: 38,
  safetyScore: 38,
  ratingTier: 'poor',
  ratingLabel: 'Poor / Risky',
  summary:
    'High-risk cosmetic profile containing harsh sulfated surfactants and endocrine-disrupting alkyl paraben preservatives. Critically non-compliant with Legal Metrology laws due to complete omission of mandatory expiry and batch details on the outer carton.',
  imageUrl:
    'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80',
  ingredientsText:
    'Aqua, Sodium Laureth Sulfate, Cocamidopropyl Betaine, Dimethiconol, Zinc Pyrithione, Parfum, Methylparaben, Propylparaben, Sodium Chloride, Carbomer, CI 19140.',
  ingredientsList: [
    'Aqua (Purified Water)',
    'Sodium Laureth Sulfate (SLES)',
    'Cocamidopropyl Betaine',
    'Dimethiconol',
    'Zinc Pyrithione (1%)',
    'Parfum (Synthetic Fragrance)',
    'Methylparaben',
    'Propylparaben',
    'Sodium Chloride',
    'Carbomer',
    'CI 19140 (Tartrazine)',
  ],
  flaggedIngredients: [
    {
      name: 'Sodium Laureth Sulfate (SLES)',
      hazardLevel: 'high',
      reason:
        'Aggressive anionic surfactant known to cause acute scalp irritation, epidermal barrier degradation, and potential contamination with 1,4-Dioxane (a known human carcinogen).',
      category: 'Surfactant / Foaming Agent',
      scientificDetails:
        'Causes micro-inflammation in follicular roots and strips natural lipid ceramides. CIR Expert Panel advises stringent limits in prolonged contact formulas.',
      regulatoryStatus:
        'Restricted concentration in leave-on hair formulations in EU Cosmetic Annex III; Warning advised under BIS IS 7884.',
      dataSource: 'CIR Panel / BIS Standard',
      isVerified: true,
    },
    {
      name: 'Methylparaben',
      hazardLevel: 'high',
      reason:
        'Known endocrine disruptor with documented estrogen-receptor binding affinity. Linked to cellular alterations and contact hypersensitivity dermatitis.',
      category: 'Synthetic Preservative',
      scientificDetails:
        'Alkyl ester of p-hydroxybenzoic acid. Accumulates in dermal and glandular tissues over repetitive exposure.',
      regulatoryStatus:
        'Under strict surveillance by European SCCS; restricted in pediatric products and under review by CDSCO/BIS.',
      eNumber: 'INS 218',
      dataSource: 'EU SCCS / BIS Review',
      isVerified: true,
    },
    {
      name: 'CI 19140 (Tartrazine)',
      hazardLevel: 'moderate',
      reason:
        'Azo dye colorant associated with allergic contact dermatitis and heightened sensitivity in asthmatic individuals.',
      category: 'Synthetic Colorant',
      scientificDetails:
        'Potential histamine-release trigger upon follicular absorption.',
      regulatoryStatus: 'Restricted threshold in cosmetic colorants.',
      dataSource: 'General INCI / Unverified Threshold',
      isVerified: false,
    },
  ],
  positivePoints: [
    'Contains 1% Zinc Pyrithione (clinically proven anti-Malassezia agent)',
    'Secondary foam conditioning with Cocamidopropyl Betaine',
  ],
  negativePoints: [
    'Contains Sodium Laureth Sulfate (high skin irritation index)',
    'Contains Methylparaben (endocrine disruption & bioaccumulation concern)',
    'Contains synthetic undisclosed Parfum (potential fragrance allergens)',
    'Critical failure of Legal Metrology regulations (missing expiry date)',
  ],
  legalMetrology: {
    compliant: false,
    mrp: '₹249.00',
    netQuantity: '200ml',
    expiryDate: undefined, // Missing expiry date!
    manufactureDate: undefined,
    batchNumber: undefined,
    missingFields: [
      'Expiry Date / Best Before Date',
      'Batch Number / Lot Identification',
      'Date of Manufacture',
    ],
    manufacturerName: 'Silk Herbals Care India Pvt. Ltd.',
    manufacturerAddress:
      'Industrial Area Phase 2, Baddi, Solan - 173205, Himachal Pradesh, India',
    consumerCareDetails: 'care@silkhaircare.in | +91 98765 43210',
    countryOfOrigin: 'India',
    complianceScore: 35,
    notes:
      'CRITICAL VIOLATION: Packaged without mandatory Expiry Date, Manufacturing Date, and Batch Number in direct contravention of Rule 6 of Legal Metrology (Packaged Commodities) Rules, 2011 and Drugs & Cosmetics Rules, 1945.',
  },
  alternatives: [
    {
      id: 'alt-derma-001',
      name: '1% Salicylic Acid Anti-Dandruff Shampoo',
      brand: 'The Derma Co',
      category: 'cosmetic',
      score: 88,
      ratingTier: 'good',
      mrp: '₹349.00',
      netQuantity: '250ml',
      highlightReason:
        '100% Sulfate & Paraben Free formulation. Powered by Salicylic Acid & Zinc Pyrithione to gently exfoliate dry flakes without stripping the scalp barrier.',
      imageUrl:
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=400&q=80',
    },
    {
      id: 'alt-bare-002',
      name: 'Expert Anti-Dandruff Scalp Shampoo',
      brand: 'Bare Anatomy',
      category: 'cosmetic',
      score: 93,
      ratingTier: 'excellent',
      mrp: '₹449.00',
      netQuantity: '250ml',
      highlightReason:
        'Clean beauty certified, sulfate-free & silicone-free. Powered by Piroctone Olamine & Salicylic Acid with 0 endocrine-disrupting chemicals.',
      imageUrl:
        'https://images.unsplash.com/photo-1608248597359-5980a375a065?auto=format&fit=crop&w=400&q=80',
    },
  ],
  scannedAt: '2026-11-22T10:05:00Z',
  packVerified: false,
};

/**
 * Array of mock products for search and lookup.
 */
export const mockProducts: ProductAnalysis[] = [
  mockFoodProduct,
  mockCosmeticProduct,
];

/**
 * 18+ Comprehensive Indian & Global Hazard Ingredients for Admin Catalog
 */
export const initialHazardIngredients: HazardIngredient[] = [
  {
    id: 'haz-001',
    name: 'Sodium Laureth Sulfate (SLES)',
    aliases: ['SLES', 'Sodium Lauryl Ether Sulfate', 'Sulfated Ethoxylated Alcohol'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'CIR / BIS IS 7884',
    reason: 'Aggressive anionic surfactant causing scalp irritation, lipid barrier breakdown, and 1,4-Dioxane risk.',
    scientificDetails: 'Alters cutaneous barrier permeability, strips natural ceramides from hair follicles.',
  },
  {
    id: 'haz-002',
    name: 'Methylparaben',
    aliases: ['Methyl 4-hydroxybenzoate', 'E218', 'Nipagin M'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'EU SCCS / CDSCO',
    reason: 'Estrogenic endocrine disruptor; bioaccumulates in glandular tissues and induces hypersensitivity.',
    eNumber: 'INS 218',
    scientificDetails: 'Demonstrates estrogen receptor alpha (ERα) binding in clinical tissue biopsies.',
  },
  {
    id: 'haz-003',
    name: 'Propylparaben',
    aliases: ['Propyl 4-hydroxybenzoate', 'E216', 'Nipasol'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'CIR / EU Annex V',
    reason: 'Longer alkyl chain paraben linked to hormone disruption and reproductive toxicity.',
    eNumber: 'INS 216',
    scientificDetails: 'Reproductive endocrine disruptor banned in diaper area leave-on products in EU.',
  },
  {
    id: 'haz-004',
    name: 'Tartrazine (CI 19140 / Yellow 5)',
    aliases: ['FD&C Yellow No. 5', 'E102', 'Acid Yellow 23'],
    category: 'food',
    hazardLevel: 'moderate',
    regulatorySource: 'FSSAI / US FDA',
    reason: 'Synthetic azo dye known to trigger hyperactivity in children and severe urticaria in asthmatics.',
    eNumber: 'INS 102',
    scientificDetails: 'Promotes histamine release in sensitized individuals; subject to warning label in EU.',
  },
  {
    id: 'haz-005',
    name: 'Titanium Dioxide (E171 / CI 77891)',
    aliases: ['Titania', 'E171', 'Pigment White 6'],
    category: 'food',
    hazardLevel: 'high',
    regulatorySource: 'EU EFSA / FSSAI Review',
    reason: 'Nanoparticle accumulation in intestinal mucosa; classified as no longer safe as a food additive by EFSA.',
    eNumber: 'INS 171',
    scientificDetails: 'Evidence of genotoxicity through DNA strand breaks in gastrointestinal tract.',
  },
  {
    id: 'haz-006',
    name: 'Potassium Bromate',
    aliases: ['E924a', 'Bromated Flour Additive'],
    category: 'food',
    hazardLevel: 'high',
    regulatorySource: 'FSSAI Banned (2016)',
    reason: 'Recognized Group 2B carcinogen; completely banned by FSSAI for use in bakery and flour processing.',
    eNumber: 'INS 924a',
    scientificDetails: 'Potent oxidative agent inducing renal cell tumors and cellular chromosomal aberrations.',
  },
  {
    id: 'haz-007',
    name: 'Monosodium Glutamate (MSG)',
    aliases: ['MSG', 'E621', 'Sodium Glutamate', 'Ajinomoto'],
    category: 'food',
    hazardLevel: 'moderate',
    regulatorySource: 'FSSAI Standard Regulations',
    reason: 'High excitotoxin causing headache, flushing, and sweating in glutamate-sensitive individuals.',
    eNumber: 'INS 621',
    scientificDetails: 'Overstimulates glutamate NMDA receptors; prohibited in food infant formulations.',
  },
  {
    id: 'haz-008',
    name: 'High Fructose Corn Syrup (HFCS)',
    aliases: ['Glucose-Fructose Syrup', 'Isoglucose', 'HFCS-55'],
    category: 'food',
    hazardLevel: 'moderate',
    regulatorySource: 'Codex Alimentarius / WHO',
    reason: 'Bypasses hepatic insulin signaling, driving non-alcoholic fatty liver disease (NAFLD) and insulin resistance.',
    scientificDetails: 'Accelerates de novo lipogenesis directly in hepatocytes.',
  },
  {
    id: 'haz-009',
    name: 'Partially Hydrogenated Palm Oil',
    aliases: ['Industrial Trans Fat', 'Hydrogenated Vegetable Oil', 'Vanaspati'],
    category: 'food',
    hazardLevel: 'high',
    regulatorySource: 'WHO REPLACE / FSSAI (max 2%)',
    reason: 'Primary dietary contributor to coronary artery disease, elevated LDL cholesterol, and vascular inflammation.',
    scientificDetails: 'Induces systemic arterial endothelial dysfunction and suppresses anti-inflammatory HDL.',
  },
  {
    id: 'haz-010',
    name: 'Aspartame',
    aliases: ['E951', 'NutraSweet', 'Equal', 'APM'],
    category: 'food',
    hazardLevel: 'moderate',
    regulatorySource: 'WHO IARC Group 2B / FSSAI',
    reason: 'Artificial non-saccharide sweetener categorized as possibly carcinogenic to humans by WHO IARC in 2023.',
    eNumber: 'INS 951',
    scientificDetails: 'Metabolizes into phenylalanine, aspartic acid, and free methanol in the gut.',
  },
  {
    id: 'haz-011',
    name: 'Butylated Hydroxytoluene (BHT)',
    aliases: ['E321', 'BHT Preservative', '2,6-di-tert-butyl-4-methylphenol'],
    category: 'cosmetic',
    hazardLevel: 'moderate',
    regulatorySource: 'CIR / FSSAI Guidelines',
    reason: 'Synthetic phenolic antioxidant suspected of hepatic strain and endocrine perturbation.',
    eNumber: 'INS 321',
    scientificDetails: 'Shows weak estrogenic activity and pulmonary tissue toxic accumulation in animal bioassays.',
  },
  {
    id: 'haz-012',
    name: 'DMDM Hydantoin',
    aliases: ['Formaldehyde Releaser', 'Glydant', 'Dimethylol Dimethyl Hydantoin'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'EU SCCS / INCI Standard',
    reason: 'Slow-releasing formaldehyde preservative; high sensitization rate leading to chronic eczema.',
    scientificDetails: 'Releases free aqueous formaldehyde to inhibit bacteria, triggering severe type IV allergic reactions.',
  },
  {
    id: 'haz-013',
    name: 'Triclosan',
    aliases: ['TCS', '5-chloro-2-(2,4-dichlorophenoxy)phenol', 'Irgasan'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'US FDA Banned / BIS IS 4011',
    reason: 'Antibacterial agent linked to antibiotic resistance, thyroid disruption, and bioaccumulation in aquatic life.',
    scientificDetails: 'Perturbs thyroid hormone receptor and deiodinase activity; banned in OTC antiseptic soaps.',
  },
  {
    id: 'haz-014',
    name: 'Oxybenzone (Benzophenone-3)',
    aliases: ['BP-3', '2-hydroxy-4-methoxybenzophenone', 'Uvinul M40'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'Hawaii Reef Act / CIR',
    reason: 'Chemical sunscreen filter absorbing deeply into bloodstream; toxic to coral marine ecosystems and endocrine systems.',
    scientificDetails: 'Detected in 96% of human urine samples; induces coral bleaching at parts-per-trillion levels.',
  },
  {
    id: 'haz-015',
    name: 'Synthetic Fragrance (Parfum)',
    aliases: ['Parfum', 'Fragrance Oil', 'Aroma Blend'],
    category: 'cosmetic',
    hazardLevel: 'moderate',
    regulatorySource: 'IFRA / INCI Standards',
    reason: 'Proprietary cocktail frequently concealing undisclosed phthalates (DEP) and contact allergens.',
    scientificDetails: 'Top cause of cosmetic contact allergy, containing known sensitizers like citral, linalool, and limonene.',
  },
  {
    id: 'haz-016',
    name: 'Sodium Benzoate',
    aliases: ['E211', 'Benzoate of Soda'],
    category: 'food',
    hazardLevel: 'moderate',
    regulatorySource: 'FSSAI Food Additives Rule',
    reason: 'When combined with Ascorbic Acid (Vitamin C), forms Benzene—a known Class 1 human carcinogen.',
    eNumber: 'INS 211',
    scientificDetails: 'Decarboxylation reaction catalyzed by heat and UV light generates trace benzene.',
  },
  {
    id: 'haz-017',
    name: 'Dimethicone (Polydimethylsiloxane)',
    aliases: ['PDMS', 'Dimethicone Copolyol', 'Silicone Oil'],
    category: 'cosmetic',
    hazardLevel: 'low',
    regulatorySource: 'EU REACH / INCI',
    reason: 'Non-biodegradable synthetic occlusive coating scalp pores and causing persistent environmental persistence.',
    scientificDetails: 'High molecular weight siloxane resisting wastewater biodegradation; traps follicular sebum.',
  },
  {
    id: 'haz-018',
    name: 'Coal Tar Dyes (CI 77266 / D&C Black No. 2)',
    aliases: ['Carbon Black', 'CI 77266', 'Acetylene Black'],
    category: 'cosmetic',
    hazardLevel: 'high',
    regulatorySource: 'US FDA / CIR Panel',
    reason: 'Heavy-hydrocarbon byproduct containing polycyclic aromatic hydrocarbons (PAHs) with carcinogenic potential.',
    scientificDetails: 'Contaminated with trace benzo[a]pyrene unless purified under rigorous FDA carbon black criteria.',
  },
];

/**
 * Realistic Indian scan history items.
 */
export const mockScanHistory: ScanHistoryItem[] = [
  {
    id: 'hist-001',
    productId: 'prod-amul-taaza-001',
    productName: 'Amul Taaza Pasteurised Toned Milk',
    brand: 'Amul',
    category: 'food',
    score: 92,
    ratingTier: 'excellent',
    ratingLabel: 'Excellent',
    isCompliant: true,
    flaggedCount: 1,
    timestamp: 'Today, 09:15 AM',
    thumbnailUrl:
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=200&q=80',
  },
  {
    id: 'hist-002',
    productId: 'prod-herbal-silk-002',
    productName: 'Herbal Silk Anti-Dandruff Shampoo',
    brand: 'Herbal Silk',
    category: 'cosmetic',
    score: 38,
    ratingTier: 'poor',
    ratingLabel: 'Poor / Risky',
    isCompliant: false,
    flaggedCount: 3,
    timestamp: 'Today, 10:05 AM',
    thumbnailUrl:
      'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=200&q=80',
  },
  {
    id: 'hist-003',
    productId: 'alt-cd-001',
    productName: 'Pure Desi Cow Milk',
    brand: 'Country Delight',
    category: 'food',
    score: 96,
    ratingTier: 'excellent',
    ratingLabel: 'Excellent',
    isCompliant: true,
    flaggedCount: 0,
    timestamp: 'Yesterday, 04:30 PM',
    thumbnailUrl:
      'https://images.unsplash.com/photo-1527153857715-3908f2ae5e81?auto=format&fit=crop&w=200&q=80',
  },
  {
    id: 'hist-004',
    productId: 'alt-derma-001',
    productName: '1% Salicylic Acid Anti-Dandruff Shampoo',
    brand: 'The Derma Co',
    category: 'cosmetic',
    score: 88,
    ratingTier: 'good',
    ratingLabel: 'Good',
    isCompliant: true,
    flaggedCount: 0,
    timestamp: '20 Nov 2026',
    thumbnailUrl:
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=200&q=80',
  },
];

/**
 * Realistic default user profile with personal health allergen sensitivities
 */
export const mockUserProfile: UserProfile = {
  id: 'usr-indian-health-01',
  name: 'ABC',
  email: 'abc@safescan.ai',
  avatar:
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
  role: 'user',
  skinType: 'Scalp-Sensitive & Allergy-Prone',
  dietaryPreferences: ['Vegetarian (Green Dot)', 'Sugar-Conscious', 'High Calcium'],
  allergies: [
    'Sulfates (SLES / SLS)',
    'Parabens (Methyl / Propyl)',
    'Artificial Azo Dyes (CI 19140)',
  ],
  scansCount: 42,
  savedAlternativesCount: 14,
  createdAt: '2026-08-15T00:00:00Z',
};

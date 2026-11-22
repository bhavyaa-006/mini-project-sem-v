import React, { useState } from 'react';
import { mockUserProfile } from '../mockData';
import type { UserProfile } from '../types/api';
import {
  User,
  Shield,
  Heart,
  AlertCircle,
  Check,
  Save,
  Award,
} from 'lucide-react';

export const ProfileView: React.FC = () => {
  const [profile, setProfile] = useState<UserProfile>(mockUserProfile);
  const [savedSuccess, setSavedSuccess] = useState(false);

  // Available dietary & allergy tags common in Indian consumer context
  const availableDiets = [
    'Vegetarian (Green Dot)',
    'Vegan',
    'Lactose-Conscious',
    'Sugar-Conscious',
    'High Calcium',
    'Gluten-Free',
    'Jain Dietary Standard',
    'Low Sodium (Hypertension)',
  ];

  const availableAllergens = [
    'Sulfates (SLES / SLS)',
    'Parabens (Methyl / Propyl)',
    'Synthetic Fragrance (Parfum)',
    'Artificial Azo Dyes (CI 19140)',
    'Peanuts / Groundnuts',
    'Tree Nuts (Almond / Cashew)',
    'Dairy Milk Proteins',
    'Soy Lecithin',
  ];

  const toggleDiet = (diet: string) => {
    setProfile((prev) => {
      const exists = prev.dietaryPreferences.includes(diet);
      return {
        ...prev,
        dietaryPreferences: exists
          ? prev.dietaryPreferences.filter((d) => d !== diet)
          : [...prev.dietaryPreferences, diet],
      };
    });
  };

  const toggleAllergen = (allergen: string) => {
    setProfile((prev) => {
      const exists = prev.allergies.includes(allergen);
      return {
        ...prev,
        allergies: exists
          ? prev.allergies.filter((a) => a !== allergen)
          : [...prev.allergies, allergen],
      };
    });
  };

  const handleSave = () => {
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 2500);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
      {/* Header */}
      <div>
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-[#27AE60]/10 text-[#1E8449] border border-[#27AE60]/20 mb-1.5">
          <User className="w-3.5 h-3.5" />
          <span>Consumer Health Profile</span>
        </div>
        <h1 className="text-2xl sm:text-3xl font-extrabold text-neutral-900 tracking-tight">
          Personal Preferences &amp; Allergen Alerts
        </h1>
        <p className="text-xs sm:text-sm text-neutral-500 mt-1">
          Customize ingredient warnings and tailored product alternatives for your household.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        {/* Left Column: User Card & Stats */}
        <div className="lg:col-span-4 space-y-6">
          <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs flex flex-col items-center text-center">
            <div className="relative mb-4">
              <div className="w-24 h-24 rounded-3xl bg-gradient-to-br from-[#27AE60] to-[#1E8449] text-white flex items-center justify-center text-3xl font-black ring-4 ring-[#27AE60]/20 border-2 border-white shadow-md tracking-wider">
                AB
              </div>
              <span className="absolute -bottom-1 -right-1 w-7 h-7 rounded-full bg-[#27AE60] text-white flex items-center justify-center text-xs shadow-xs border-2 border-white">
                ✓
              </span>
            </div>

            <h2 className="text-lg font-bold text-neutral-900">{profile.name}</h2>
            <p className="text-xs text-neutral-500 font-medium">{profile.email}</p>

            <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold bg-[#27AE60]/10 text-[#1E8449] mt-3">
              <Shield className="w-3 h-3" />
              Verified SafeScan Consumer
            </span>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 gap-3 w-full mt-6 pt-6 border-t border-neutral-100">
              <div className="p-3 bg-[#F9FAF8] rounded-2xl border border-neutral-200/60">
                <span className="text-[10px] uppercase font-bold text-neutral-400 block">
                  Packs Scanned
                </span>
                <span className="text-2xl font-black text-neutral-900">
                  {profile.scansCount}
                </span>
              </div>

              <div className="p-3 bg-[#F9FAF8] rounded-2xl border border-neutral-200/60">
                <span className="text-[10px] uppercase font-bold text-neutral-400 block">
                  Clean Alternatives
                </span>
                <span className="text-2xl font-black text-[#1E8449]">
                  {profile.savedAlternativesCount || 14}
                </span>
              </div>
            </div>

            <div className="w-full mt-4 p-3 bg-emerald-50/60 rounded-xl border border-emerald-100 text-left text-xs text-emerald-900 flex items-start gap-2">
              <Award className="w-4 h-4 text-[#27AE60] shrink-0 mt-0.5" />
              <span>
                <strong>Smart Shopper Badge:</strong> You've avoided 28 high-risk additives this month!
              </span>
            </div>
          </div>
        </div>

        {/* Right Column: Preferences & Allergens Configuration */}
        <div className="lg:col-span-8 space-y-6">
          {/* Dietary Restrictions */}
          <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs space-y-4">
            <div>
              <h3 className="text-sm font-bold text-neutral-900 tracking-tight flex items-center gap-2">
                <Heart className="w-4 h-4 text-[#27AE60]" />
                <span>Dietary Choices &amp; Nutritional Goals</span>
              </h3>
              <p className="text-xs text-neutral-500 mt-0.5">
                SafeScan highlights products matching your dietary principles automatically.
              </p>
            </div>

            <div className="flex flex-wrap gap-2 pt-1">
              {availableDiets.map((diet) => {
                const isSelected = profile.dietaryPreferences.includes(diet);
                return (
                  <button
                    key={diet}
                    type="button"
                    onClick={() => toggleDiet(diet)}
                    className={`inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
                      isSelected
                        ? 'bg-[#27AE60] text-white shadow-xs'
                        : 'bg-[#F9FAF8] text-neutral-700 border border-neutral-200 hover:border-neutral-300'
                    }`}
                  >
                    {isSelected && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                    <span>{diet}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Allergen & Chemical Sensitivity Alerts */}
          <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs space-y-4">
            <div>
              <h3 className="text-sm font-bold text-neutral-900 tracking-tight flex items-center gap-2">
                <AlertCircle className="w-4 h-4 text-[#E74C3C]" />
                <span>Allergen &amp; Chemical Irritant Alerts</span>
              </h3>
              <p className="text-xs text-neutral-500 mt-0.5">
                Instantly flags ingredient labels containing ingredients you wish to avoid.
              </p>
            </div>

            <div className="flex flex-wrap gap-2 pt-1">
              {availableAllergens.map((allergen) => {
                const isSelected = profile.allergies.includes(allergen);
                return (
                  <button
                    key={allergen}
                    type="button"
                    onClick={() => toggleAllergen(allergen)}
                    className={`inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all ${
                      isSelected
                        ? 'bg-[#E74C3C] text-white shadow-xs'
                        : 'bg-[#F9FAF8] text-neutral-700 border border-neutral-200 hover:border-neutral-300'
                    }`}
                  >
                    {isSelected && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                    <span>{allergen}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Action Button */}
          <div className="flex items-center justify-between pt-2">
            {savedSuccess ? (
              <span className="text-xs font-bold text-[#1E8449] flex items-center gap-1.5 animate-in fade-in">
                <Check className="w-4 h-4 text-[#27AE60]" />
                Profile preferences updated successfully!
              </span>
            ) : (
              <span className="text-xs text-neutral-400">
                Changes apply immediately to live scanner OCR checks.
              </span>
            )}

            <button
              type="button"
              onClick={handleSave}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all active:scale-[0.98]"
            >
              <Save className="w-4 h-4" />
              <span>Save Health Profile</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfileView;

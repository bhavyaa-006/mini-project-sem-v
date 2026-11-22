import React, { useState } from 'react';
import {
  ShieldAlert,
  ShieldCheck,
  FileSpreadsheet,
  AlertOctagon,
  Scale,
  CheckCircle,
  Building,
  AlertTriangle,
  AlertCircle,
  Plus,
  Edit2,
  Trash2,
  Search,
  X,
  Save,
  Database,
} from 'lucide-react';
import { mockCosmeticProduct, mockFoodProduct, initialHazardIngredients } from '../mockData';
import type { HazardIngredient, HazardLevel, ProductCategory } from '../types/api';

export const AdminView: React.FC = () => {
  // Hazard Ingredients Catalog State (18+ Indian & Global items)
  const [ingredients, setIngredients] = useState<HazardIngredient[]>(initialHazardIngredients);

  // Search & Filters
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState<'all' | 'food' | 'cosmetic'>('all');
  const [hazardFilter, setHazardFilter] = useState<'all' | 'high' | 'moderate' | 'low'>('all');

  // Modal State for Add & Edit
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingIngredient, setEditingIngredient] = useState<HazardIngredient | null>(null);

  // Form Fields
  const [formName, setFormName] = useState('');
  const [formAliases, setFormAliases] = useState('');
  const [formCategory, setFormCategory] = useState<ProductCategory>('cosmetic');
  const [formHazardLevel, setFormHazardLevel] = useState<HazardLevel>('high');
  const [formSource, setFormSource] = useState('FSSAI');
  const [formReason, setFormReason] = useState('');
  const [formScientific, setFormScientific] = useState('');
  const [formError, setFormError] = useState<string | null>(null);
  const [notification, setNotification] = useState<string | null>(null);

  // Filtered ingredients
  const filteredIngredients = ingredients.filter((item) => {
    const matchesSearch =
      item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.aliases.some((a) => a.toLowerCase().includes(searchQuery.toLowerCase())) ||
      item.reason.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory =
      categoryFilter === 'all' || item.category === categoryFilter;

    const matchesHazard =
      hazardFilter === 'all' || item.hazardLevel === hazardFilter;

    return matchesSearch && matchesCategory && matchesHazard;
  });

  const handleOpenAddModal = () => {
    setEditingIngredient(null);
    setFormName('');
    setFormAliases('');
    setFormCategory('cosmetic');
    setFormHazardLevel('high');
    setFormSource('FSSAI');
    setFormReason('');
    setFormScientific('');
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleOpenEditModal = (item: HazardIngredient) => {
    setEditingIngredient(item);
    setFormName(item.name);
    setFormAliases(item.aliases.join(', '));
    setFormCategory(item.category);
    setFormHazardLevel(item.hazardLevel);
    setFormSource(item.regulatorySource);
    setFormReason(item.reason);
    setFormScientific(item.scientificDetails || '');
    setFormError(null);
    setIsModalOpen(true);
  };

  const handleSaveModal = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim() || !formReason.trim()) {
      setFormError('Ingredient name and regulatory risk reason are mandatory.');
      return;
    }

    const aliasesArray = formAliases
      .split(',')
      .map((a) => a.trim())
      .filter((a) => a.length > 0);

    if (editingIngredient) {
      // Edit existing
      setIngredients((prev) =>
        prev.map((item) =>
          item.id === editingIngredient.id
            ? {
                ...item,
                name: formName.trim(),
                aliases: aliasesArray,
                category: formCategory,
                hazardLevel: formHazardLevel,
                regulatorySource: formSource.trim(),
                reason: formReason.trim(),
                scientificDetails: formScientific.trim() || undefined,
              }
            : item
        )
      );
      setNotification(`Updated hazard ingredient "${formName.trim()}" successfully.`);
    } else {
      // Add new
      const newIngredient: HazardIngredient = {
        id: `haz-${Date.now()}`,
        name: formName.trim(),
        aliases: aliasesArray,
        category: formCategory,
        hazardLevel: formHazardLevel,
        regulatorySource: formSource.trim(),
        reason: formReason.trim(),
        scientificDetails: formScientific.trim() || undefined,
      };
      setIngredients((prev) => [newIngredient, ...prev]);
      setNotification(`Added new hazard ingredient "${formName.trim()}" to database.`);
    }

    setIsModalOpen(false);
    setTimeout(() => setNotification(null), 3000);
  };

  const handleDelete = (id: string, name: string) => {
    if (confirm(`Remove "${name}" from the active hazard database?`)) {
      setIngredients((prev) => prev.filter((item) => item.id !== id));
      setNotification(`Deleted "${name}" from database.`);
      setTimeout(() => setNotification(null), 3000);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8 font-sans">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-[#1E8449]/10 text-[#1E8449] border border-[#1E8449]/20 mb-1.5">
            <ShieldAlert className="w-3.5 h-3.5" />
            <span>Legal Metrology &amp; Statutory Compliance Hub</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-neutral-900 tracking-tight">
            PackCheck AI Administration
          </h1>
          <p className="text-xs sm:text-sm text-neutral-500 mt-1">
            Real-time compliance monitoring under Legal Metrology (Packaged Commodities) Rules, 2011 &amp; FSSAI.
          </p>
        </div>

        <button
          type="button"
          onClick={() => alert('Generating Legal Metrology Compliance Audit Report (PDF/CSV)...')}
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all self-start sm:self-auto"
        >
          <FileSpreadsheet className="w-4 h-4" />
          <span>Export Audit Log</span>
        </button>
      </div>

      {notification && (
        <div className="p-3.5 rounded-xl bg-emerald-50 text-[#1E8449] text-xs font-bold flex items-center gap-2 animate-in fade-in border border-emerald-200 shadow-2xs">
          <CheckCircle className="w-4 h-4 text-[#27AE60]" />
          <span>{notification}</span>
        </div>
      )}

      {/* KPI Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-5 rounded-2xl bg-white border border-neutral-200/80 shadow-xs">
          <div className="flex items-center justify-between text-neutral-400 mb-2">
            <span className="text-xs font-bold uppercase tracking-wider">Total Scans Audited</span>
            <Scale className="w-4 h-4 text-neutral-500" />
          </div>
          <div className="text-3xl font-black text-neutral-900">1,248</div>
          <p className="text-[11px] text-[#1E8449] font-semibold mt-1">
            +18% automated audits this week
          </p>
        </div>

        <div className="p-5 rounded-2xl bg-white border border-neutral-200/80 shadow-xs">
          <div className="flex items-center justify-between text-neutral-400 mb-2">
            <span className="text-xs font-bold uppercase tracking-wider">PCR 2011 Compliance</span>
            <ShieldCheck className="w-4 h-4 text-[#27AE60]" />
          </div>
          <div className="text-3xl font-black text-[#1E8449]">82.4%</div>
          <p className="text-[11px] text-neutral-500 mt-1">
            17.6% missing mandatory declarations
          </p>
        </div>

        <div className="p-5 rounded-2xl bg-white border border-neutral-200/80 shadow-xs">
          <div className="flex items-center justify-between text-neutral-400 mb-2">
            <span className="text-xs font-bold uppercase tracking-wider">Omitted Expiry Dates</span>
            <AlertOctagon className="w-4 h-4 text-[#E74C3C]" />
          </div>
          <div className="text-3xl font-black text-[#E74C3C]">47</div>
          <p className="text-[11px] text-rose-600 font-semibold mt-1">
            Flagged for statutory review
          </p>
        </div>

        <div className="p-5 rounded-2xl bg-white border border-neutral-200/80 shadow-xs">
          <div className="flex items-center justify-between text-neutral-400 mb-2">
            <span className="text-xs font-bold uppercase tracking-wider">Active Hazard Chemicals</span>
            <Database className="w-4 h-4 text-[#2ECC71]" />
          </div>
          <div className="text-3xl font-black text-neutral-900">{ingredients.length}</div>
          <p className="text-[11px] text-[#1E8449] font-semibold mt-1">
            Indian &amp; Global databases synced
          </p>
        </div>
      </div>

      {/* EDITABLE HAZARD-INGREDIENT TABLE (15+ Indian & Global Ingredients) */}
      <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h3 className="text-sm sm:text-base font-bold text-neutral-900 tracking-tight flex items-center gap-2">
              <Database className="w-4 h-4 text-[#27AE60]" />
              <span>Hazard Ingredient Reference Database ({ingredients.length} Total)</span>
            </h3>
            <p className="text-xs text-neutral-500 mt-0.5">
              Authoritative toxicological rules enforced during barcode lookup &amp; OCR text analysis.
            </p>
          </div>

          <button
            type="button"
            onClick={handleOpenAddModal}
            className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-xs font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-xs transition-all active:scale-[0.98] self-start sm:self-auto"
          >
            <Plus className="w-4 h-4" />
            <span>+ Add Ingredient</span>
          </button>
        </div>

        {/* Search & Filter Bar */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-3 pt-1">
          {/* Search Box */}
          <div className="md:col-span-6 relative">
            <Search className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Search ingredient by name, aliases (e.g., SLES, Tartrazine, BHT)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 text-xs rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] transition-all"
            />
          </div>

          {/* Category Filter */}
          <div className="md:col-span-3">
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value as 'all' | ProductCategory)}
              className="w-full px-3 py-2 text-xs rounded-xl border border-neutral-200 bg-[#F9FAF8] text-neutral-700 font-medium focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
            >
              <option value="all">All Categories</option>
              <option value="food">Food Additives</option>
              <option value="cosmetic">Cosmetic Chemicals</option>
            </select>
          </div>

          {/* Hazard Level Filter */}
          <div className="md:col-span-3">
            <select
              value={hazardFilter}
              onChange={(e) => setHazardFilter(e.target.value as 'all' | 'high' | 'moderate' | 'low')}
              className="w-full px-3 py-2 text-xs rounded-xl border border-neutral-200 bg-[#F9FAF8] text-neutral-700 font-medium focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
            >
              <option value="all">All Hazard Levels</option>
              <option value="high">High Risk</option>
              <option value="moderate">Moderate Risk</option>
              <option value="low">Low Risk</option>
            </select>
          </div>
        </div>

        {/* Table of Ingredients */}
        <div className="overflow-x-auto rounded-2xl border border-neutral-200/80">
          <table className="w-full text-left text-xs text-neutral-700">
            <thead className="bg-[#F9FAF8] text-neutral-500 font-bold uppercase text-[10px] tracking-wider border-b border-neutral-200">
              <tr>
                <th className="py-3 px-4">Ingredient &amp; Aliases</th>
                <th className="py-3 px-4">Category</th>
                <th className="py-3 px-4">Hazard Level</th>
                <th className="py-3 px-4">Regulatory Source</th>
                <th className="py-3 px-4">Toxicological Reason</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-neutral-100 bg-white">
              {filteredIngredients.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-neutral-400">
                    No hazard ingredients found matching "{searchQuery}".
                  </td>
                </tr>
              ) : (
                filteredIngredients.map((item) => (
                  <tr key={item.id} className="hover:bg-neutral-50/70 transition-colors">
                    <td className="py-3 px-4">
                      <div className="font-bold text-neutral-900">{item.name}</div>
                      {item.aliases.length > 0 && (
                        <div className="text-[11px] text-neutral-400 truncate max-w-xs mt-0.5">
                          aka {item.aliases.join(', ')}
                        </div>
                      )}
                    </td>

                    <td className="py-3 px-4">
                      <span className="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md bg-neutral-100 text-neutral-600">
                        {item.category}
                      </span>
                    </td>

                    <td className="py-3 px-4">
                      <span
                        className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                          item.hazardLevel === 'high'
                            ? 'bg-rose-100 text-rose-800'
                            : item.hazardLevel === 'moderate'
                            ? 'bg-amber-100 text-amber-800'
                            : 'bg-emerald-100 text-emerald-800'
                        }`}
                      >
                        {item.hazardLevel.toUpperCase()}
                      </span>
                    </td>

                    <td className="py-3 px-4 font-mono text-[11px] text-[#1E8449] font-semibold">
                      {item.regulatorySource}
                    </td>

                    <td className="py-3 px-4 text-neutral-600 max-w-sm text-[11px] leading-relaxed">
                      {item.reason}
                    </td>

                    <td className="py-3 px-4 text-right">
                      <div className="inline-flex items-center gap-1.5 justify-end">
                        <button
                          type="button"
                          onClick={() => handleOpenEditModal(item)}
                          className="p-1.5 text-neutral-500 hover:text-[#1E8449] hover:bg-emerald-50 rounded-lg transition-colors"
                          title="Edit Ingredient"
                        >
                          <Edit2 className="w-3.5 h-3.5" />
                        </button>
                        <button
                          type="button"
                          onClick={() => handleDelete(item.id, item.name)}
                          className="p-1.5 text-neutral-500 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"
                          title="Delete Ingredient"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Flagged Package Violations Table */}
      <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs space-y-4">
        <div>
          <h3 className="text-sm font-bold text-neutral-900 tracking-tight flex items-center gap-2">
            <AlertTriangle className="w-4 h-4 text-[#E74C3C]" />
            <span>Flagged Package Violations (Rule 6, PCR 2011)</span>
          </h3>
          <p className="text-xs text-neutral-500 mt-0.5">
            Consumer packages detected with missing or illegible statutory declarations.
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-neutral-700">
            <thead className="bg-[#F9FAF8] text-neutral-500 font-bold uppercase text-[10px] tracking-wider border-y border-neutral-200/80">
              <tr>
                <th className="py-3 px-4">Product Name</th>
                <th className="py-3 px-4">Brand</th>
                <th className="py-3 px-4">Category</th>
                <th className="py-3 px-4">Violation Details</th>
                <th className="py-3 px-4">MRP &amp; Net Qty</th>
                <th className="py-3 px-4">Compliance Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-neutral-100">
              <tr className="hover:bg-rose-50/30 transition-colors">
                <td className="py-3 px-4 font-bold text-neutral-900">
                  {mockCosmeticProduct.name}
                </td>
                <td className="py-3 px-4">{mockCosmeticProduct.brand}</td>
                <td className="py-3 px-4 uppercase text-[10px] font-bold text-neutral-500">
                  {mockCosmeticProduct.category}
                </td>
                <td className="py-3 px-4 text-rose-700 font-semibold">
                  Missing Expiry Date &amp; Batch No.
                </td>
                <td className="py-3 px-4">
                  {mockCosmeticProduct.legalMetrology.mrp} • {mockCosmeticProduct.legalMetrology.netQuantity}
                </td>
                <td className="py-3 px-4">
                  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-100 text-rose-800">
                    Non-Compliant
                  </span>
                </td>
              </tr>

              <tr className="hover:bg-emerald-50/30 transition-colors">
                <td className="py-3 px-4 font-bold text-neutral-900">
                  {mockFoodProduct.name}
                </td>
                <td className="py-3 px-4">{mockFoodProduct.brand}</td>
                <td className="py-3 px-4 uppercase text-[10px] font-bold text-neutral-500">
                  {mockFoodProduct.category}
                </td>
                <td className="py-3 px-4 text-[#1E8449] font-medium">
                  None (Full Declarations Present)
                </td>
                <td className="py-3 px-4">
                  {mockFoodProduct.legalMetrology.mrp} • {mockFoodProduct.legalMetrology.netQuantity}
                </td>
                <td className="py-3 px-4">
                  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800">
                    100% Compliant
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Mandatory Statutory Checklist */}
      <div className="bg-white rounded-3xl border border-neutral-200/80 p-6 shadow-xs space-y-4">
        <div>
          <h3 className="text-sm font-bold text-neutral-900 tracking-tight flex items-center gap-2">
            <Building className="w-4 h-4 text-[#1E8449]" />
            <span>Legal Metrology (Packaged Commodities) Rules 2011 - Rule 6 Checklist</span>
          </h3>
          <p className="text-xs text-neutral-500 mt-0.5">
            Automated OCR rule validation pipeline enforced on every camera upload.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 text-xs">
          {[
            { rule: 'Rule 6(1)(a)', label: 'Name and address of Manufacturer / Packer / Importer' },
            { rule: 'Rule 6(1)(b)', label: 'Common or generic name of commodity contained' },
            { rule: 'Rule 6(1)(c)', label: 'Net quantity in standard units of weight or measure' },
            { rule: 'Rule 6(1)(d)', label: 'Month and year of manufacture or pre-packing' },
            { rule: 'Rule 6(1)(da)', label: 'Expiry / Best Before date for perishable commodities' },
            { rule: 'Rule 6(1)(e)', label: 'Maximum Retail Price (MRP inclusive of all taxes)' },
            { rule: 'Rule 6(1)(f)', label: 'Dimensions of commodity where relevant' },
            { rule: 'Rule 6(1)(n)', label: 'Name, address, telephone, email of Consumer Care' },
            { rule: 'FSSAI Mandate', label: '14-digit FSSAI License Number & Logo on Food Packs' },
          ].map((item, idx) => (
            <div
              key={idx}
              className="p-3 bg-[#F9FAF8] rounded-xl border border-neutral-200/70 flex items-start gap-2.5"
            >
              <div className="w-5 h-5 rounded-full bg-[#27AE60]/15 text-[#1E8449] flex items-center justify-center font-bold text-[10px] shrink-0 mt-0.5">
                ✓
              </div>
              <div>
                <span className="font-mono text-[10px] font-bold text-[#1E8449] block">
                  {item.rule}
                </span>
                <span className="text-neutral-700 font-medium leading-tight">
                  {item.label}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ADD / EDIT HAZARD INGREDIENT MODAL DIALOG */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-neutral-900/50 backdrop-blur-xs animate-in fade-in duration-150">
          <div className="bg-white rounded-3xl border border-neutral-200 shadow-xl max-w-lg w-full p-6 space-y-4 animate-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
              <h3 className="text-base font-extrabold text-neutral-900 tracking-tight flex items-center gap-2">
                <Database className="w-4 h-4 text-[#27AE60]" />
                <span>{editingIngredient ? 'Edit Hazard Ingredient' : 'Add New Hazard Ingredient'}</span>
              </h3>
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-lg text-neutral-400 hover:text-neutral-700 hover:bg-neutral-100"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveModal} className="space-y-3.5 text-xs">
              {formError && (
                <div className="p-2.5 rounded-xl bg-rose-50 text-rose-800 border border-rose-200 flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
                  <span>{formError}</span>
                </div>
              )}

              {/* Name */}
              <div>
                <label className="block font-bold text-neutral-700 mb-1">
                  Chemical / Ingredient Name *
                </label>
                <input
                  type="text"
                  value={formName}
                  onChange={(e) => setFormName(e.target.value)}
                  placeholder="e.g. Sodium Laureth Sulfate (SLES)"
                  className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                  required
                />
              </div>

              {/* Aliases */}
              <div>
                <label className="block font-bold text-neutral-700 mb-1">
                  Aliases &amp; Synonyms (comma-separated)
                </label>
                <input
                  type="text"
                  value={formAliases}
                  onChange={(e) => setFormAliases(e.target.value)}
                  placeholder="e.g. SLES, Sodium Lauryl Ether Sulfate, E218"
                  className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                />
              </div>

              {/* Category & Hazard Level in 2 cols */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-neutral-700 mb-1">
                    Commodity Category
                  </label>
                  <select
                    value={formCategory}
                    onChange={(e) => setFormCategory(e.target.value as ProductCategory)}
                    className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                  >
                    <option value="food">Food</option>
                    <option value="cosmetic">Cosmetic</option>
                  </select>
                </div>

                <div>
                  <label className="block font-bold text-neutral-700 mb-1">
                    Hazard Classification
                  </label>
                  <select
                    value={formHazardLevel}
                    onChange={(e) => setFormHazardLevel(e.target.value as HazardLevel)}
                    className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                  >
                    <option value="high">High Risk</option>
                    <option value="moderate">Moderate Risk</option>
                    <option value="low">Low Risk</option>
                    <option value="info">Info / Dietary Note</option>
                  </select>
                </div>
              </div>

              {/* Regulatory Source */}
              <div>
                <label className="block font-bold text-neutral-700 mb-1">
                  Regulatory Benchmark Source
                </label>
                <input
                  type="text"
                  value={formSource}
                  onChange={(e) => setFormSource(e.target.value)}
                  placeholder="e.g. FSSAI / BIS IS 7884 / CIR / EWG / EU SCCS"
                  className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                />
              </div>

              {/* Reason */}
              <div>
                <label className="block font-bold text-neutral-700 mb-1">
                  Health &amp; Toxicological Reason *
                </label>
                <textarea
                  value={formReason}
                  onChange={(e) => setFormReason(e.target.value)}
                  rows={2}
                  placeholder="Explain epidermal barrier stripping, endocrine mimicry, carcinogenicity, or hyperactivity triggers..."
                  className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                  required
                />
              </div>

              {/* Scientific Details */}
              <div>
                <label className="block font-bold text-neutral-700 mb-1">
                  Scientific Monograph Details (Optional)
                </label>
                <input
                  type="text"
                  value={formScientific}
                  onChange={(e) => setFormScientific(e.target.value)}
                  placeholder="e.g. CIR Expert panel limit: <1% concentration in leave-on products"
                  className="w-full px-3 py-2 rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
                />
              </div>

              {/* Modal Actions */}
              <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-neutral-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 rounded-xl text-neutral-600 hover:bg-neutral-100 font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="inline-flex items-center gap-1.5 px-5 py-2 rounded-xl font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-xs"
                >
                  <Save className="w-3.5 h-3.5" />
                  <span>{editingIngredient ? 'Save Changes' : 'Create Ingredient'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminView;

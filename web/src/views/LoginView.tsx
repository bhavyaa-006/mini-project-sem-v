import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { LeafShieldLogo } from '../components/LeafShieldLogo';
import { loginWithToken } from '../api/client';
import {
  LogIn,
  UserPlus,
  Mail,
  Lock,
  User,
  CheckCircle,
  AlertCircle,
  Sparkles,
  ShieldCheck,
} from 'lucide-react';

interface LoginViewProps {
  onLoginSuccess?: (email: string) => void;
}

export const LoginView: React.FC<LoginViewProps> = ({ onLoginSuccess }) => {
  const navigate = useNavigate();
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');

  // Form Fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('abc@safescan.ai');
  const [password, setPassword] = useState('safescan123');
  const [rememberMe, setRememberMe] = useState(true);
  const [selectedDiet, setSelectedDiet] = useState<string[]>(['Vegetarian (Green Dot)']);

  // Feedback & Loading
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const availableDiets = [
    'Vegetarian (Green Dot)',
    'Vegan',
    'Lactose-Conscious',
    'Sugar-Conscious',
    'Gluten-Free',
  ];

  const toggleDiet = (diet: string) => {
    setSelectedDiet((prev) =>
      prev.includes(diet) ? prev.filter((d) => d !== diet) : [...prev, diet]
    );
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    setSuccessMessage(null);

    if (!email.trim() || !password.trim()) {
      setErrorMessage('Please provide both email and password.');
      return;
    }

    if (mode === 'signup' && !name.trim()) {
      setErrorMessage('Please enter your full name.');
      return;
    }

    setIsLoading(true);
    try {
      // Simulate authentication API call and persist JWT in localStorage
      const syntheticToken = `jwt-safescan-${btoa(email)}-${Date.now()}`;
      await loginWithToken(email, syntheticToken);

      if (rememberMe) {
        localStorage.setItem('safescan_user_email', email);
      }

      setSuccessMessage(
        mode === 'signin'
          ? 'Sign in successful! Redirecting to inspection scanner...'
          : 'Account created successfully! Welcome to SafeScan & PackCheck AI.'
      );

      onLoginSuccess?.(email);

      setTimeout(() => {
        navigate('/');
      }, 700);
    } catch {
      setErrorMessage('Authentication error. Please verify your credentials.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickDemoFill = () => {
    setEmail('abc@safescan.ai');
    setPassword('safescan2026');
    setName('ABC');
    setErrorMessage(null);
  };

  return (
    <div className="min-h-[80vh] flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-8 bg-gradient-to-b from-white to-[#F9FAF8] font-sans">
      <div className="sm:mx-auto sm:w-full sm:max-w-md text-center">
        {/* Brand Logo */}
        <div className="inline-flex justify-center mb-3">
          <LeafShieldLogo size={44} />
        </div>
        <h2 className="text-2xl sm:text-3xl font-extrabold text-neutral-900 tracking-tight">
          {mode === 'signin' ? 'Sign in to SafeScan' : 'Create Consumer Account'}
        </h2>
        <p className="mt-1 text-xs sm:text-sm text-neutral-500">
          Independent health analysis and Legal Metrology compliance verification.
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-6 sm:px-10 rounded-3xl border border-neutral-200/90 shadow-sm space-y-6">
          {/* Tab Switcher: Sign In vs Create Account */}
          <div className="flex rounded-2xl bg-[#F9FAF8] p-1 border border-neutral-200/80">
            <button
              type="button"
              onClick={() => {
                setMode('signin');
                setErrorMessage(null);
              }}
              className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all flex items-center justify-center gap-1.5 ${
                mode === 'signin'
                  ? 'bg-white text-neutral-900 shadow-2xs'
                  : 'text-neutral-500 hover:text-neutral-900'
              }`}
            >
              <LogIn className="w-3.5 h-3.5 text-[#27AE60]" />
              <span>Sign In</span>
            </button>

            <button
              type="button"
              onClick={() => {
                setMode('signup');
                setErrorMessage(null);
              }}
              className={`flex-1 py-2 text-xs font-bold rounded-xl transition-all flex items-center justify-center gap-1.5 ${
                mode === 'signup'
                  ? 'bg-white text-neutral-900 shadow-2xs'
                  : 'text-neutral-500 hover:text-neutral-900'
              }`}
            >
              <UserPlus className="w-3.5 h-3.5 text-[#27AE60]" />
              <span>Create Account</span>
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Name Field (Sign Up Only) */}
            {mode === 'signup' && (
              <div>
                <label className="block text-xs font-bold text-neutral-700 mb-1">
                  Full Name
                </label>
                <div className="relative">
                  <User className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. ABC"
                    required
                    className="w-full pl-10 pr-4 py-2.5 text-xs sm:text-sm rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] focus:border-transparent transition-all"
                  />
                </div>
              </div>
            )}

            {/* Email Field */}
            <div>
              <label className="block text-xs font-bold text-neutral-700 mb-1">
                Email Address
              </label>
              <div className="relative">
                <Mail className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="abc@safescan.ai"
                  required
                  className="w-full pl-10 pr-4 py-2.5 text-xs sm:text-sm rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] focus:border-transparent transition-all"
                />
              </div>
            </div>

            {/* Password Field */}
            <div>
              <label className="block text-xs font-bold text-neutral-700 mb-1">
                Password
              </label>
              <div className="relative">
                <Lock className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  className="w-full pl-10 pr-4 py-2.5 text-xs sm:text-sm rounded-xl border border-neutral-200 bg-[#F9FAF8] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#27AE60] focus:border-transparent transition-all"
                />
              </div>
            </div>

            {/* Dietary Preference Quick Setup (Sign Up Only) */}
            {mode === 'signup' && (
              <div className="pt-2">
                <label className="block text-xs font-bold text-neutral-700 mb-1.5">
                  Initial Dietary Focus (Optional)
                </label>
                <div className="flex flex-wrap gap-1.5">
                  {availableDiets.map((diet) => {
                    const isSelected = selectedDiet.includes(diet);
                    return (
                      <button
                        key={diet}
                        type="button"
                        onClick={() => toggleDiet(diet)}
                        className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-all ${
                          isSelected
                            ? 'bg-[#27AE60] text-white'
                            : 'bg-[#F9FAF8] text-neutral-600 border border-neutral-200'
                        }`}
                      >
                        {diet}
                      </button>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Remember Me & Help */}
            <div className="flex items-center justify-between text-xs pt-1">
              <label className="flex items-center gap-2 cursor-pointer text-neutral-600">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="rounded text-[#27AE60] focus:ring-[#27AE60]"
                />
                <span>Remember me on this browser</span>
              </label>

              <button
                type="button"
                onClick={handleQuickDemoFill}
                className="text-xs font-bold text-[#1E8449] hover:underline flex items-center gap-1"
              >
                <Sparkles className="w-3 h-3 text-[#27AE60]" />
                Demo Credentials
              </button>
            </div>

            {/* Error & Success Messages */}
            {errorMessage && (
              <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-medium flex items-center gap-2 animate-in fade-in">
                <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
                <span>{errorMessage}</span>
              </div>
            )}

            {successMessage && (
              <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold flex items-center gap-2 animate-in fade-in">
                <CheckCircle className="w-4 h-4 text-[#27AE60] shrink-0" />
                <span>{successMessage}</span>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-xl text-sm font-bold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all active:scale-[0.98] disabled:opacity-60"
            >
              {isLoading ? (
                <span>Authenticating...</span>
              ) : mode === 'signin' ? (
                <>
                  <LogIn className="w-4 h-4" />
                  <span>Sign In</span>
                </>
              ) : (
                <>
                  <UserPlus className="w-4 h-4" />
                  <span>Create Account &amp; Start Scanning</span>
                </>
              )}
            </button>
          </form>

          {/* Privacy & Compliance Assurance */}
          <div className="pt-2 border-t border-neutral-100 flex items-center justify-center gap-2 text-neutral-400 text-xs text-center">
            <ShieldCheck className="w-4 h-4 text-[#27AE60]" />
            <span>Zero advertising tracking • 100% independent evaluation</span>
          </div>
        </div>

        <p className="mt-4 text-center text-xs text-neutral-500">
          Want to test without signing in?{' '}
          <Link to="/" className="font-bold text-[#1E8449] hover:underline">
            Use instant demo scanner →
          </Link>
        </p>
      </div>
    </div>
  );
};

export default LoginView;

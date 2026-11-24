import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  ScanLine,
  History,
  User,
  ShieldCheck,
  LogIn,
  LogOut,
  Menu,
  X,
  Sparkles,
} from 'lucide-react';
import { LeafShieldLogo } from './LeafShieldLogo';

interface NavbarProps {
  isLoggedIn?: boolean;
  onLogout?: () => void;
  userEmail?: string;
}

export const Navbar: React.FC<NavbarProps> = ({
  isLoggedIn = true,
  onLogout,
  userEmail = 'abc@safescan.ai',
}) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const location = useLocation();

  const navItems = [
    { label: 'Scan', path: '/', icon: ScanLine },
    { label: 'History', path: '/history', icon: History },
    { label: 'Profile', path: '/profile', icon: User },
    { label: 'Admin', path: '/admin', icon: ShieldCheck },
  ];

  const isActive = (path: string) => {
    if (path === '/' && (location.pathname === '/' || location.pathname === '/scan')) {
      return true;
    }
    return location.pathname.startsWith(path) && path !== '/';
  };

  return (
    <header className="sticky top-0 z-50 w-full bg-[#FFFFFF]/95 backdrop-blur-md border-b border-neutral-100 shadow-[0_1px_3px_rgba(0,0,0,0.03)] font-sans">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 sm:h-18">
          {/* Logo */}
          <Link
            to="/"
            className="flex items-center gap-3 transition-opacity hover:opacity-95 focus:outline-none"
            aria-label="SafeScan & PackCheck AI Home"
          >
            <LeafShieldLogo size={36} />
          </Link>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center space-x-1 lg:space-x-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-sm font-semibold transition-all duration-200 ${
                    active
                      ? 'bg-[#27AE60]/10 text-[#1E8449] shadow-xs'
                      : 'text-neutral-600 hover:text-neutral-900 hover:bg-neutral-50'
                  }`}
                >
                  <Icon
                    className={`w-4 h-4 transition-colors ${
                      active ? 'text-[#27AE60]' : 'text-neutral-400 group-hover:text-neutral-600'
                    }`}
                  />
                  <span>{item.label}</span>
                </Link>
              );
            })}
          </nav>

          {/* Right Action / Auth Button */}
          <div className="hidden md:flex items-center gap-3">
            {isLoggedIn ? (
              <div className="flex items-center gap-3 pl-2 border-l border-neutral-200">
                <Link
                  to="/profile"
                  className="flex items-center gap-2.5 text-right leading-tight hover:opacity-85 transition-opacity"
                >
                  <div className="flex flex-col">
                    <span className="text-xs font-semibold text-neutral-800">
                      {userEmail === 'abc@safescan.ai' ? 'ABC' : userEmail.split('@')[0]}
                    </span>
                    <span className="text-[10px] text-[#27AE60] font-medium flex items-center justify-end gap-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#27AE60]"></span>
                      Member
                    </span>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#27AE60] to-[#1E8449] text-white flex items-center justify-center font-bold text-xs shadow-2xs">
                    AB
                  </div>
                </Link>

                <button
                  type="button"
                  onClick={onLogout}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-neutral-600 hover:text-rose-600 rounded-lg hover:bg-rose-50 transition-colors"
                  title="Logout"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Logout</span>
                </button>
              </div>
            ) : (
              <Link
                to="/login"
                className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm transition-all duration-150 active:scale-[0.98]"
              >
                <LogIn className="w-4 h-4" />
                <span>Sign In</span>
              </Link>
            )}

            {/* Quick Demo Scan CTA */}
            <Link
              to="/"
              className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-bold bg-[#F9FAF8] text-[#1E8449] border border-emerald-200/60 hover:border-emerald-300 hover:bg-emerald-50/50 transition-all shadow-xs"
            >
              <Sparkles className="w-3.5 h-3.5 text-[#27AE60]" />
              <span>Quick Demo</span>
            </Link>
          </div>

          {/* Mobile Menu Hamburger Toggle */}
          <div className="flex md:hidden items-center gap-2">
            <button
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 rounded-xl text-neutral-600 hover:text-neutral-900 hover:bg-neutral-100 transition-colors focus:outline-none focus:ring-2 focus:ring-[#27AE60]"
              aria-label="Toggle mobile menu"
            >
              {mobileMenuOpen ? (
                <X className="w-6 h-6 text-neutral-800" />
              ) : (
                <Menu className="w-6 h-6 text-neutral-800" />
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden border-t border-neutral-100 bg-white px-4 pt-3 pb-5 space-y-2 shadow-lg animate-in slide-in-from-top-2 duration-150">
          <div className="space-y-1">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all ${
                    active
                      ? 'bg-[#27AE60]/10 text-[#1E8449]'
                      : 'text-neutral-600 hover:text-neutral-900 hover:bg-neutral-50'
                  }`}
                >
                  <Icon
                    className={`w-5 h-5 ${
                      active ? 'text-[#27AE60]' : 'text-neutral-400'
                    }`}
                  />
                  <span>{item.label}</span>
                </Link>
              );
            })}
          </div>

          <div className="pt-3 border-t border-neutral-100 flex flex-col gap-2">
            {isLoggedIn ? (
              <div className="flex items-center justify-between px-3 py-2 bg-[#F9FAF8] rounded-xl border border-neutral-100">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#27AE60] to-[#1E8449] text-white flex items-center justify-center font-bold text-xs shadow-2xs">
                    AB
                  </div>
                  <div className="text-left">
                    <p className="text-xs font-semibold text-neutral-800 leading-none">
                      {userEmail}
                    </p>
                    <p className="text-[10px] text-[#27AE60] font-medium mt-0.5">
                      Verified Member
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    onLogout?.();
                    setMobileMenuOpen(false);
                  }}
                  className="p-1.5 text-neutral-500 hover:text-rose-600 rounded-lg hover:bg-rose-50 text-xs font-medium inline-flex items-center gap-1"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>Logout</span>
                </button>
              </div>
            ) : (
              <Link
                to="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="w-full inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold bg-[#27AE60] hover:bg-[#1E8449] text-white shadow-sm"
              >
                <LogIn className="w-4 h-4" />
                <span>Sign In / Create Account</span>
              </Link>
            )}
          </div>
        </div>
      )}
    </header>
  );
};

export default Navbar;

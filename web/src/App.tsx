import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { ProductAnalysisView } from './views/ProductAnalysisView';
import { HistoryView } from './views/HistoryView';
import { ProfileView } from './views/ProfileView';
import { AdminView } from './views/AdminView';
import { LoginView } from './views/LoginView';
import { logout } from './api/client';

export const App: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(() => {
    return !!(
      localStorage.getItem('safescan_token') ||
      localStorage.getItem('token')
    );
  });

  const [userEmail, setUserEmail] = useState<string>(() => {
    return localStorage.getItem('safescan_user_email') || 'abc@safescan.ai';
  });

  const handleLogout = () => {
    logout();
    setIsLoggedIn(false);
  };

  const handleLoginSuccess = (email: string) => {
    setIsLoggedIn(true);
    setUserEmail(email);
  };

  return (
    <BrowserRouter>
      <div className="min-h-screen flex flex-col bg-white text-neutral-900 font-sans selection:bg-[#27AE60]/20 selection:text-[#1E8449]">
        {/* Yuka-Inspired Responsive App Shell Navigation */}
        <Navbar
          isLoggedIn={isLoggedIn}
          onLogout={handleLogout}
          userEmail={userEmail}
        />

        {/* Dynamic Route Content */}
        <div className="flex-1">
          <Routes>
            <Route path="/" element={<ProductAnalysisView />} />
            <Route path="/scan" element={<ProductAnalysisView />} />
            <Route path="/history" element={<HistoryView />} />
            <Route path="/profile" element={<ProfileView />} />
            <Route path="/admin" element={<AdminView />} />
            <Route
              path="/login"
              element={<LoginView onLoginSuccess={handleLoginSuccess} />}
            />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </div>

        {/* Informational Guidance & Legal Metrology Disclaimer Footer */}
        <Footer />
      </div>
    </BrowserRouter>
  );
};

export default App;

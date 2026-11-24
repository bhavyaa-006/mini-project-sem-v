import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios';
import {
  mockFoodProduct,
  mockCosmeticProduct,
  mockProducts,
  mockScanHistory,
  mockUserProfile,
} from '../mockData';
import type {
  ProductAnalysis,
  ScanHistoryItem,
  UserProfile,
} from '../types/api';
import { downloadAuditReportFile } from '../utils/pdfGenerator';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

// When VITE_USE_MOCK is not explicitly 'false', default to mock fallback mode
export const isMockEnabled = (): boolean => {
  return import.meta.env.VITE_USE_MOCK !== 'false';
};

/**
 * Configured Axios instance with automatic JWT Authorization header attachment
 */
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request interceptor: attach Bearer token from localStorage
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token =
      localStorage.getItem('token') ||
      localStorage.getItem('auth_token') ||
      localStorage.getItem('safescan_token');

    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// Response interceptor: graceful mock fallback on network disconnect or when mock is enabled
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    if (isMockEnabled()) {
      console.info(
        `[SafeScan API] Request to "${error.config?.url}" fell back to mock data (VITE_USE_MOCK !== 'false').`
      );
    }
    return Promise.reject(error);
  }
);

/**
 * Service Layer: High-level API calls with transparent mock fallback
 */

// Simulated network latency for realistic UX in mock mode
const delay = (ms: number = 300) =>
  new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Retrieve product analysis by ID, barcode, or category keyword
 */
export async function getProductAnalysis(
  queryOrId: string
): Promise<ProductAnalysis> {
  if (!isMockEnabled()) {
    try {
      const response = await apiClient.get<ProductAnalysis>(
        `/api/v1/products/${encodeURIComponent(queryOrId)}`
      );
      return response.data;
    } catch (err) {
      console.warn(
        `[SafeScan API] Backend fetch failed for "${queryOrId}". Falling back to mock dataset:`,
        err
      );
    }
  }

  await delay(350);
  const normalized = queryOrId.toLowerCase().trim();

  if (
    normalized.includes('shampoo') ||
    normalized.includes('silk') ||
    normalized.includes('cosmetic') ||
    normalized === 'prod-herbal-silk-002' ||
    normalized === '8904005928114'
  ) {
    return mockCosmeticProduct;
  }

  // Default to Amul Taaza Food product
  return mockFoodProduct;
}

/**
 * Retrieve all available products
 */
export async function getAllProducts(): Promise<ProductAnalysis[]> {
  if (!isMockEnabled()) {
    try {
      const response = await apiClient.get<ProductAnalysis[]>('/api/v1/products');
      return response.data;
    } catch (err) {
      console.warn('[SafeScan API] Fallback to mock products list:', err);
    }
  }

  await delay(200);
  return mockProducts;
}

/**
 * Retrieve user's scan history
 */
export async function getScanHistory(): Promise<ScanHistoryItem[]> {
  if (!isMockEnabled()) {
    try {
      const response = await apiClient.get<ScanHistoryItem[]>('/api/v1/history');
      return response.data;
    } catch (err) {
      console.warn('[SafeScan API] Fallback to mock scan history:', err);
    }
  }

  await delay(250);
  return mockScanHistory;
}

/**
 * Retrieve current user profile
 */
export async function getUserProfile(): Promise<UserProfile> {
  if (!isMockEnabled()) {
    try {
      const response = await apiClient.get<UserProfile>('/api/v1/user/profile');
      return response.data;
    } catch (err) {
      console.warn('[SafeScan API] Fallback to mock user profile:', err);
    }
  }

  await delay(200);
  return mockUserProfile;
}

/**
 * Update user preferences or restrictions
 */
export async function updateUserProfile(
  updates: Partial<UserProfile>
): Promise<UserProfile> {
  if (!isMockEnabled()) {
    try {
      const response = await apiClient.put<UserProfile>(
        '/api/v1/user/profile',
        updates
      );
      return response.data;
    } catch (err) {
      console.warn('[SafeScan API] Fallback to local profile update:', err);
    }
  }

  await delay(300);
  return {
    ...mockUserProfile,
    ...updates,
  };
}

/**
 * Analyze an uploaded package image or label photo
 */
export async function analyzePackageImage(
  file: File | Blob
): Promise<ProductAnalysis> {
  if (!isMockEnabled()) {
    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await apiClient.post<ProductAnalysis>(
        '/api/v1/scan/upload',
        formData,
        {
          headers: { 'Content-Type': 'multipart/form-data' },
        }
      );
      return response.data;
    } catch (err) {
      console.warn('[SafeScan API] Upload analysis fell back to mock data:', err);
    }
  }

  await delay(600);
  // Returns appropriate mock product for rich interactive test
  const fileName = file instanceof File ? file.name.toLowerCase() : '';
  if (fileName.includes('shampoo') || fileName.includes('cosmetic') || fileName.includes('silk')) {
    return mockCosmeticProduct;
  }
  return mockFoodProduct;
}

/**
 * Download statutory PDF audit report
 * Calls GET /report/{scan_id}/pdf or generates formatted PDF in mock mode
 */
export async function downloadAuditReport(
  scanId: string,
  product?: ProductAnalysis | null
): Promise<void> {
  const targetProduct = product || (scanId.includes('silk') || scanId.includes('cosmetic') ? mockCosmeticProduct : mockFoodProduct);

  if (!isMockEnabled()) {
    try {
      const response = await apiClient.get(`/report/${encodeURIComponent(scanId)}/pdf`, {
        responseType: 'blob',
      });
      const url = URL.createObjectURL(response.data);
      const link = document.createElement('a');
      link.href = url;
      link.download = `SafeScan_Audit_Report_${scanId}.pdf`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      return;
    } catch (err) {
      console.warn(
        `[SafeScan API] Real PDF report fetch failed for "${scanId}". Falling back to client PDF generator:`,
        err
      );
    }
  }

  await delay(250);
  downloadAuditReportFile(targetProduct, `SafeScan_Audit_Report_${scanId}.pdf`);
}

/**
 * Demo authentication helpers
 */
export async function loginWithToken(
  email: string,
  token: string = 'demo-jwt-safescan-packcheck-token'
): Promise<UserProfile> {
  localStorage.setItem('safescan_token', token);
  localStorage.setItem('token', token);
  return { ...mockUserProfile, email };
}

export function logout(): void {
  localStorage.removeItem('safescan_token');
  localStorage.removeItem('token');
  localStorage.removeItem('auth_token');
}

export function isAuthenticated(): boolean {
  return !!(
    localStorage.getItem('safescan_token') ||
    localStorage.getItem('token') ||
    localStorage.getItem('auth_token')
  );
}

export default apiClient;

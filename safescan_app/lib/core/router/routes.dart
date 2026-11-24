abstract final class AppRoutes {
  static const splash = '/';
  static const splashName = 'splash';

  static const debugRoutes = '/debug/routes';
  static const debugRoutesName = 'debugRoutes';
  static const widgetGallery = '/debug/widget-gallery';
  static const widgetGalleryName = 'widgetGallery';

  static const onboarding = '/onboarding';
  static const onboardingName = 'onboarding';
  static const login = '/login';
  static const loginName = 'login';
  static const register = '/register';
  static const registerName = 'register';
  static const forgotPassword = '/forgot-password';
  static const forgotPasswordName = 'forgotPassword';

  static const home = '/home';
  static const homeName = 'home';
  static const scanHub = '/scan';
  static const scanHubName = 'scanHub';
  static const barcodeScanner = '/scan/barcode';
  static const barcodeScannerName = 'barcodeScanner';
  static const labelScanner = '/scan/label';
  static const labelScannerName = 'labelScanner';
  static const scanProcessing = '/scan/processing/:barcode';
  static const scanProcessingName = 'scanProcessing';
  static String scanProcessingPath(String barcode) => '/scan/processing/${Uri.encodeComponent(barcode)}';

  static const productResult = '/products/:id';
  static const productResultName = 'productResult';
  static const ingredientDetail = '/ingredients/:id';
  static const ingredientDetailName = 'ingredientDetail';
  static const ingredientList = '/products/:id/ingredients';
  static const ingredientListName = 'ingredientList';
  static const alternatives = '/alternatives';
  static const alternativesName = 'alternatives';
  static const alternativesForProduct = '/products/:id/alternatives';
  static const alternativesForProductName = 'alternativesForProduct';
  static const alternativesCompare = '/alternatives/compare';
  static const alternativesCompareName = 'alternativesCompare';

  static String alternativesPath([String? productId]) {
    if (productId == null || productId.isEmpty) return alternatives;
    return '/products/${Uri.encodeComponent(productId)}/alternatives';
  }
  static const history = '/history';
  static const historyName = 'history';
  static const profile = '/profile';
  static const profileName = 'profile';
  static const editProfile = '/profile/edit';
  static const editProfileName = 'editProfile';
  static const pdfReport = '/report/pdf/:id';
  static const pdfReportName = 'pdfReport';
  static String pdfReportPath(String id) => '/report/pdf/${Uri.encodeComponent(id)}';

  static String productResultPath(String id) => '/products/$id';
  static String ingredientDetailPath(String id) => '/ingredients/${Uri.encodeComponent(id)}';
  static String ingredientListPath(String productId) => '/products/${Uri.encodeComponent(productId)}/ingredients';
}

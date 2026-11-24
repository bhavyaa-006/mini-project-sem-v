import type { ProductAnalysis } from '../types/api';

/**
 * Generates a valid PDF-1.4 binary document for product audit reports.
 * Includes complete Legal Metrology declarations, Yuka-inspired scoring,
 * flagged ingredients analysis, and regulatory disclaimers.
 */
export function generateAuditReportPdf(product: ProductAnalysis): Blob {
  const sanitize = (text: string = '') =>
    text
      .replace(/\\/g, '\\\\')
      .replace(/\(/g, '\\(')
      .replace(/\)/g, '\\)')
      .replace(/[^\x20-\x7E]/g, ' '); // Keep printable ASCII for standard PDF Helvetica font

  const productName = sanitize(product.name);
  const brand = sanitize(product.brand);
  const barcode = sanitize(product.barcode || 'N/A');
  const category = sanitize(product.category.toUpperCase());
  const score = product.score;
  const ratingTier = sanitize(product.ratingLabel.toUpperCase());
  const compliant = product.legalMetrology.compliant ? 'COMPLIANT' : 'NON-COMPLIANT (CRITICAL VIOLATION)';
  const mrp = sanitize(product.legalMetrology.mrp || 'N/A');
  const netQty = sanitize(product.legalMetrology.netQuantity || 'N/A');
  const expiry = sanitize(product.legalMetrology.expiryDate || 'OMITTED / MISSING');
  const manufacturer = sanitize(product.legalMetrology.manufacturerName || 'N/A');
  const fssai = sanitize(product.legalMetrology.fssaiLicenseNumber || 'N/A');
  const dateStr = new Date().toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });

  // Build stream content for the PDF page
  const contentStream = `
q
0.15 0.68 0.38 rg
15 760 565 60 re f
0.98 0.98 0.97 rg
15 25 565 725 re f
0.85 0.85 0.85 RG
1 w
15 25 565 795 re s
Q

BT
/F2 16 Tf
1 1 1 rg
30 790 Td
(SAFESCAN & PACKCHECK AI) Tj
/F1 10 Tf
30 772 Td
(Statutory Package & Toxicological Compliance Audit Report) Tj
ET

BT
/F1 9 Tf
0.3 0.3 0.3 rg
370 772 Td
(Date: ${dateStr} | Auditor: ABC) Tj
ET

BT
/F2 14 Tf
0.1 0.1 0.1 rg
30 725 Td
(Product: ${productName}) Tj
/F1 10 Tf
0.2 0.2 0.2 rg
30 705 Td
(Brand: ${brand}   |   Category: ${category}   |   Barcode: ${barcode}) Tj
ET

q
${score >= 75 ? '0.12 0.52 0.29' : score >= 50 ? '0.18 0.80 0.44' : score >= 25 ? '0.95 0.61 0.07' : '0.91 0.30 0.24'} rg
30 635 250 50 re f
Q

BT
/F2 18 Tf
1 1 1 rg
45 658 Td
(SCORE: ${score} / 100) Tj
/F1 10 Tf
45 643 Td
(Yuka Tier: ${ratingTier}) Tj
ET

q
0.92 0.94 0.92 rg
300 635 265 50 re f
0.7 0.7 0.7 RG
300 635 265 50 re s
Q

BT
/F2 11 Tf
0.1 0.1 0.1 rg
312 666 Td
(LEGAL METROLOGY PCR 2011) Tj
/F2 10 Tf
${product.legalMetrology.compliant ? '0.12 0.52 0.29' : '0.91 0.30 0.24'} rg
312 648 Td
(Status: ${compliant}) Tj
ET

BT
/F2 11 Tf
0.15 0.68 0.38 rg
30 600 Td
(1. LEGAL METROLOGY & PACKAGING DECLARATIONS) Tj
/F1 9 Tf
0.2 0.2 0.2 rg
30 582 Td
(Declared Maximum Retail Price (MRP): ${mrp}) Tj
30 568 Td
(Net Quantity / Content: ${netQty}) Tj
30 554 Td
(Expiry Date / Best Before: ${expiry}) Tj
30 540 Td
(Manufacturer / Packer: ${manufacturer}) Tj
30 526 Td
(FSSAI / Statutory License: ${fssai}) Tj
ET

BT
/F2 11 Tf
0.15 0.68 0.38 rg
30 495 Td
(2. INGREDIENTS RISK & CHEMICAL TOXICITY ASSESSMENT) Tj
ET

${product.flaggedIngredients
  .slice(0, 4)
  .map((ing, idx) => {
    const yName = 475 - idx * 36;
    const yReason = yName - 14;
    const ingName = sanitize(ing.name);
    const ingHazard = sanitize(ing.hazardLevel.toUpperCase());
    const ingSource = sanitize(ing.dataSource || 'Statutory INCI Panel');
    const ingReason = sanitize(ing.reason.slice(0, 85) + (ing.reason.length > 85 ? '...' : ''));

    return `
BT
/F2 9 Tf
${ing.hazardLevel === 'high' ? '0.85 0.2 0.2' : ing.hazardLevel === 'moderate' ? '0.8 0.5 0.1' : '0.15 0.6 0.2'} rg
30 ${yName} Td
([${ingHazard}] ${ingName}  --  Source: ${ingSource}) Tj
/F1 8 Tf
0.3 0.3 0.3 rg
30 ${yReason} Td
(${ingReason}) Tj
ET
`;
  })
  .join('\n')}

BT
/F2 11 Tf
0.15 0.68 0.38 rg
30 320 Td
(3. RECOMMENDED CLEANER & SAFER ALTERNATIVES) Tj
ET

${product.alternatives
  .slice(0, 2)
  .map((alt, idx) => {
    const y = 300 - idx * 24;
    const altName = sanitize(alt.name);
    const altBrand = sanitize(alt.brand);
    const altReason = sanitize(alt.highlightReason.slice(0, 75));
    return `
BT
/F2 9 Tf
0.2 0.2 0.2 rg
30 ${y} Td
(* ${altBrand} - ${altName} [Score: ${alt.score}/100]:) Tj
/F1 8 Tf
0.4 0.4 0.4 rg
260 ${y} Td
(${altReason}) Tj
ET
`;
  })
  .join('\n')}

q
0.96 0.96 0.94 rg
30 50 535 60 re f
0.8 0.8 0.8 RG
30 50 535 60 re s
Q

BT
/F2 8 Tf
0.4 0.3 0.1 rg
40 94 Td
(INFORMATIONAL GUIDANCE NOTICE & MEDICAL / STATUTORY DISCLAIMER) Tj
/F1 7 Tf
0.4 0.4 0.4 rg
40 82 Td
(This report is generated strictly for informational consumer guidance and does not constitute certified medical diagnosis,) Tj
40 72 Td
(dermatological prescription, or statutory enforcement certification. Evaluation criteria are benchmarked against public FSSAI,) Tj
40 62 Td
(Legal Metrology Act 2009 / Packaged Commodities Rules 2011, and international cosmetic safety panels.) Tj
ET
`;

  const streamLength = contentStream.length;

  const pdfDocument = `%PDF-1.4
1 0 obj
<<
  /Type /Catalog
  /Pages 2 0 R
>>
endobj
2 0 obj
<<
  /Type /Pages
  /Kids [3 0 R]
  /Count 1
>>
endobj
3 0 obj
<<
  /Type /Page
  /Parent 2 0 R
  /MediaBox [0 0 595 842]
  /Contents 4 0 R
  /Resources <<
    /Font <<
      /F1 5 0 R
      /F2 6 0 R
    >>
  >>
>>
endobj
4 0 obj
<<
  /Length ${streamLength}
>>
stream${contentStream}
endstream
endobj
5 0 obj
<<
  /Type /Font
  /Subtype /Type1
  /BaseFont /Helvetica
>>
endobj
6 0 obj
<<
  /Type /Font
  /Subtype /Type1
  /BaseFont /Helvetica-Bold
>>
endobj
xref
0 7
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
0000000266 00000 n 
0000000${(320 + streamLength).toString().padStart(4, '0')} 00000 n 
0000000${(398 + streamLength).toString().padStart(4, '0')} 00000 n 
trailer
<<
  /Size 7
  /Root 1 0 R
>>
startxref
${480 + streamLength}
%%EOF`;

  return new Blob([pdfDocument], { type: 'application/pdf' });
}

/**
 * Triggers a browser file download of the generated PDF audit report.
 */
export function downloadAuditReportFile(
  product: ProductAnalysis,
  fileName?: string
): void {
  const blob = generateAuditReportPdf(product);
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  const safeId = product.id.replace(/[^a-zA-Z0-9_-]/g, '_');
  link.download = fileName || `SafeScan_PackCheck_Audit_${safeId}.pdf`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

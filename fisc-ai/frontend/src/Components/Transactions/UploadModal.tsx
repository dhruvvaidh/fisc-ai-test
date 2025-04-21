// src/Components/Transactions/UploadModal.tsx
import React from 'react';
import styles from './UploadModal.module.css';

interface UploadModalProps {
  isOpen: boolean;
  onClose: () => void;
  onUpload: (file: File) => Promise<void>;
  uploadStatus: string;
}

const UploadModal: React.FC<UploadModalProps> = ({
  isOpen,
  onClose,
  onUpload,
  uploadStatus
}) => {
  if (!isOpen) return null;

  const getUploadStep = (status: string): number => {
    if (status.includes('url')) return 1;
    if (status.includes('s3')) return 2;
    if (status.includes('processing')) return 3;
    if (status.includes('successfully')) return 4;
    return 0;
  };

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={e => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h3>Upload Receipt</h3>
          <button onClick={onClose} className={styles.closeButton}>×</button>
        </div>

        <div className={styles.uploadSection}>
          {uploadStatus ? (
            <div className={styles.statusContainer}>
              {/* Progress Steps */}
              <div className={styles.steps}>
                {['Preparing', 'Uploading', 'Processing', 'Complete'].map((step, index) => (
                  <div 
                    key={step} 
                    className={`${styles.step} ${getUploadStep(uploadStatus) > index ? styles.completed : ''} ${getUploadStep(uploadStatus) === index + 1 ? styles.current : ''}`}
                  >
                    <div className={styles.stepNumber}>
                      {getUploadStep(uploadStatus) > index ? '✓' : index + 1}
                    </div>
                    <div className={styles.stepLabel}>{step}</div>
                  </div>
                ))}
              </div>

              {/* Status Message */}
              <div className={styles.statusMessage}>
                <div className={styles.statusText}>
                  {uploadStatus}
                </div>
                {!uploadStatus.includes('successfully') && !uploadStatus.includes('failed') && (
                  <div className={styles.loadingSpinner}></div>
                )}
              </div>
            </div>
          ) : (
            <label className={styles.uploadArea}>
              <input
                type="file"
                accept="image/*,.pdf"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) onUpload(file);
                }}
                className={styles.fileInput}
              />
              <div className={styles.uploadContent}>
                <div className={styles.uploadIcon}>
                  <svg width="50" height="50" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                    <polyline points="17 8 12 3 7 8" />
                    <line x1="12" y1="3" x2="12" y2="15" />
                  </svg>
                </div>
                <div className={styles.uploadText}>
                  <span className={styles.primaryText}>Choose a file</span>
                  <span className={styles.secondaryText}>or drag and drop</span>
                </div>
                <div className={styles.supportedFormats}>
                  Supported formats: PDF, PNG, JPG
                </div>
              </div>
            </label>
          )}
        </div>
      </div>
    </div>
  );
};

export default UploadModal;
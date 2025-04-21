import { useState } from 'react';
import Institution from './Institution';
import './Institutions.css';

export interface InstitutionData {
  institution_id: string;
  name: string;
  logo?: string | null;
  products?: string[];
  status?: string;
  accounts?: any[];
}

interface InstitutionsProps {
  institutions: InstitutionData[];
}

export default function Institutions({ institutions = [] }: InstitutionsProps) {
  console.log('Institutions component received data:', institutions);
  
  return (
    <div className="institutions-container">
      <div className="institutions-header">
        <h2 className="institutions-title">Connected Banks</h2>
      </div>
      <div className="institutions-grid">
        {institutions.length ? (
          institutions.map((institution) => (
            <Institution 
              key={`institution-${institution.institution_id}`}
              institution={institution}
            />
          ))
        ) : (
          <div className="institution-card">
            <div className="institution-header">
              <div className="institution-logo">🏦</div>
              <div>
                <h3 className="institution-name">No Banks Connected</h3>
                <span className="status-badge">Connect your first bank to get started</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 
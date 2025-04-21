// src/Components/LoadingScreen/index.tsx
import React from 'react';
import { motion } from 'framer-motion';
import FiscAILogo from '../../assets/FiscAI.jpeg'; // Import the logo

const LoadingScreen = () => (
  <motion.div
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    exit={{ opacity: 0 }}
    className="fixed inset-0 flex items-center justify-center bg-white"
    style={{
      width: '100vw',
      height: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      position: 'fixed',
      top: 0,
      left: 0
    }}
  >
    <motion.div
      className="flex flex-col items-center justify-center"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
    >
      <motion.div 
        className="text-center"
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '20px'
        }}
      >
        {/* Logo Image */}
        <motion.img
          src={FiscAILogo}
          alt="FiscAI Logo"
          style={{
            width: '150px', // Adjust size as needed
            height: 'auto',
            objectFit: 'contain'
          }}
          initial={{ scale: 0.9 }}
          animate={{ scale: 1 }}
          transition={{ duration: 0.5 }}
        />

        {/* Loading Dots */}
        <motion.div
          style={{
            display: 'flex',
            gap: '6px',
            justifyContent: 'center',
            marginTop: '8px'
          }}
        >
          {[0, 1, 2].map((index) => (
            <motion.span
              key={index}
              style={{
                width: '6px',
                height: '6px',
                borderRadius: '50%',
                backgroundColor: '#3B82F6',
                display: 'inline-block'
              }}
              animate={{
                opacity: [0.3, 1, 0.3],
                scale: [1, 1.2, 1]
              }}
              transition={{
                duration: 1.2,
                repeat: Infinity,
                delay: index * 0.2,
                ease: "easeInOut"
              }}
            />
          ))}
        </motion.div>
      </motion.div>
    </motion.div>
  </motion.div>
);

export default LoadingScreen;
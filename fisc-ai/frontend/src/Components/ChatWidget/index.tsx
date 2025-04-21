import React, { useState } from 'react';
import './ChatWidget.css';

// You can store this in an environment variable or config file
const API_ENDPOINT = 'https://7o81y9tcsa.execute-api.us-east-1.amazonaws.com/dev/query_lex';

const ChatWidget = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState<Array<{text: string, sender: 'user' | 'bot'}>>([
    { text: "Type something to talk to Lutro powered by AWS Lex..", sender: 'bot' }
  ]);
  const [inputText, setInputText] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const toggleChat = () => {
    setIsOpen(!isOpen);
  };

  const sendMessageToLex = async (message: string) => {
    try {
      const requestBody = JSON.stringify({ message });
      console.log('Request body:', requestBody); // Will show: {"message": "your text"}
      
      const response = await fetch(API_ENDPOINT, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody
      });

      if (!response.ok) {
        throw new Error('Failed to get response from bot');
      }

      const data = await response.json();
      return data.message; // Assuming your Lambda returns { message: "bot response" }
    } catch (error) {
      console.error('Error sending message:', error);
      return "I'm sorry, I'm having trouble processing your request right now.";
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim() || isLoading) return;

    // Add user message
    setMessages(prev => [...prev, { text: inputText, sender: 'user' }]);
    const userMessage = inputText;
    setInputText('');
    
    // Show loading state
    setIsLoading(true);

    try {
      // Get response from Lex
      const botResponse = await sendMessageToLex(userMessage);
      
      // Add bot response
      setMessages(prev => [...prev, {
        text: botResponse,
        sender: 'bot'
      }]);

      console.log('Bot response:', botResponse);
    } catch (error) {
      // Handle error
      console.error('Error in chat response:', error instanceof Error ? error.message : error);
      setMessages(prev => [...prev, {
        text: "I'm sorry, I encountered an error. Please try again.",
        sender: 'bot'
      }]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="chat-widget-container">
      {isOpen && (
        <div className="chat-window">
          <div className="chat-header">
            <h3>Chat with Luthro</h3>
            <button className="close-button" onClick={toggleChat}>×</button>
          </div>
          <div className="chat-messages">
            {messages.map((message, index) => (
              <div key={index} className={`message ${message.sender}`}>
                {message.text}
              </div>
            ))}
            {isLoading && (
              <div className="message bot loading">
                <span>...</span>
              </div>
            )}
          </div>
          <form onSubmit={handleSubmit} className="chat-input-form">
            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="Type your message..."
              className="chat-input"
              disabled={isLoading}
            />
            <button 
              type="submit" 
              className="send-button"
              disabled={isLoading}
            >
              <i className="fas fa-paper-plane"></i>
            </button>
          </form>
        </div>
      )}
      <button className="chat-toggle-button" onClick={toggleChat}>
        <i className="fas fa-comments"></i>
        Ask Luthro
      </button>
    </div>
  );
};

export default ChatWidget; 
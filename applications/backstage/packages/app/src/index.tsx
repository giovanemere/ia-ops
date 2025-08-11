import '@backstage/cli/asset-types';
import ReactDOM from 'react-dom/client';
import App from './App';
import '@backstage/ui/css/styles.css';
import './styles/dark-mode.css';
import './scripts/force-dark-mode.js';

ReactDOM.createRoot(document.getElementById('root')!).render(<App />);

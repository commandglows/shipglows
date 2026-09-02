const { Plugin } = require('obsidian');

module.exports = class VisualProofPlugin extends Plugin {
  onload() {
    this.addCommand({
      id: 'open-proof',
      name: 'Open proof',
      callback: () => {
        const element = document.createElement('button');
        element.className = 'sg-visual-proof';
        element.textContent = 'Before click';
        element.style.backgroundColor = 'rgb(1, 2, 3)';
        element.style.position = 'fixed';
        element.style.inset = '16px auto auto 16px';
        element.style.zIndex = '9999';
        element.addEventListener('click', () => { element.textContent = 'After click'; });
        document.body.appendChild(element);
      },
    });
  }
};

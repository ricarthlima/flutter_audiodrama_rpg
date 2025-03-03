const fs = require('fs');

const envVars = JSON.stringify(process.env);
fs.writeFileSync('build/web/env.js', `window.env = ${envVars};`);

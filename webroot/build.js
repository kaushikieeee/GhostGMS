const fs = require('fs');
const path = require('path');
const { minify } = require('terser');

async function build() {
    try {
        // Read the source file
        const sourcePath = path.join(__dirname, 'src', 'index.js');
        const sourceCode = fs.readFileSync(sourcePath, 'utf8');

        // Minify the code
        const result = await minify(sourceCode, {
            compress: true,
            mangle: true,
            format: {
                comments: false
            }
        });

        // Write the minified code
        const outputPath = path.join(__dirname, 'index.js');
        fs.writeFileSync(outputPath, result.code);

        console.log('Build completed successfully!');
    } catch (error) {
        console.error('Build failed:', error);
        process.exit(1);
    }
}

build(); 
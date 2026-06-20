const fs = require('fs');
const path = require('path');

const output = fs.readFileSync(path.join(__dirname, 'analyze_output_utf8.txt'), 'utf-8');
// Strip ANSI escape codes
const cleanOutput = output.replace(/\u001b\[.*?m/g, '');
const lines = cleanOutput.split('\n');

const fixes = new Map();

for (const line of lines) {
    if (line.includes('invalid_constant') || line.includes('invalid_annotation_constant_value') || line.includes('creation_with_non_type')) {
        // More flexible regex: just look for lib\...dart:line
        const match = line.match(/(lib[^\:]+\.dart):(\d+):(\d+)/);
        if (match) {
            const filePath = match[1];
            const lineNumber = parseInt(match[2], 10);
            
            if (!fixes.has(filePath)) {
                fixes.set(filePath, []);
            }
            fixes.get(filePath).push(lineNumber);
        }
    }
}

for (const [filePath, lineNumbers] of fixes.entries()) {
    const fullPath = path.join(__dirname, filePath);
    if (!fs.existsSync(fullPath)) continue;
    
    let contentLines = fs.readFileSync(fullPath, 'utf-8').split('\n');
    let changed = false;
    
    for (const lineNum of lineNumbers) {
        // Look for 'const ' on the current line or up to 3 lines above
        for (let i = lineNum - 1; i >= Math.max(0, lineNum - 4); i--) {
            if (contentLines[i] && contentLines[i].includes('const ')) {
                contentLines[i] = contentLines[i].replace(/const\s+/, '');
                changed = true;
                break; // only remove the closest const
            }
        }
    }
    
    if (changed) {
        fs.writeFileSync(fullPath, contentLines.join('\n'));
        console.log(`Fixed ${filePath}`);
    }
}

console.log('Done!');

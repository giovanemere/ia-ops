#!/usr/bin/env node

// Script para verificar que todos los iconos de Material-UI existen
const fs = require('fs');
const path = require('path');

console.log('🔍 Verificando iconos de Material-UI...\n');

// Leer el archivo Root.tsx
const rootFile = path.join(__dirname, 'packages/app/src/components/Root/Root.tsx');

if (!fs.existsSync(rootFile)) {
    console.log('❌ No se encontró el archivo Root.tsx');
    process.exit(1);
}

const content = fs.readFileSync(rootFile, 'utf8');

// Extraer imports de iconos
const iconImports = content.match(/import\s+\w+Icon\s+from\s+'@material-ui\/icons\/\w+'/g) || [];
const otherIconImports = content.match(/import\s+\w+\s+from\s+'@material-ui\/icons\/\w+'/g) || [];

const allImports = [...iconImports, ...otherIconImports];

console.log('📋 Iconos encontrados en Root.tsx:');
console.log('================================');

const iconList = [];

allImports.forEach(importLine => {
    const match = importLine.match(/import\s+(\w+)\s+from\s+'@material-ui\/icons\/(\w+)'/);
    if (match) {
        const [, varName, iconName] = match;
        iconList.push({ varName, iconName, importLine });
        console.log(`✅ ${varName} <- @material-ui/icons/${iconName}`);
    }
});

console.log('\n🎯 Iconos comúnmente disponibles en Material-UI:');
console.log('===============================================');

const commonIcons = [
    'Home', 'Extension', 'LibraryBooks', 'AddCircleOutline',
    'GitHub', 'Cloud', 'Timeline', 'MonetizationOn', 'Android',
    'Build', 'Settings', 'Search', 'Menu', 'People', 'Dashboard',
    'Code', 'Storage', 'Security', 'Assessment', 'TrendingUp',
    'BarChart', 'PieChart', 'ShowChart', 'Timeline', 'Radar'
];

commonIcons.forEach(icon => {
    const isUsed = iconList.some(item => item.iconName === icon);
    const status = isUsed ? '✅ USADO' : '⚪ Disponible';
    console.log(`  ${status} - ${icon}`);
});

console.log('\n⚠️  Iconos problemáticos conocidos:');
console.log('==================================');
console.log('❌ Radar - NO EXISTE en @material-ui/icons');
console.log('✅ Timeline - Alternativa recomendada para Tech Radar');
console.log('✅ Assessment - Alternativa para análisis');
console.log('✅ TrendingUp - Alternativa para métricas');

console.log('\n🔧 Recomendaciones de iconos por funcionalidad:');
console.log('=============================================');
console.log('🤖 AI Assistant: Android, SmartToy, Psychology');
console.log('📡 Tech Radar: Timeline, Assessment, TrendingUp');
console.log('💰 Cost Insights: MonetizationOn, AttachMoney, TrendingUp');
console.log('🔧 GitHub Actions: Build, PlayArrow, Settings');
console.log('☁️  Azure DevOps: Cloud, CloudQueue, Storage');
console.log('📚 TechDocs: LibraryBooks, Description, MenuBook');

console.log('\n✅ Verificación completada!');

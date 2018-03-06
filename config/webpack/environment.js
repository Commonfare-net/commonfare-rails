const { environment } = require('@rails/webpacker');
const { resolve } = require('path');

// Enable css modules with sass loader
const sassLoader = environment.loaders.get('sass')
sassLoader.use.find(item => item.loader === 'sass-loader').options.includePaths = [
  resolve('app', 'javascript', 'src', 'styles'),
  resolve('node_modules')
];
const cssLoader = sassLoader.use.find(item => item.loader === 'css-loader')

cssLoader.options = Object.assign({}, cssLoader.options, {
//   modules: true,
//   localIdentName: '[path][name]__[local]--[hash:base64:5]',
  includePaths: [
    resolve('app', 'javascript', 'src', 'styles'),
    resolve('node_modules')
  ]
})

module.exports = environment

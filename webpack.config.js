var path = require("path");
var HtmlWebpackPlugin = require("html-webpack-plugin");
var ExtractTextPlugin = require("extract-text-webpack-plugin");

// Purescript Config
var psc = {
  srcs: [ "src[]=bower_components/purescript-*/src/**/*.purs",
          "src[]=app/**/*.purs" ],
  ffis: [ "ffi[]=bower_components/purescript-*/src/**/*.js",
          "ffi[]=app/**/*.js"],
  output: "output"
};

module.exports = {

  entry: "./index.js",
  output: {
    path: path.join(__dirname, "public"),
    filename: "app.js"
  },

  module: {
    loaders: [
      {
        test: /\.purs$/,
        loader: "purs-loader?output=" + psc.output + "&" + psc.srcs.concat(psc.ffis).join("&")
      },
      {
        test:   /\.css$/,
        loader: "style-loader!css-loader!postcss-loader"
      }
    ]
  },

  resolve: {
    modulesDirectories: [
      "node_modules",
      "bower_components/purescript-prelude/src"
    ],
    extensions: ["", ".js"]
  },

  plugins: [
    new ExtractTextPlugin("styles.css"),
    new HtmlWebpackPlugin({
      title: "Purs Test",
      hash: true,
      template: "./app/index.html",
      inject: "body"
    })
  ],

  postcss: function (webpack) {
    return [
        // https://github.com/jonathantneal/postcss-short
        require("postcss-short")()

        // https://github.com/postcss/autoprefixer
      , require("autoprefixer")()

        // https://github.com/stylelint/stylelint
      , require("stylelint")()

        // https://github.com/peterramsing/lost
      , require("lost")()

        // https://github.com/anandthakker/doiuse
      , require("doiuse")({
          browsers: ["ie >= 8"]
        })

        // https://github.com/postcss/postcss-import
      , require("postcss-import")({
          addDependencyTo: webpack
        })

        // https://github.com/jonathantneal/postcss-font-magician
      , require("postcss-font-magician")()

        // https://github.com/SlexAxton/css-colorguard
      , require("colorguard")()

        // http://cssnano.co/
      , require("cssnano")()

        // https://github.com/outpunk/postcss-each
      , require("postcss-each")()

        // https://github.com/markgoodyear/postcss-vertical-rhythm
      , require("postcss-vertical-rhythm")()

        // https://github.com/postcss/postcss-nested
      , require("postcss-nested")()
    ];
  },

  devServer: {
    contentBase: "./public",
    historyApiFallback: true
  }
}

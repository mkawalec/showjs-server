Show.js server
==============

This is a server side of Show.js. You can obtain the raw, compiled version at [the source](https://syncjs.io). This repository is used primarily for development, so you should head there if you want to know more about the project.


Working on the server side
--------------------------

You are just a couple keystrokes from it! Type the following into your terminal. Nothing bad will happen (I promise, right?).

    sudo npm install -g bower gulp coffee-script
    npm install
    bower install
    gulp build

You should have the built files inside the `static/` directory. If you want to go full-on dev, you probably want gulp to be watching for your changes:

    gulp

will do. In order to run the server side do:

    ./syncer.coffee

Then head to [http://localhost:55555](http://localhost:55555).

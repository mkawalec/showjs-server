Show.js server
==============

This is a server side of Show.js. You can obtain the raw, compiled version at [the source](https://syncjs.io). This repository is used primarily for development, so you should head there if you want to know more about the project.


Working on the server side
--------------------------

You are just a couple keystrokes from it! Make sure you have `docker` and `fig` installed and do:

    fig up

Then head to [http://localhost:55555](http://localhost:55555).
The raw DB connection is available at port 5445, you can connect to it with `psql`. The password is `showjs`.


Plan for rewrite
----------------

* [x] knex works
* [x] bookshelf models are added
* [x] HapiJS with Joi are used on the server side
* [x] Add socketIO endpoints verification with Joi and custom handler
* [ ] Add model verification with checkit
* [ ] Isomorphic FluxApp and FluxApp router are used throughout
* [ ] Users are added, with the ability to log in/out and add presentations
* [ ] Current functionality is added
* [ ] Tests with PhantomJS
* [ ] There is the ability to add PDF presentations

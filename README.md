# diplicitous

This is a sister project of [diplicity][diplicity]. Its aim is to create a great web interface for that project.

Notable planned features:

- fully interactive point-and-click interface
- live updates

More will be added as they get planned.

## Installation

To install and run:

1. Install [diplicity][diplicity]. Run with `go run diplicity/diplicity.go --appcache=false --port=8080` (appcache=false is optional, but recommended for development)
1. Install dependencies: [compass][compass] and [susy][susy] (to compile the project's SASS), [node][node] & [CoffeeScript][CoffeeScript] (to run the web server - consider also [nodemon][nodemon], which watches your files and restarts automatically)
1. Clone this repo and run `npm install`.
1. Run `compass compile` (or `compass watch` if you're going to make changes to the SASS files) under the project root directory.
1. Run the web server with: `coffee server.coffee <port>` (or `nodemon server.coffee <port> -w coffee/ -e coffee`)
1. Visit `http://localhost:<port>/`.

At this point, you will probably see nothing besides a navigation bar. You need to create a game using diplicity. To do that, visit `http://localhost:8080` (or whatever port you set above) and create a game. It should appear on the diplicitous page, too.

## Attribution

This project was based off of [angular-coffee-seed](https://github.com/PavelVanecek/angular-coffee-seed) (but has since outgrown it).

[diplicity]: https://github.com/zond/diplicity "Diplicity repo"
[compass]: http://compass-style.org/install/ "Compass"
[susy]: http://susydocs.oddbird.net/en/latest/install/ "Susy docs"
[CoffeeScript]: http://coffeescript.org/ "CoffeeScript"
[node]: http://nodejs.org/ "Node.js"
[nodemon]: https://github.com/remy/nodemon "Nodemon"

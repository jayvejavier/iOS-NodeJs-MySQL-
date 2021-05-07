const express = require('express'),
    path = require('path'),
    fileUpload = require('express-fileupload'),
    bodyParser = require('body-parser'),
    morgan = require('morgan');

const PORT = process.env.PORT || 8080
const app = express();
app.set('port', PORT);
app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(morgan('short'));
app.use(fileUpload({
    useTempFiles: true
}));

const route = require('./route.js');
app.use(route);

// localhost: PORT
app.listen(app.get('port'), function() {
    console.log(
        'Express server listening on port ' +
        app.get('port') +
        '. Start Time: ' +
        new Date() 
    );
});
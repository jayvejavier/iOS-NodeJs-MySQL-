const express = require('express'),
mysql = require('mysql'),
router = express.Router();

var cloudinary = require('cloudinary').v2;

cloudinary.config({
    cloud_name: 'dc3xmpa3y',
    api_key: '135924642217755',
    api_secret: 'vDUq15FM2EnLnjLiaSa5Tf4zbqs'
});

// localhost server
// const pool = mysql.createPool({
//     connectionLimit: 10,
//     host: 'localhost',
//     user: 'root',
//     database: 'avengers_db',  
// });

// heroku server
const pool = mysql.createPool({
    connectionLimit: 10,
    host: 'us-cdbr-east-02.cleardb.com',
    user: 'b304fc876995ac',
    password: '389f43f7',
    database: 'heroku_3d60c976b385cbc',  
});

function getConnection() {
    return pool
}

router.get("/", (req,res) => {
    console.log("Responding to root route")
    const connection =  getConnection()
    const sql = "SELECT * FROM heroes";
    connection.query(sql, (err, rows, fields) => {
        if(err) {
            console.log("Failed to query for heroes: " + err) 
            res.sendStatus(500)
            return
        }
        if(rows.length <= 0) {
            console.log("Empty Table!");
        }
        res.render('index.ejs',{data:rows});
    });
});

router.get("/heroes", (req,res) => {
// get all heroes
const connection =  getConnection()
    const sql = "SELECT * FROM heroes";
    connection.query(sql, (err, rows, fields) => {
        if(err) {
            console.log("Failed to query for heroes: " + err) 
            res.sendStatus(500)
            return
        }
        res.json(rows);
    });
});

router.get("/hero/:heroId", (req,res) => {
    // get specified hero
    console.log("Fetching hero with id: " + req.params.heroId)
    const connection = getConnection()
    const heroId = req.params.heroId
    const sql = "SELECT * FROM heroes WHERE id = ?"
    connection.query(sql, [heroId], (err, rows, fields) => {
        if(err) {
            console.log("Failed to query for specified hero: " + err) 
            res.sendStatus(500)
            return
        }
        if(rows.length > 0) {
            res.send(rows[0]);
        }
        else {
            res.send(`Failed to find hero by id: ${heroId}`);
        }  
    })
});

router.post('/hero_create', (req, res) => {
    // create hero
    const connection =  getConnection()
    const reqBody  = req.body;
    const name = reqBody.create_name;
    const special_skill = reqBody.create_special_skill;
    const reqFiles = req.files;

    if (!reqFiles) {
        console.log("reqFiles " + reqFiles)
        return res.status(400).send('No files were uploaded.');
    }
    const file = reqFiles.uploaded_image;
    
    if(file.mimetype == "image/jpeg" ||file.mimetype == "image/png"||file.mimetype == "image/gif" ){                   
        console.log(file);

        // save images on cloudinary instead on static files
        // file.mv('public/images/uploaded_images/'+file.name, function(err) {
       
        cloudinary.uploader.upload(file.tempFilePath, function(err, result) {
            if (err) {
                return res.status(500).send(err);
            }
            const sql = "INSERT INTO heroes(name,special_skill,image) VALUES (?, ?, ?)";
            connection.query(sql, [name, special_skill, result.url],function(err, result) {
                if(err) {
                    console.log("Failed to insert new hero: " + err) 
                    return res.serverError(err.toString());
                }
                console.log("Inserted a new hero with id: ", result.insertId)

                res.redirect('/');
                res.end();
            });
        });
    }
    else {
        console.log("Format is not allowed , please upload file with '.png','.gif','.jpg'");
    }
});

router.delete("/hero/:heroId", (req,res) => {
    // delete specified hero
    console.log("Deleting hero with id: " + req.params.heroId)
    const connection = getConnection()
    const heroId = req.params.heroId
    const sql = "DELETE FROM heroes WHERE id = ?"
    connection.query(sql, [heroId], (err, rows, fields) => {
        if(err) {
            console.log("Failed to query for specified hero: " + err) 
            res.sendStatus(500)
            return
        }
        if(rows.length > 0) {
            res.send('Finished deleting hero');
        }
        else {
            res.send(`Failed to find hero by id: ${heroId}`);
        }  
    })
});

module.exports = router
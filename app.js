const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const request = require("request");
const https = require("https");
app.use(bodyParser.urlencoded({
  extended: true
}));


//to impoort css and image.
app.use(express.static("public"));

app.get("/", function(req, res) {
  res.sendFile(__dirname + "/signup.html");
})
app.post("/", function(req, res) {
  const email = req.body.email;
  const fname = req.body.fName;
  const lname = req.body.lName;
  //creating data to send which is a js object
  const data = {
    members: [{
      email_address: email,
      status: "subscribed",
      merge_fields: {
        FNAME: fname,
        LNAME: lname
      }
    }]
  };
  //converting this data' to json format;
  const jsonData = JSON.stringify(data);
  //creating options for http.reuest function;
  const options = {
    method: "POST",
    auth: "ChetanEcho:d1b36708fc105cda428c44a59b25393c-us1"
  }
  const url = "https://us1.api.mailchimp.com/3.0/lists/db69f284f2";

  const request = https.request(url, options, function(response) {
    //check succes or not:
    if (response.statusCode === 200) {
      res.sendFile(__dirname + "/success.html");
    } else {
      res.sendFile(__dirname + "/failure.html");
    }
    response.on("data", function(data) {
      console.log(JSON.parse(data));
    })

  });


  request.write(jsonData);
  request.end();
});


app.post("/failure", function(req, res){
  return res.redirect("/")
});







app.listen(process.env.PORT ||3000, function() {
  console.log("server at localhost:3000");
})



//MailChimp api key:
//d1b36708fc105cda428c44a59b25393c-us1
//list ID;
//db69f284f2
//url
//https://us1.api.mailchimp.com/3.0/

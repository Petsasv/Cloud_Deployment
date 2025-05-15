const express = require("express");
const MongoClient = require("mongodb").MongoClient;
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

const PORT = 3000;
const DB = "devops";
var URL = `mongodb://127.0.0.1:27017`;
const client = new MongoClient(URL);

app.post("/register", async (req, res) => {
  const { username } = req.body;

  try {
    const result = await client.connect();

    const foundUser = await result
      .db(DB)
      .collection("user")
      .findOne({ username });

    if (foundUser) {
      res
        .status(500)
        .json({ error: `User with username ${username} already exists` });

      return;
    }

    await result.db(DB).collection("user").insertOne(req.body);

    result.close();
    res.status(200).json({ success: true });
  } catch (err) {
    throw err;
  }
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const result = await client.connect();

    const foundUser = await result.db(DB).collection("user").findOne({ email });

    if (foundUser && foundUser.password !== password) {
      res.status(500).json({ error: "Passwords do not match" });
      return;
    }

    result.close();
    res.status(200).json({ success: true });
  } catch (err) {
    throw err;
  }
});

app.listen(PORT, () => {
  console.log("Server listening on port ", PORT);
});

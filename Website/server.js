const express = require("express");
const { MongoClient } = require("mongodb");
const bodyParser = require("body-parser");
const cors = require("cors");
const path = require("path");

const app = express();
const PORT = 3000;
const DB = "devops";
const URL = "mongodb://127.0.0.1:27017";

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files
app.use(express.static(__dirname));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "firstPage.html"));
});

app.post("/register", async (req, res) => {
  const { name, username, email, password } = req.body;
  const client = new MongoClient(URL);

  try {
    await client.connect();
    const db = client.db(DB);
    const existingUser = await db.collection("user").findOne({ username });

    if (existingUser) {
      return res
        .status(400)
        .json({ error: `Username "${username}" already exists.` });
    }

    await db.collection("user").insertOne({ name, username, email, password });
    res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    await client.close();
  }
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const client = new MongoClient(URL);

  try {
    await client.connect();
    const db = client.db(DB);
    const user = await db.collection("user").findOne({ email });

    if (!user || user.password !== password) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Internal server error" });
  } finally {
    await client.close();
  }
});

app.listen(PORT, () => {
  console.log("Server listening on port", PORT);
});

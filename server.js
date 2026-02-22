const express = require("express");
const fetch = require("node-fetch");
const cors = require("cors");

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3000;

app.get("/api/questions", async (req, res) => {
  const { amount = 10, category = 17, difficulty = "medium" } = req.query;

  try {
    const response = await fetch(
      `https://opentdb.com/api.php?amount=${amount}&category=${category}&difficulty=${difficulty}&type=multiple`
    );

    const data = await response.json();

    const cleaned = data.results.map((q) => {
      const decode = (str) =>
        str
          .replace(/&quot;/g, '"')
          .replace(/&#039;/g, "'")
          .replace(/&amp;/g, "&");

      return {
        question: decode(q.question),
        options: shuffle([
          ...q.incorrect_answers.map(decode),
          decode(q.correct_answer),
        ]),
        correctAnswer: decode(q.correct_answer),
      };
    });

    res.json({ questions: cleaned });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch questions" });
  }
});

function shuffle(array) {
  return array.sort(() => Math.random() - 0.5);
}

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

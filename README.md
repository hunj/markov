# Markov Sentence Generator

implementation in Ruby, inspired by [hrs/markov-sentence-generator](https://github.com/hrs/markov-sentence-generator):

> This program generates a sentence's worth of "real-looking" text using a Markov model and sample textual training input. Given some sample text from which to build a model, the program prints out a 
> sentence based on a Markov chain.

This is a _word-based_ implementation; _currently in development._

## Instructions

To run:

```shell
$ ruby sentence_generator.rb [text] [chain length]
```

where `text ` is the path to the file, and `chain length`  optionally represents the number of words taken into account when choosing the next word. Chain length defaults to 3 (reasonable), but increasing this may generate more realistic text, albeit slightly more slowly. Depending on the text, increasing the chain length past 6 or 7 words probably won't do much good -- at that point you're usually plucking out whole sentences anyway, so using a Markov model is kind of redundant.

### Example

To demonstrate with a real-life data example, I have scraped tweets from [@realDonaldTrump](https://twitter.com/realDonaldTrump) and placed in `src/trump.txt`. The result is interesting:

```shell
$ ruby generate_sentence.rb src/trump.txt
"Together, we will Make America Great Again agenda from beginning, never wins elections! working together, we will Make America Great Again agenda from beginning, without hesitation! Two dozen nfl players continue to kneel during the National Anthem, showing total disrespect to our Flag amp; Country."
```


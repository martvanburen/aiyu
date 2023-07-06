# AiYu - GPT-Based Language Practice

This app is motivated by two developments:
1) I've spent much of my life on language learning. Consistently the hardest
part is getting good at real-life conversations.
2) Large language models like GPT change everything. It's changed how I think
about everything that I do, and language-learning is no exception. Already, I
use ChatGPT all the time for helping me study Korean, and this app is me
experimenting with ways to automate common study workflows.

## Idea #1: Quick Question Mode

I want to make it as easy as possible to ask GPT a quick question in Korean or
Chinese. Ideally, it will be launchable from a quick shortcut. Then, besides
just answering my question, the app will ask the GPT API to analyse my question
and suggest grammar or vocabulary improvements that would have made the sentence
sound more natural and well-articulated.

## Idea #2: Conversation Mode

An extension to quick-question mode, I can have a discussion with GPT about any
topic. At each prompt, besides giving me a response, the app will separately use
GPT to give feedback on my sentences. This should include quick shortcuts to add
new words or interesting sentences to my Anki flashcards.

## Idea #3: Word Analysis

Create deeplinks that I can use when making my Anki flashcards, which ask GPT
some common questions about the word I'm studying such as:
- What are some similar words that are commonly confused with this word.
- Is this used in everyday speech? Or more just in written situations?
- For each common usage of the word, make an real-life example sentence.

## Idea #4: Enriching Flashcards

Implement various deeplinks that enrich my Anki flashcards. When these links are
clicked from a flashcard, the app would automatically find that flashcard
through the Anki API and populate additional fields. Some potential examples:
- Adding audio where it didn't exist before.
- Adding an example sentence (and maybe also its audio).
- Double-checking the translation is actually correct.

## Current Progress

- [x] Basic app layout.
- [x] Set-up pages for Ideas #1 & #2.
- [x] Connect to GPT API.
- [x] Voice input in English, Korean and Chinese.
- [x] Audio output in English, Korean, Chinese.
- [x] Implement Mode #1.
- [x] Quick shortcuts to launch question mode.
- [x] Implement Mode #2.
- [ ] Integrate with Anki to add flashcards.
- [ ] Add deeplinks.
- [ ] Implement Mode #3.
- [ ] Implement Mode #4.

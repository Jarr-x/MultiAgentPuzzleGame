# Two-Bot Escape Room

A two-player escape room where both "players" are autonomous LLM agents. Each bot wakes up trapped in its own sealed room, separated by a shared window, and has to figure out — mostly by talking to the bot next door — how to get out.

Built in **Godot (GDScript)**, with a custom script that calls the **OpenAI API** directly over HTTP (no LLM framework — just raw requests and hand-built prompt/response handling).

Here is a video of the project running:
https://photos.app.goo.gl/4zM9rzWhERaknktG9

## Environment Variables
To run this project locally, you will need an OpenAI API key. 
The project expects this key to be set as an environment variable:

### On Linux/macOS
export OPENAI_API_KEY="your_api_key_here"

### On Windows (Command Prompt)
set OPENAI_API_KEY="your_api_key_here"

## The setup

Each room has different objects. In this run:

- **LeftBot's room:** a door, a window, and a signboard that reads *"Middle Left Right"*
- **RightBot's room:** a door, a window, and three unlabeled buttons

Neither bot can see the other's room. The signboard is useless without the buttons, and the buttons are useless without knowing the order — so the only way out is for the two bots to notice this and share what they see through the window.

Each bot interacts with the world by naming an object in asterisks, e.g. `*door*`, `*leftButton*`, and can talk to whoever's at the window using plain quoted dialogue. Solving the room means realizing "Middle Left Right" is a button-press order, relaying that across the window, and pressing all three in sequence to unlock the shared door.

## How it's wired up

- `Scripts/OpenAi.gd` — sends the conversation history to the OpenAI API and returns the model's next move
- `Scripts/bot.gd` / `Scripts/mind.gd` — each bot's local state: what it can see, what it's already tried, and its running conversation log
- `Scripts/ai_interactable.gd`, `door.gd`, `levers.gd`, `window_handler.gd` — the objects each bot can act on
- `AIPrompts/puzzleRoomSystem.txt`, `puzzleRoomSystem2.txt` — the system prompts that define each bot's room, its object list, and the interaction syntax
- `AIPrompts/followPrompt.txt`, `LogicMaker.txt` — follow-up prompt templates used to keep the model's responses in the expected action/dialogue format

## The hard part: getting the turn-taking right

The core challenge wasn't the puzzle logic — it was making sure the two bots didn't step on each other. Since each bot is a separate call to the OpenAI API, there's no shared clock keeping them in sync. Early on, this caused two failure modes:

1. Both bots would try to act or speak at once, and the conversation would get out of order or one bot's action would get lost.
2. If one bot walked away from the window mid-conversation, the other would sit there waiting on a response that was never coming.

The fix was a **turn-based signal system**: when a bot finishes its action for the turn, it sends a signal that hands control to the other bot. Only the bot holding the signal is allowed to act or speak. On top of that, a **timeout failsafe** means that if a bot doesn't hand control back within a set window (e.g. the other side walked away), the waiting bot proceeds on its own instead of stalling indefinitely.

That combination — explicit turn-passing plus a timeout as a backstop — is what actually got two independent LLM calls behaving like a coordinated pair instead of two agents talking past each other.

## Sample run

Below is an excerpt from an actual playthrough. LeftBot reads the sign, RightBot finds the buttons, and the two coordinate through the window to work out that the sign's message is a press order:

> **LeftBot:** *(reads the sign)* "Middle Left Right" seems like it could be a clue — maybe a sequence of actions.
>
> **RightBot:** *(at the window)* "I see a set of three buttons at the back of the room. They might correspond to 'Middle Left Right.' Should I try pressing the middle button?"
>
> **LeftBot:** "Yes, try pressing the middle button! Let's see what happens."
>
> *(RightBot presses middle, then — after the conversation ends and the timeout fires — left, then right, in the order from the sign. The shared door unlocks.)*

## Stack

- Godot Engine / GDScript
- OpenAI API (direct HTTP calls, no framework)
- Custom prompt templates for room state, object lists, and turn-passing rules

## Possible next steps

- Let the bots negotiate a shared vocabulary for objects instead of hardcoding names in the system prompt
- Log full transcripts to disk for easier debugging of multi-turn failures
- Generalize beyond a fixed two-room layout to N rooms / N bots
